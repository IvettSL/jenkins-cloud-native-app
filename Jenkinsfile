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
                sh 'docker build -t jenkins-cloud-native-app:latest .'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploy'
                sh 'minikube image load jenkins-cloud-native-app:latest && kubectl apply -k kubernetes/overlays/dev'
            }
        }
        stage('Test') {
            steps {
                echo 'Test'
                sh 'kubectl get pods -n dev'
            }
        }
    }
}
