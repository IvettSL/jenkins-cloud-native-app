pipeline {
    // Usar el nodo principal de Jenkins (donde está Docker)
    agent { label 'built-in' }
    
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
                    echo "=== Construyendo imagen ==="
                    docker build -t ${APP_NAME}:latest .
                    
                    echo "=== Cargando imagen en Minikube ==="
                    minikube image load ${APP_NAME}:latest || echo "Minikube image load falló, continuando..."
                '''
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                echo '☸️ Desplegando en Kubernetes...'
                sh '''
                    echo "=== Asegurando namespace ==="
                    kubectl create namespace ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -
                    
                    echo "=== Desplegando aplicación ==="
                    kubectl apply -k kubernetes/overlays/dev
                    
                    echo "=== Esperando despliegue ==="
                    kubectl rollout status deployment/jenkins-app -n ${NAMESPACE} --timeout=120s
                    
                    echo "=== Verificando pods ==="
                    kubectl get pods -n ${NAMESPACE}
                '''
            }
        }
        
        stage('Verify Deployment') {
            steps {
                echo '🔍 Verificando despliegue...'
                sh '''
                    echo "=== Servicios ==="
                    kubectl get svc -n ${NAMESPACE}
                    
                    echo "=== Health Check ==="
                    MINIKUBE_IP=$(minikube ip)
                    NODE_PORT=$(kubectl get svc jenkins-app -n ${NAMESPACE} -o jsonpath='{.spec.ports[0].nodePort}')
                    echo "🌐 Aplicación en: http://${MINIKUBE_IP}:${NODE_PORT}"
                    
                    # Probar health check
                    sleep 5
                    curl -s "http://${MINIKUBE_IP}:${NODE_PORT}/health" && echo " ✅ Health check OK" || echo " ⚠️ Health check falló"
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