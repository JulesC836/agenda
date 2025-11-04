#!/bin/bash

echo "🚀 Déploiement de l'application Agenda sur Kubernetes"

# Build images

# minikube start --addons=ingress --addons=metrics-server
eval $(minikube -p minikube docker-env)  

docker build -t agenda-backend:latest ./backend
docker build -t agenda-frontend:latest ./frontend

eval $(minikube docker-env -u)  

# Apply Kubernetes manifests
echo "📋 Application des manifests Kubernetes..."
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/backend-secret.yaml --force # SECRET APPLIQUÉ EN PREMIER
kubectl apply -f k8s/mariadb.yaml
kubectl apply -f k8s/backend.yaml
kubectl apply -f k8s/frontend.yaml

# Wait for MariaDB to be ready
echo "⏳ Attente de MariaDB..."
kubectl wait --for=condition=ready pod -l app=mariadb -n agenda --timeout=300s

# Wait for backend to be ready
echo "⏳ Attente du backend..."
kubectl wait --for=condition=available deployment/backend -n agenda --timeout=300s

# Run migrations
echo "Attente de l'application des migrations"
# kubectl wait --for=condition=available pod -l app=mariadb -n agenda --timeout=300s

echo "🗄️ Exécution des migrations..."
kubectl exec -n agenda deployment/backend -c backend -- php artisan migrate --force

echo "✅ Déploiement terminé. Accès via: http://agenda.local"