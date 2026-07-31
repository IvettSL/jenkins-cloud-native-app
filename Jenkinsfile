pipeline {
    agent any
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Clonando repositorio...'
                checkout scm
            }
        }
        
        stage('Build') {
            steps {
                echo 'Construyendo imagen Docker...'
                sh 'docker build -t jenkins-cloud-native-app:latest .'
            }
        }
        
        stage('Deploy') {
            steps {
                echo 'Desplegando en Kubernetes...'
                sh '''
                    minikube image load jenkins-cloud-native-app:latest
                    kubectl apply -k kubernetes/overlays/dev
                    kubectl rollout status deployment/jenkins-app -n dev --timeout=120s
                '''
            }
        }
        
        stage('Verify') {
            steps {
                echo 'Verificando despliegue...'
                sh '''
                    kubectl get pods -n dev
                    MINIKUBE_IP=$(minikube ip)
                    NODE_PORT=$(kubectl get svc jenkins-app -n dev -o jsonpath='{.spec.ports[0].nodePort}')
                    curl -s "http://${MINIKUBE_IP}:${NODE_PORT}/health"
                '''
            }
        }
    }
    
    post {
        success {
            echo 'Pipeline exitoso!'
        }
        failure {
            echo 'Pipeline fallido!'
        }
        always {
            cleanWs()
        }
    }
}