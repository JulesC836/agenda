# Docker & Kubernetes - Agenda

## Structure créée

```
agenda/
├── backend/Dockerfile
├── frontend/Dockerfile
├── frontend/nginx.conf
├── docker-compose.yml
└── k8s/
    ├── namespace.yaml
    ├── mysql.yaml
    ├── backend.yaml
    ├── frontend.yaml
    └── deploy.sh
```

## Développement local (Docker Compose)

```bash
# Démarrer tous les services
docker-compose up --build

# Accès:
# Frontend: http://localhost:4200
# Backend: http://localhost:8000
# MySQL: localhost:3306
```

## Production (Kubernetes)

### Prérequis
- Cluster Kubernetes
- kubectl configuré
- Ingress Controller installé

### Déploiement
```bash
# Déploiement automatique
./k8s/deploy.sh

# Ou manuel:
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/mysql.yaml
kubectl apply -f k8s/backend.yaml
kubectl apply -f k8s/frontend.yaml
```

### Accès
Ajouter à `/etc/hosts`:
```
<CLUSTER_IP> agenda.local
```

Accès: http://agenda.local

## Services Kubernetes

- **MySQL**: Base de données avec PVC 1Gi
- **Backend**: 2 replicas Laravel (port 8000)
- **Frontend**: 2 replicas Angular/Nginx (port 80)
- **Ingress**: Routage `/` → frontend, `/api` → backend

## Commandes utiles

```bash
# Voir les pods
kubectl get pods -n agenda

# Logs backend
kubectl logs -f deployment/backend -n agenda

# Accès MySQL
kubectl exec -it deployment/mysql -n agenda -- mysql -u root -p agenda

# Supprimer le déploiement
kubectl delete namespace agenda
```