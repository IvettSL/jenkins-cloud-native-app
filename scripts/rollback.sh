#!/bin/bash
set -e

# Script de rollback
ENVIRONMENT=${1:-dev}
APP_NAME="jenkins-cloud-native-app"
NAMESPACE=${ENVIRONMENT}

echo "🔄 Iniciando rollback de $APP_NAME en $ENVIRONMENT"

# Verificar que kubectl esté configurado
if ! kubectl cluster-info &>/dev/null; then
    echo "❌ kubectl no está configurado correctamente"
    exit 1
fi

# Realizar rollback del deployment
echo "⏪ Realizando rollback del deployment..."
kubectl rollout undo deployment/$APP_NAME -n $NAMESPACE

# Esperar a que el rollback esté completo
echo "⏳ Esperando a que el rollback esté completo..."
kubectl rollout status deployment/$APP_NAME -n $NAMESPACE --timeout=300s

# Verificar estado
echo "📊 Estado después del rollback:"
kubectl get pods -n $NAMESPACE

echo "✅ Rollback completado exitosamente"