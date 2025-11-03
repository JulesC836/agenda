#!/bin/bash

# Build images
docker build -t agenda-backend:latest ./backend
docker build -t agenda-frontend:latest ./frontend

# Apply Kubernetes manifests
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/mysql.yaml
kubectl apply -f k8s/backend.yaml
kubectl apply -f k8s/frontend.yaml

# Wait for MySQL to be ready
kubectl wait --for=condition=ready pod -l app=mysql -n agenda --timeout=300s

# Run migrations
kubectl exec -n agenda deployment/backend -- php artisan migrate --force

echo "Déploiement terminé. Accès via: http://agenda.local"