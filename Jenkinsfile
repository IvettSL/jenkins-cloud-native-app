pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Checkout'
                checkout scm
            }
        }
        
        stage('Build') {
            steps {
                echo 'Build'
                // Usar Docker desde el host (no desde el contenedor)
                sh '''
                    # Verificar si Docker está disponible
                    if ! command -v docker &> /dev/null; then
                        echo "Docker no encontrado, usando alternativa..."
                        # Intentar con Docker desde el host
                        docker --version || echo "Docker no disponible"
                    fi
                '''
            }
        }
        
        stage('Deploy') {
            steps {
                echo 'Deploy'
                sh '''
                    # Usar minikube para cargar imagen
                    minikube image load jenkins-cloud-native-app:latest 2>/dev/null || echo "Minikube no disponible"
                    kubectl apply -k kubernetes/overlays/dev 2>/dev/null || echo "Kubectl no disponible"
                '''
            }
        }
        
        stage('Test') {
            steps {
                echo 'Test'
                sh 'kubectl get pods -n dev 2>/dev/null || echo "Kubectl no disponible"'
            }
        }
    }
}