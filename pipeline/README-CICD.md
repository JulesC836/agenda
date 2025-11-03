# Pipeline CI/CD pour le Projet Agenda

Ce document explique comment configurer et utiliser le pipeline CI/CD pour le projet Agenda.

## Prérequis

- Un dépôt GitLab
- Un cluster Kubernetes configuré avec accès via `kubectl`
- Un registre Docker (comme GitLab Container Registry)
- Les variables d'environnement nécessaires configurées dans GitLab CI/CD

## Structure du pipeline

Le pipeline est divisé en 4 étapes principales :

1. **Test** : Exécution des tests unitaires et d'intégration
2. **Build** : Construction des images Docker pour le frontend et le backend
3. **Déploiement Dev** : Déploiement automatique sur l'environnement de développement
4. **Déploiement Prod** : Déploiement manuel sur l'environnement de production

## Configuration requise

### Variables d'environnement GitLab CI/CD

Les variables suivantes doivent être configurées dans les paramètres CI/CD de votre projet GitLab :

- `CI_REGISTRY` : URL du registre Docker
- `CI_REGISTRY_USER` : Nom d'utilisateur pour le registre
- `CI_REGISTRY_PASSWORD` : Mot de passe pour le registre
- `KUBE_CONFIG` : Configuration Kubernetes encodée en base64
- `MYSQL_ROOT_PASSWORD` : Mot de passe root MySQL pour les sauvegardes

### Configuration des environnements Kubernetes

Deux namespaces sont nécessaires :
- `agenda-dev` pour l'environnement de développement
- `agenda-prod` pour l'environnement de production

## Utilisation

### Déploiement manuel

Pour déployer manuellement une version spécifique :

```bash
# Pour l'environnement de développement
./scripts/deploy-k8s.sh agenda-dev v1.0.0 dev

# Pour l'environnement de production
./scripts/deploy-k8s.sh agenda-prod v1.0.0 prod
```

### Rollback

Pour revenir à une version précédente :

```bash
# Pour le backend
kubectl rollout undo deployment/backend -n agenda-dev

# Pour le frontend
kubectl rollout undo deployment/frontend -n agenda-dev
```

## Surveillance

Des sondes de vivacité (liveness) et de préparation (readiness) sont configurées pour les deux services. Les métriques sont disponibles via :

- Backend : `http://backend-service:8000/metrics`
- Frontend : `http://frontend-service:3000/metrics`

## Sécurité

- Les secrets sont gérés via les secrets Kubernetes et les variables d'environnement GitLab
- Les images sont scannées pour les vulnérabilités lors du build
- Les déploiements en production nécessitent une approbation manuelle

## Dépannage

### Vérifier l'état des pods

```bash
kubectl get pods -n agenda-dev
kubectl describe pod <pod-name> -n agenda-dev
kubectl logs <pod-name> -n agenda-dev
```

### Accéder à la base de données

```bash
kubectl run -it --rm --image=mysql:5.7 --restart=Never mysql-client -- mysql -h mysql-service -u root -p
```

## Maintenance

### Nettoyage

Pour nettoyer les ressources inutilisées :

```bash
# Supprimer les pods terminés
kubectl delete pod --field-selector=status.phase==Succeeded -n agenda-dev

# Nettoyer les images Docker
docker system prune -af
```
