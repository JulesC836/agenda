# Docker & CI/CD - Configuration Optimisée

## 🏗️ Images Docker Optimisées

### Backend (Laravel)
- **Multi-stage build** pour réduire la taille de l'image
- **Utilisateur non-root** pour la sécurité
- **Cache des dépendances** Composer optimisé
- **Extensions PHP** minimales requises

### Frontend (Angular)
- **Build de production** avec Angular CLI
- **Nginx Alpine** pour servir les fichiers statiques
- **Utilisateur non-root** pour la sécurité
- **Optimisation des assets** automatique

## 🚀 Scripts de Build

### Construction rapide
```bash
# Construction avec tag par défaut (latest)
./build.sh

# Construction avec tag personnalisé
./build.sh v1.0.0
```

### Déploiement Kubernetes
```bash
cd k8s
./deploy.sh
```

## 🔧 CI/CD Pipeline

### Étapes automatisées
1. **Tests** - Backend (PHPUnit) et Frontend (Jest)
2. **Build Docker** - Images optimisées multi-stage
3. **Scan sécurité** - Trivy pour les vulnérabilités
4. **Déploiement K8s** - Validation et déploiement automatique

### Configuration GitHub Actions
- **PHP 8.2** avec extensions requises
- **Node.js 20** avec pnpm
- **Docker Buildx** pour builds multi-plateforme
- **kubectl** pour déploiement Kubernetes

## 📦 Docker Compose

### Développement local
```bash
# Démarrage complet
docker-compose up --build

# Services individuels
docker-compose up mariadb
docker-compose up backend
docker-compose up frontend
```

### Accès aux services
- **Frontend**: http://localhost:4200
- **Backend API**: http://localhost:8000/api
- **MariaDB**: localhost:3306

## 🔒 Sécurité

### Images Docker
- Utilisateurs non-root dans tous les conteneurs
- Images Alpine Linux quand possible
- Scan automatique des vulnérabilités avec Trivy
- Secrets gérés via variables d'environnement

### Kubernetes
- Namespace dédié `agenda`
- NetworkPolicies pour l'isolation
- ResourceLimits pour éviter les abus
- Secrets K8s pour les données sensibles

## 🎯 Optimisations

### Build
- Cache Docker layers optimisé
- .dockerignore pour exclure les fichiers inutiles
- Multi-stage builds pour réduire la taille
- Parallélisation des builds frontend/backend

### Runtime
- Healthchecks pour tous les services
- Graceful shutdown des conteneurs
- Logs structurés pour le monitoring
- Métriques Prometheus ready

## 🛠️ Développement

### Variables d'environnement
```env
# Backend
DB_HOST=mariadb
DB_DATABASE=agenda
DB_USERNAME=user
DB_PASSWORD=md_pass

# Frontend
API_URL=http://backend:8000/api
```

### Debugging
```bash
# Logs des conteneurs
docker-compose logs -f backend
docker-compose logs -f frontend

# Accès shell
docker-compose exec backend bash
docker-compose exec frontend sh
```

## 📊 Monitoring

### Métriques disponibles
- Temps de réponse API
- Utilisation mémoire/CPU
- Erreurs applicatives
- Connexions base de données

### Logs centralisés
- Format JSON structuré
- Corrélation des requêtes
- Niveaux de log configurables
- Rotation automatique