#!/bin/bash
set -e

# Script de monitoreo
ENVIRONMENT=${1:-dev}
APP_NAME="jenkins-cloud-native-app"
NAMESPACE=${ENVIRONMENT}
PROMETHEUS_URL=${PROMETHEUS_URL:-"http://prometheus.monitoring.svc.cluster.local:9090"}

echo "📊 Iniciando monitoreo de $APP_NAME en $ENVIRONMENT"

# Función para verificar métricas
check_metric() {
    local metric_name=$1
    local threshold=$2
    local query=$3
    
    echo "Verificando $metric_name..."
    local value=$(curl -s -G $PROMETHEUS_URL/api/v1/query \
        --data-urlencode "query=$query" | jq -r '.data.result[0].value[1] // 0')
    
    if (( $(echo "$value > $threshold" | bc -l 2>/dev/null || echo "0") )); then
        echo "⚠️ ALERTA: $metric_name = $value (umbral: $threshold)"
        return 1
    else
        echo "✅ $metric_name = $value"
        return 0
    fi
}

# Verificar métricas críticas
echo "🔍 Verificando métricas de rendimiento..."

# CPU Usage
check_metric "CPU Usage" 80 "avg(rate(container_cpu_usage_seconds_total{namespace=\"$NAMESPACE\"}[5m])) * 100"

# Memory Usage
check_metric "Memory Usage" 85 "avg(container_memory_usage_bytes{namespace=\"$NAMESPACE\"} / container_spec_memory_limit_bytes) * 100"

# Pod status
echo "📊 Verificando estado de los pods..."
kubectl get pods -n $NAMESPACE

# Service health
echo "🔍 Verificando health de servicios..."
for pod in $(kubectl get pods -n $NAMESPACE -l app=$APP_NAME -o name); do
    echo "Verificando $pod..."
    kubectl exec -n $NAMESPACE $pod -- curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/health || echo "❌ Health check falló"
done

echo "📈 Generando informe de recursos..."
kubectl top pods -n $NAMESPACE 2>/dev/null || echo "⚠️ metrics-server no disponible"

echo "✅ Monitoreo completado"