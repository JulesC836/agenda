#!/bin/bash
set -e

# Configuration
NAMESPACE=$1
IMAGE_TAG=$2
ENV=$3

if [ -z "$NAMESPACE" ] || [ -z "$IMAGE_TAG" ] || [ -z "$ENV" ]; then
  echo "Usage: $0 <namespace> <image-tag> <environment>"
  exit 1
fi

# Création du namespace s'il n'existe pas
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Définition des images
BACKEND_IMAGE="${CI_REGISTRY_IMAGE}/backend:${IMAGE_TAG}"
FRONTEND_IMAGE="${CI_REGISTRY_IMAGE}/frontend:${IMAGE_TAG}"

# Application des configurations de base
# Appliquer la configuration du namespace
kubectl apply -f ../config/namespace-${ENV}.yaml

# Appliquer la configuration de la base de données
kubectl apply -f ../../k8s/mysql.yaml -n $NAMESPACE

# Configuration spécifique à l'environnement
case $ENV in
  dev)
    REPLICAS=1
    RESOURCES="--limits=cpu=500m,memory=512Mi --requests=cpu=100m,memory=256Mi"
    ;;
  prod)
    REPLICAS=3
    RESOURCES="--limits=cpu=2000m,memory=2Gi --requests=cpu=500m,memory=1Gi"
    # Sauvegarde de la base de données avant mise à jour
    kubectl exec -n $NAMESPACE -it $(kubectl get pods -n $NAMESPACE -l app=mysql -o jsonpath='{.items[0].metadata.name}') -- mysqldump -u root -p"$MYSQL_ROOT_PASSWORD" agenda > backup_$(date +%Y%m%d%H%M%S).sql
    ;;
  *)
    echo "Environnement inconnu: $ENV"
    exit 1
    ;;
esac

# Mise à jour des déploiements avec les bonnes images et ressources
# Backend
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: $NAMESPACE
spec:
  replicas: $REPLICAS
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: backend
        image: $BACKEND_IMAGE
        ports:
        - containerPort: 8000
        resources:
          limits:
            cpu: "1"
            memory: "1Gi"
          requests:
            cpu: "200m"
            memory: "512Mi"
        envFrom:
        - configMapRef:
            name: backend-config
        livenessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: backend-service
  namespace: $NAMESPACE
spec:
  selector:
    app: backend
  ports:
  - port: 80
    targetPort: 8000
  type: ClusterIP
EOF

# Frontend
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: $NAMESPACE
spec:
  replicas: $REPLICAS
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: frontend
        image: $FRONTEND_IMAGE
        ports:
        - containerPort: 3000
        resources:
          limits:
            cpu: "500m"
            memory: "512Mi"
          requests:
            cpu: "100m"
            memory: "256Mi"
        livenessProbe:
          httpGet:
            path: /
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: frontend-service
  namespace: $NAMESPACE
spec:
  selector:
    app: frontend
  ports:
  - port: 80
    targetPort: 3000
  type: LoadBalancer
EOF

# Si c'est un déploiement en production, on applique aussi les ressources de monitoring
if [ "$ENV" = "prod" ]; then
  kubectl apply -f ../../monitoring/ -n $NAMESPACE
fi

echo "Déploiement terminé avec succès dans l'environnement $ENV"
echo "Backend: $BACKEND_IMAGE"
echo "Frontend: $FRONTEND_IMAGE"
echo "Nombre de répliques: $REPLICAS"
