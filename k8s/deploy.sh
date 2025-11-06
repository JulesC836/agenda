#!/bin/bash

echo "🚀 Déploiement de l'application Agenda sur Kubernetes"

# Build images

# minikube start --addons=ingress --addons=metrics-server
eval $(minikube -p minikube docker-env)  

docker build -t agenda-backend:latest ./backend
docker build -t agenda-frontend:latest ./frontend

eval $(minikube docker-env -u)  

# Apply Kubernetes manifests
# --- NETTOYAGE/MISE À JOUR CRITIQUE POUR MARIADB (SUPPRESSION DES IMMUABLES) ---
echo "🧹 Suppression des ressources MariaDB pour permettre la mise à jour des champs immuables..."
# Supprime le StatefulSet et le PVC s'ils existent (ignore les erreurs si non trouvés)
kubectl delete sts mariadb -n agenda --ignore-not-found=true
# ATTENTION: Supprimer le PVC supprime la liaison, mais les données devraient persister sur Minikube
kubectl delete pvc mariadb-pvc -n agenda --ignore-not-found=true
# 
echo "📋 Application des manifests Kubernetes..."
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/mariadb.yaml
kubectl apply -f k8s/backend-secret.yaml --force # SECRET APPLIQUÉ EN PREMIER
kubectl apply -f k8s/backend.yaml
kubectl apply -f k8s/frontend.yaml

# Wait for MariaDB to be ready
echo "⏳ Attente de MariaDB..."
kubectl wait --for=condition=ready pod -l app=mariadb -n agenda --timeout=300s

# Wait for backend to be ready
echo "⏳ Attente du backend..."
kubectl wait --for=condition=available deployment/backend -n agenda --timeout=300s

# Run migrations

echo "🗄️ Exécution des migrations..."
kubectl exec -n agenda deployment/backend -c backend -- php artisan migrate --force
kubectl exec -n agenda deployment/backend -c backend -- php artisan key:generate --force
kubectl exec -n agenda deployment/backend -c backend -- php artisan jwt:secret
kubectl exec -n agenda deployment/backend -c backend -- composer dump-autoload --no-dev --optimize

echo "✅ Déploiement terminé. Accès via: http://agenda.local"