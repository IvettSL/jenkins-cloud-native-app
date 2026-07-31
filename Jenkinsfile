pipeline {
    agent {
        label 'docker-agent'
    }
    
    environment {
        NAMESPACE = 'dev'
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
                    kubectl version --client
                    
                    echo "=== Construyendo imagen ==="
                    docker build -t jenkins-cloud-native-app:latest .
                    
                    echo "=== Cargando en Minikube ==="
                    minikube image load jenkins-cloud-native-app:latest || echo "Minikube no disponible"
                '''
            }
        }
        
        stage('Deploy') {
            steps {
                echo '?? Desplegando en Kubernetes...'
                sh '''
                    echo "=== Desplegando ==="
                    kubectl apply -k kubernetes/overlays/${NAMESPACE}
                    kubectl rollout status deployment/jenkins-app -n ${NAMESPACE} --timeout=120s
                '''
            }
        }
        
        stage('Verify') {
            steps {
                echo '?? Verificando despliegue...'
                sh '''
                    echo "=== Pods ==="
                    kubectl get pods -n ${NAMESPACE}
                    
                    echo "=== Servicios ==="
                    kubectl get svc -n ${NAMESPACE}
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
