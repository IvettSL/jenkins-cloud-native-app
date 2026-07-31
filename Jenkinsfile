pipeline {
    agent { label 'built-in' }
    
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
                    docker --version || echo "Docker no disponible en built-in"
                    
                    echo "=== Construyendo imagen ==="
                    docker build -t jenkins-cloud-native-app:latest . || echo "Docker build fall?"
                '''
            }
        }
        
        stage('Deploy') {
            steps {
                echo '?? Desplegando en Kubernetes...'
                sh '''
                    echo "=== Cargando imagen en Minikube ==="
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
                    echo "=== Pods ==="
                    kubectl get pods -n dev
                    
                    echo "=== Servicios ==="
                    kubectl get svc -n dev
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
