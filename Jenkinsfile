pipeline {
    agent { label 'built-in' }
    stages {
        stage('Build') {
            steps {
                sh 'docker build -t jenkins-cloud-native-app:latest .'
            }
        }
        stage('Deploy') {
            steps {
                sh 'minikube image load jenkins-cloud-native-app:latest && kubectl apply -k kubernetes/overlays/dev'
            }
        }
        stage('Test') {
            steps {
                sh 'kubectl get pods -n dev'
            }
        }
    }
}
