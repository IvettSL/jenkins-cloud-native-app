pipeline {
    agent any
    
    environment {
        NAMESPACE = 'dev'
        APP_NAME = 'jenkins-cloud-native-app'
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo '?? Clonando repositorio...'
                checkout scm
            }
        }
        
        stage('Deploy') {
            steps {
                echo '?? Desplegando en Kubernetes...'
                sh '''
                    echo "=== Aplicando configuraci?n ==="
                    kubectl apply -k kubernetes/overlays/${NAMESPACE}
                    
                    echo "=== Esperando despliegue ==="
                    kubectl rollout status deployment/jenkins-app -n ${NAMESPACE} --timeout=120s
                    
                    echo "=== Verificando pods ==="
                    kubectl get pods -n ${NAMESPACE}
                '''
            }
        }
        
        stage('Verify') {
            steps {
                echo '?? Verificando despliegue...'
                sh '''
                    echo "=== Servicios ==="
                    kubectl get svc -n ${NAMESPACE}
                    
                    echo "=== Health Check ==="
                    MINIKUBE_IP=$(minikube ip)
                    NODE_PORT=$(kubectl get svc jenkins-app -n ${NAMESPACE} -o jsonpath='{.spec.ports[0].nodePort}')
                    echo "?? Aplicaci?n: http://${MINIKUBE_IP}:${NODE_PORT}/health"
                    
                    # Probar health check
                    sleep 5
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
