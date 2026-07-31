#!/bin/bash
set -e

# Script de despliegue
ENVIRONMENT=${1:-dev}
APP_NAME="jenkins-cloud-native-app"
NAMESPACE=${ENVIRONMENT}

echo "🚀 Desplegando $APP_NAME en $ENVIRONMENT"

# Verificar que kubectl esté configurado
if ! kubectl cluster-info &>/dev/null; then
    echo "❌ kubectl no está configurado correctamente"
    exit 1
fi

# Crear namespace si no existe
echo "📁 Creando namespace $NAMESPACE"
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Aplicar configuraciones usando kustomize
echo "📦 Aplicando configuración de Kubernetes"
kubectl apply -k kubernetes/overlays/$ENVIRONMENT

# Esperar a que los pods estén listos
echo "⏳ Esperando a que los pods estén listos..."
kubectl wait --for=condition=ready pod -l app=$APP_NAME -n $NAMESPACE --timeout=300s

# Verificar estado
echo "📊 Estado de los pods:"
kubectl get pods -n $NAMESPACE

echo "✅ Despliegue completado exitosamente"