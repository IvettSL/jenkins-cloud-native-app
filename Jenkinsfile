pipeline {
    agent any
    
    environment {
        APP_NAME = 'jenkins-cloud-native-app'
        NAMESPACE = 'dev'
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo '📥 Clonando repositorio...'
                checkout scm
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo '🐳 Construyendo imagen Docker...'
                sh '''
                    docker build -t ${APP_NAME}:latest .
                '''
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                echo '☸️ Desplegando en Kubernetes...'
                sh '''
                    # Cargar imagen en Minikube
                    minikube image load ${APP_NAME}:latest
                    
                    # Asegurar namespace
                    kubectl create namespace ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -
                    
                    # Desplegar
                    kubectl apply -k kubernetes/overlays/dev
                    
                    # Esperar despliegue
                    kubectl rollout status deployment/jenkins-app -n ${NAMESPACE} --timeout=120s
                '''
            }
        }
        
        stage('Verify') {
            steps {
                echo '🔍 Verificando despliegue...'
                sh '''
                    kubectl get pods -n ${NAMESPACE}
                    kubectl get svc -n ${NAMESPACE}
                    
                    # Health check
                    MINIKUBE_IP=$(minikube ip)
                    NODE_PORT=$(kubectl get svc jenkins-app -n ${NAMESPACE} -o jsonpath='{.spec.ports[0].nodePort}')
                    
                    echo "🌐 Probando health check en http://${MINIKUBE_IP}:${NODE_PORT}/health"
                    if curl -s "http://${MINIKUBE_IP}:${NODE_PORT}/health" | grep -q "healthy"; then
                        echo "✅ Health check exitoso!"
                    else
                        echo "⚠️ Health check falló"
                        kubectl logs -n ${NAMESPACE} deployment/jenkins-app --tail=20
                        exit 1
                    fi
                '''
            }
        }
    }
    
    post {
        success {
            echo '✅ Pipeline completado exitosamente!'
        }
        failure {
            echo '❌ Pipeline falló!'
        }
        always {
            cleanWs()
        }
    }
}