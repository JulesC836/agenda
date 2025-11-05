# Docker & Kubernetes

## 🚀 Démarrage Rapide

```bash
# Local
docker-compose up --build

# Production
./k8s/deploy.sh
```

## 📍 Accès

- **Local**: http://localhost:4200
- **K8s**: http://agenda.local

## 🔧 Commandes

```bash
# Monitoring
kubectl get pods -n agenda
kubectl logs -f deployment/backend -n agenda

# Cleanup
kubectl delete namespace agenda
```