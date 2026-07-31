pipeline {
    agent any
    
    environment {
        APP_NAME = 'jenkins-cloud-native-app'
        DOCKER_REGISTRY = 'localhost:5000'
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
                script {
                    sh '''
                        docker build -t ${APP_NAME}:latest .
                        docker tag ${APP_NAME}:latest ${DOCKER_REGISTRY}/${APP_NAME}:latest
                    '''
                }
            }
        }
        
        stage('Push to Registry') {
            steps {
                echo '📤 Subiendo imagen al registry local...'
                script {
                    sh '''
                        # Verificar si el registry local está corriendo
                        if ! docker ps | grep -q registry; then
                            docker run -d -p 5000:5000 --name registry registry:2
                        fi
                        docker push ${DOCKER_REGISTRY}/${APP_NAME}:latest
                    '''
                }
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                echo '☸️ Desplegando en Kubernetes...'
                script {
                    sh '''
                        # Asegurar que el namespace existe
                        kubectl create namespace ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -
                        
                        # Cargar imagen en Minikube (si es necesario)
                        minikube image load ${APP_NAME}:latest || true
                        
                        # Desplegar usando kustomize
                        kubectl apply -k kubernetes/overlays/dev
                        
                        # Esperar a que los pods estén listos
                        kubectl rollout status deployment/jenkins-app -n ${NAMESPACE} --timeout=120s
                    '''
                }
            }
        }
        
        stage('Verify') {
            steps {
                echo '🔍 Verificando despliegue...'
                script {
                    sh '''
                        echo "📊 Estado de pods:"
                        kubectl get pods -n ${NAMESPACE}
                        
                        echo "📊 Estado de servicios:"
                        kubectl get svc -n ${NAMESPACE}
                        
                        echo "🔍 Verificando health check..."
                        # Obtener IP de Minikube y puerto NodePort
                        MINIKUBE_IP=$(minikube ip)
                        NODE_PORT=$(kubectl get svc jenkins-app -n ${NAMESPACE} -o jsonpath='{.spec.ports[0].nodePort}')
                        
                        # Probar health check usando NodePort
                        if curl -s "http://${MINIKUBE_IP}:${NODE_PORT}/health" | grep -q "healthy"; then
                            echo "✅ Health check exitoso!"
                        else
                            echo "⚠️ Health check falló, verificando logs..."
                            kubectl logs -n ${NAMESPACE} deployment/jenkins-app --tail=20
                            exit 1
                        fi
                    '''
                }
            }
        }
    }
    
    post {
        success {
            echo '✅ Pipeline completado exitosamente!'
            
            // Enviar notificación por email
            emailext (
                subject: "✅ Pipeline exitoso: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """
                    El pipeline se completó correctamente.
                    
                    Aplicación: ${APP_NAME}
                    Namespace: ${NAMESPACE}
                    URL: ${env.BUILD_URL}
                    
                    Para acceder a la aplicación:
                    kubectl port-forward -n ${NAMESPACE} svc/jenkins-app 8083:8080
                    http://localhost:8083
                """,
                to: 'equipo-dev@ejemplo.com'
            )
        }
        
        failure {
            echo '❌ Pipeline falló!'
            
            emailext (
                subject: "❌ Pipeline fallido: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """
                    El pipeline falló.
                    
                    Aplicación: ${APP_NAME}
                    Namespace: ${NAMESPACE}
                    URL: ${env.BUILD_URL}
                    
                    Revisa los logs para más detalles.
                """,
                to: 'equipo-dev@ejemplo.com'
            )
        }
        
        always {
            echo '🧹 Limpiando workspace...'
            cleanWs()
        }
    }
}
