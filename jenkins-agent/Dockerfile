FROM jenkins/inbound-agent:latest

USER root

# Instalar Docker y herramientas
RUN apt-get update && \
    apt-get install -y \
        docker.io \
        curl \
        && \
    curl -LO "https://dl.k8s.io/release/v1.27.0/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/ && \
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && \
    chmod +x minikube-linux-amd64 && \
    mv minikube-linux-amd64 /usr/local/bin/minikube

# Agregar jenkins al grupo docker
RUN usermod -aG docker jenkins

# Crear directorio para kubeconfig
RUN mkdir -p /home/jenkins/.kube

USER jenkins
