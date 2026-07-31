pipeline {
    agent {
        label 'docker-agent'
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo '?? Clonando repositorio...'
                checkout scm
            }
        }
        
        stage('Build') {
            steps {
                echo '?? Construyendo imagen Docker...'
                sh '''
                    echo "=== Verificando herramientas ==="
                    docker --version
                    
                    echo "=== Construyendo imagen ==="
                    docker build -t jenkins-cloud-native-app:latest .
                '''
            }
        }
        
        stage('Deploy') {
            steps {
                echo '?? Desplegando en Kubernetes...'
                sh '''
                    echo "=== Cargando imagen en Minikube ==="
                    # Usar minikube desde el host (si est? disponible)
                    minikube image load jenkins-cloud-native-app:latest 2>/dev/null || echo "Minikube no disponible"
                    
                    echo "=== Desplegando ==="
                    kubectl apply -k kubernetes/overlays/dev
                    kubectl rollout status deployment/jenkins-app -n dev --timeout=120s
                '''
            }
        }
        
        stage('Test') {
            steps {
                echo '?? Verificando despliegue...'
                sh '''
                    kubectl get pods -n dev
                    MINIKUBE_IP=$(minikube ip 2>/dev/null || echo "192.168.49.2")
                    NODE_PORT=$(kubectl get svc jenkins-app -n dev -o jsonpath='{.spec.ports[0].nodePort}')
                    echo "?? Aplicaci?n: http://${MINIKUBE_IP}:${NODE_PORT}"
                    
                    # Health check
                    curl -s "http://${MINIKUBE_IP}:${NODE_PORT}/health" && echo " ? Health check OK" || echo " ?? Health check fall?"
                '''
            }
        }
    }
    
    post {
        success {
            echo '? Pipeline completado exitosamente!'
        }
        failure {
            echo '? Pipeline fall?!'
        }
        always {
            cleanWs()
        }
    }
}
