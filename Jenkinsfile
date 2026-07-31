pipeline {
    agent {
        label 'built-in'
    }
    
    environment {
        NAMESPACE = 'dev'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Deploy') {
            steps {
                sh '''
                    echo "?? Desplegando en Kubernetes..."
                    kubectl apply -k kubernetes/overlays/${NAMESPACE}
                    kubectl rollout status deployment/jenkins-app -n ${NAMESPACE} --timeout=120s
                '''
            }
        }
        
        stage('Verify') {
            steps {
                sh '''
                    echo "?? Verificando..."
                    kubectl get pods -n ${NAMESPACE}
                    kubectl get svc -n ${NAMESPACE}
                '''
            }
        }
    }
    
    post {
        success {
            echo '? Pipeline exitoso!'
        }
        failure {
            echo '? Pipeline fall?!'
        }
    }
}
