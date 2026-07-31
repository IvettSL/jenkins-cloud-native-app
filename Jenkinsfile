pipeline {
    agent {
        label 'docker-agent'  // ? Usa el agente con Docker
    }
    
    stages {
        stage('Checkout') {
            steps { checkout scm }
        }
        stage('Build') {
            steps {
                sh '''
                    echo "=== Verificando Docker ==="
                    docker --version
                    
                    echo "=== Construyendo imagen ==="
                    docker build -t jenkins-cloud-native-app:latest .
                '''
            }
        }
        stage('Deploy') {
            steps {
                sh '''
                    echo "=== Desplegando en Kubernetes ==="
                    kubectl apply -k kubernetes/overlays/dev
                    kubectl rollout status deployment/jenkins-app -n dev --timeout=120s
                '''
            }
        }
        stage('Test') {
            steps {
                sh '''
                    echo "=== Verificando despliegue ==="
                    kubectl get pods -n dev
                    kubectl get svc -n dev
                '''
            }
        }
    }
    
    post {
        success { echo '? Pipeline exitoso!' }
        failure { echo '? Pipeline fall?!' }
        always { cleanWs() }
    }
}
