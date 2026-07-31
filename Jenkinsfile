pipeline {
    agent { label 'built-in' }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build') {
            steps {
                sh '''
                    echo "?? Construyendo imagen Docker..."
                    docker build -t jenkins-cloud-native-app:latest .
                    minikube image load jenkins-cloud-native-app:latest
                '''
            }
        }
        
        stage('Deploy') {
            steps {
                sh '''
                    echo "?? Desplegando en Kubernetes..."
                    kubectl apply -k kubernetes/overlays/dev
                    kubectl rollout status deployment/jenkins-app -n dev --timeout=120s
                '''
            }
        }
        
        stage('Test') {
            steps {
                sh '''
                    echo "?? Verificando despliegue..."
                    kubectl get pods -n dev
                    MINIKUBE_IP=$(minikube ip)
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
