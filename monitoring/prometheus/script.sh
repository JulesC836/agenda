#!/bin/bash

set -e

echo "🔍 Déploiement du monitoring Prometheus pour Agenda"
# Vérifications
if ! command -v kubectl &> /dev/null; then
    echo "ERREUR: kubectl requis"
    exit 1
fi

# Déploiement
echo "🚀 Déploiement des manifests..."
kubectl apply -f monitoring/prometheus/prometheus-config.yaml
kubectl apply -f monitoring/prometheus/prometheus.yaml
kubectl apply -f monitoring/prometheus/monitoring.yaml

# Attendre Prometheus
echo "⏳ Attente de Prometheus..."
kubectl wait --for=condition=available deployment/prometheus -n agenda --timeout=300s

# Statut
echo "📋 Statut des pods:"
kubectl get pods -n agenda -l app=prometheus

# Accès
echo ""
echo "✅ Monitoring déployé avec succès!"
echo "📊 Accès Prometheus: http://prometheus.local"
echo "🎯 Targets: http://prometheus.local/targets"
echo ""
echo "Port-forward local:"
kubectl port-forward -n agenda svc/prometheus-service 9090:9090
echo "Puis: http://localhost:9090"