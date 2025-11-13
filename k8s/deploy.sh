#!/bin/bash

set -e  # Arrête le script en cas d'erreur

echo "🚀 Déploiement de l'application Agenda sur Kubernetes"

# Démarrage de Minikube avec les addons nécessaires
echo "🔧 Démarrage de Minikube..."
minikube start --addons=ingress --addons=metrics-server

# Configuration de l'environnement Docker de Minikube
echo "🐳 Configuration de l'environnement Docker..."
eval $(minikube -p minikube docker-env)

# Construction des images Docker
echo "🏗️  Construction de l'image Backend..."
docker build -t agenda-backend:latest ./backend

echo "🏗️  Construction de l'image Frontend..."
docker build -t agenda-frontend:latest ./frontend

# Réinitialisation de l'environnement Docker
eval $(minikube docker-env -u)

# --- NETTOYAGE/MISE À JOUR CRITIQUE POUR MARIADB ---
echo "🧹 Suppression des ressources MariaDB pour permettre la mise à jour..."
kubectl delete sts mariadb -n agenda --ignore-not-found=true
kubectl delete pvc mariadb-pvc -n agenda --ignore-not-found=true

# Application des manifests Kubernetes
echo "📋 Application des manifests Kubernetes..."
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/mariadb.yaml
kubectl apply -f k8s/backend-secret.yaml
kubectl apply -f k8s/backend.yaml
kubectl apply -f k8s/frontend.yaml

# Attente de MariaDB
echo "⏳ Attente de MariaDB..."
kubectl wait --for=condition=ready pod -l app=mariadb -n agenda --timeout=300s

# Pause pour laisser MariaDB initialiser complètement
echo "⏸️  Pause de 10s pour l'initialisation de MariaDB..."
sleep 10

# Attente du backend
echo "⏳ Attente du backend..."
kubectl wait --for=condition=available deployment/backend -n agenda --timeout=300s

# Exécution des migrations et setup Laravel
echo "🗄️  Configuration de Laravel..."

# Génération de la clé JWT
echo "🔑 Génération de la clé JWT..."
kubectl exec -n agenda deployment/backend -c backend -- php artisan jwt:secret --force || echo "⚠️  JWT secret déjà configuré ou erreur"

# Optimisation de l'autoloader
echo "⚙️  Optimisation de l'autoloader..."
# kubectl exec -n agenda deployment/backend -c backend -- composer dump-autoload --optimize

# Exécution des migrations
echo "🗄️  Exécution des migrations de base de données..."
kubectl exec -n agenda deployment/backend -c backend -- php artisan migrate --force

# Vérification de l'état
echo "✅ Vérification de l'état des pods..."
kubectl get pods -n agenda

# Configuration du port-forwarding
echo "🌐 Configuration du port-forwarding..."
echo "   Arrêt des anciens processus de port-forward..."
pkill -f "kubectl port-forward" || true

echo "   Démarrage du port-forward pour le backend (port 8000)..."
kubectl port-forward svc/backend-service 8000:8000 -n agenda &
BACKEND_PF_PID=$!

echo "   Démarrage du port-forward pour le frontend (port 4200)..."
kubectl port-forward svc/frontend-service 4200:80 -n agenda &
FRONTEND_PF_PID=$!

# Pause pour laisser les port-forwards s'établir
sleep 3

echo ""
echo "✅ Déploiement terminé avec succès!"
echo ""
echo "📡 Services disponibles:"
echo "   Frontend: http://localhost:4200"
echo "   Backend API: http://localhost:8000"
echo "   Backend Health: http://localhost:8000/api/health (si configuré)"
echo ""
echo "🔍 Commandes utiles:"
echo "   Logs backend: kubectl logs -f -n agenda deployment/backend"
echo "   Logs frontend: kubectl logs -f -n agenda deployment/frontend"
echo "   Logs MariaDB: kubectl logs -f -n agenda statefulset/mariadb"
echo "   État des pods: kubectl get pods -n agenda"
echo ""
echo "🛑 Pour arrêter les port-forwards:"
echo "   kill $BACKEND_PF_PID $FRONTEND_PF_PID"