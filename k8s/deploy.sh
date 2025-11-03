#!/bin/bash

# Build images
eval $(minikube -p minikube docker-env)  

docker build -t agenda-backend:latest ./backend

docker build -t agenda-frontend:latest ./frontend

eval $(minikube docker-env -u)  

# Apply Kubernetes manifests
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/mariadb.yaml
kubectl apply -f k8s/backend.yaml
kubectl apply -f k8s/frontend.yaml

# Wait for MariaDB to be ready
kubectl wait --for=condition=ready pod -l app=mariadb -n agenda --timeout=300s

# Wait for backend to be ready
kubectl wait --for=condition=available deployment/backend -n agenda --timeout=300s

# Run migrations
kubectl exec -n agenda deployment/backend -c backend -- php artisan migrate --force

echo "Déploiement terminé. Accès via: http://agenda.local"