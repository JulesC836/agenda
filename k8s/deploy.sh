#!/bin/bash

set -e

echo "🚀 Déploiement de l'application Agenda sur Kubernetes"

# Build images
eval $(minikube -p minikube docker-env)  

docker build -t agenda-backend:latest ./backend
docker build -t agenda-frontend:latest ./frontend

eval $(minikube docker-env -u)  

# Apply Kubernetes manifests
echo "📋 Application des manifests Kubernetes..."
kubectl apply -f namespace.yaml
kubectl apply -f mariadb.yaml
kubectl apply -f backend.yaml
kubectl apply -f frontend.yaml

# Wait for MariaDB to be ready
echo "⏳ Attente de MariaDB..."
kubectl wait --for=condition=ready pod -l app=mariadb -n agenda --timeout=300s

# Wait for backend to be ready
echo "⏳ Attente du backend..."
kubectl wait --for=condition=available deployment/backend -n agenda --timeout=300s

# Run migrations
echo "🗄️ Exécution des migrations..."
kubectl exec -n agenda deployment/backend -c backend -- php artisan migrate --force

echo "✅ Déploiement terminé. Accès via: http://agenda.local"