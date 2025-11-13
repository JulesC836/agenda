#!/bin/bash

# helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring \
#   --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
#   --set grafana.adminPassword=admin123 \
#   --set grafana.service.type=NodePort \
#   --set prometheus.service.type=NodePort

kubectl apply -f servicemonitor.yaml -n monitoring
kubectl apply -f prometheus-config.yaml -n monitoring
kubectl apply -f grafana-dashboard.yaml -n monitoring

# Installer le dashboard Kubernetes
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

# Créer un utilisateur admin
kubectl create serviceaccount dashboard-admin -n kubernetes-dashboard
kubectl create clusterrolebinding dashboard-admin --clusterrole=cluster-admin --serviceaccount=kubernetes-dashboard:dashboard-admin

echo "
🚀 Monitoring déployé avec succès !
    Acces au service backend :
    kubectl port-forward -n agenda svc/backend-service 8000:8000


    Acces au service frontend :
    kubectl port-forward -n agenda svc/frontend-service 4200:80

    Acces au tableau de bord Prometheus :
    kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-prometheus 9090:9090

    Accès au tableau de bord Grafana :
    kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80
"