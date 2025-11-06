# Application Agenda - Guide d'Installation

## Prérequis

### Développement Local
- **PHP** >= 8.2
- **Composer** >= 2.0
- **Node.js** >= 18.0
- **npm** >= 9.0
- **MySQL** >= 8.0 ou **SQLite**

### Docker/Kubernetes
- **Docker** >= 20.0
- **Docker Compose** >= 2.0
- **Kubernetes** >= 1.20 (optionnel)

## Installation Backend (Laravel)

### 1. Installation des dépendances
```bash
cd backend
composer install
```

### 2. Configuration de l'environnement
```bash
cp .env.example .env
php artisan key:generate
```

### 3. Configuration de la base de données
Éditer le fichier `.env` :
```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=angenda
DB_USERNAME=root
DB_PASSWORD=
```

### 4. Configuration JWT
```bash
php artisan jwt:secret
```

### 5. Migration de la base de données
```bash
php artisan migrate
```

### 6. Démarrage du serveur
```bash
php artisan serve
```
Le backend sera accessible sur `http://localhost:8000`

## Installation Frontend (Angular)

### 1. Installation des dépendances
```bash
cd frontend
npm install
```

### 2. Configuration de l'environnement
Vérifier le fichier `src/environments/environment.ts` :
```typescript
export const environment = {
  production: false,
  apiUrl: 'http://localhost:8000/api'
};
```

### 3. Démarrage du serveur de développement
```bash
ng serve
```
Le frontend sera accessible sur `http://localhost:4200`

## Installation Docker (Recommandée)

### Développement rapide
```bash
# Démarrer tous les services
docker-compose up --build

# Accès:
# Frontend: http://localhost:4200
# Backend: http://localhost:8000
# MySQL: localhost:3306
```

### Production Kubernetes
```bash
# Déploiement automatique
./k8s/deploy.sh

# Accès via Ingress
echo "127.0.0.1 agenda.local" >> /etc/hosts
# http://agenda.local
```

## Structure du Projet

```
angenda/
├── backend/           # API Laravel
│   ├── app/
│   ├── database/
│   ├── routes/
│   └── Dockerfile
├── frontend/          # Application Angular
│   ├── src/
│   ├── angular.json
│   ├── Dockerfile
│   └── nginx.conf
├── k8s/              # Manifests Kubernetes
│   ├── namespace.yaml
│   ├── mysql.yaml
│   ├── backend.yaml
│   ├── frontend.yaml
│   └── deploy.sh
├── docker-compose.yml
├── README.md
└── Architecture.md
```

## Fonctionnalités

- ✅ **Authentification** : Inscription/Connexion avec JWT
- ✅ **Calendrier** : Vue mensuelle interactive
- ✅ **Événements** : CRUD complet (Créer, Lire, Modifier, Supprimer)
- ✅ **Vue par jour** : Liste détaillée des événements
- ✅ **Couleurs** : Personnalisation visuelle des événements
- ✅ **Rappels email** : Notifications automatiques (15min à 1 jour)
- ✅ **Responsive** : Interface adaptée mobile/desktop
- ✅ **Containerisation** : Docker & Kubernetes ready

## API Endpoints

### Authentification
- `POST /api/auth/register` - Inscription
- `POST /api/auth/login` - Connexion
- `POST /api/auth/logout` - Déconnexion
- `GET /api/auth/me` - Profil utilisateur

### Événements
- `GET /api/events` - Liste des événements
- `GET /api/events/day/{date}` - Événements d'un jour
- `POST /api/events` - Créer un événement
- `PUT /api/events/{id}` - Modifier un événement
- `DELETE /api/events/{id}` - Supprimer un événement

## Technologies Utilisées

### Backends
- **Laravel 11** - Framework PHP
- **JWT Auth** - Authentification
- **MySQL/SQLite** - Base de données
- **Repository Pattern** - Architecture

### Frontend
- **Angular 18** - Framework JavaScript
- **TypeScript** - Langage
- **RxJS** - Programmation réactive
- **CSS3** - Styles modernes

## Dépannage

### Erreur CORS
Ajouter dans `config/cors.php` :
```php
'paths' => ['api/*'],
'allowed_origins' => ['http://localhost:4200'],
```

### Erreur JWT
Régénérer la clé JWT :
```bash
php artisan jwt:secret --force
```

### Erreur de base de données
Vérifier la connexion et recréer la base :
```bash
php artisan migrate:fresh
```

### Erreur Angular
Nettoyer et réinstaller :
```bash
rm -rf node_modules package-lock.json
npm install
```

## Rappels Email

### Configuration
```bash
# Démarrer les queues
php artisan queue:work &

# Programmer les rappels (crontab)
* * * * * cd /path/to/agenda/backend && php artisan schedule:run
```

### Configuration SMTP (optionnel)
Dans `.env` :
```env
MAIL_MAILER=smtp
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=votre-email@gmail.com
MAIL_PASSWORD=votre-mot-de-passe-app
MAIL_ENCRYPTION=tls
```

## Développement

### Backend
```bash
# Tests
php artisan test

# Cache
php artisan config:clear
php artisan cache:clear

# Autoload
composer dump-autoload
```

### Frontend
```bash
# Build production
ng build --prod

# Tests
ng test

# Linting
ng lint
```

## Documentation

- [Architecture.md](Architecture.md) - Architecture détaillée
- [RAPPELS_EMAIL.md](RAPPELS_EMAIL.md) - Fonctionnalité rappels
- [DOCKER_K8S.md](DOCKER_K8S.md) - Containerisation


🚀 Pipeline CI/CD
Logique du Pipeline

Le pipeline CI/CD est déclenché automatiquement sur GitHub Actions et exécute les étapes suivantes :
Étapes du Pipeline:
  1. Déclenchement:
     - Sur push vers les branches 'main' ou 'develop'
     - Sur création de Pull Request
     - Manuellement via l'interface GitHub

  2. Validation du Code:
     - Linting PHP (PHP CS Fixer)
     - Linting TypeScript (ESLint)
     - Validation des syntaxes YAML/Dockerfile

  3. Construction des Images:
     - Build Frontend (Angular + Nginx)
     - Build Backend (Laravel + PHP-FPM)
     - Build Database (MySQL avec données d'initialisation)
     - Scan de sécurité des images avec Trivy

  4. Tests Automatisés:
     - Tests unitaires Backend (PHPUnit)
     - Tests unitaires Frontend (Jasmine/Karma)
     - Tests d'intégration avec Docker Compose
     - Tests E2E optionnels

  5. Déploiement:
     - Environnement PREVIEW pour les PR:
       • Namespace Kubernetes dédié
       • URL unique: pr-{num}.agenda-preview.example.com
       • Suppression auto après merge/close
     
     - Environnement PRODUCTION pour main:
       • Déploiement blue/green
       • Tests de smoke post-déploiement
       • Rollback automatique en cas d'échec

  6. Monitoring:
     - Notification Slack/Sur les statuts
     - Métriques de performance
     - Logs centralisés

     Commandes Principales
Construction des Images Docker
# Build des trois services
docker build -t agenda-frontend:latest -f docker/frontend.Dockerfile ./frontend
docker build -t agenda-backend:latest -f docker/backend.Dockerfile ./backend  
docker build -t agenda-mysql:latest -f docker/mysql.Dockerfile .

# Tag et push vers le registry
docker tag agenda-frontend:latest ghcr.io/votre-org/agenda-frontend:${GIT_SHA}
docker tag agenda-backend:latest ghcr.io/votre-org/agenda-backend:${GIT_SHA}
docker push ghcr.io/votre-org/agenda-frontend:${GIT_SHA}

# Tests Backend
cd backend && composer test
php artisan test --parallel

# Tests Frontend  
cd frontend && npm test
npm run e2e

# Tests d'intégration
docker-compose -f docker-compose.test.yml up --abort-on-container-exit
docker-compose -f docker-compose.test.yml down


Déploiement Kubernetes

# Appliquer la configuration de base
kubectl apply -f k8s/namespace.yaml

# Déployer les services dans l'ordre
kubectl apply -f k8s/storage/mysql-pvc.yaml
kubectl apply -f k8s/databases/mysql.yaml
kubectl apply -f k8s/configs/backend-config.yaml
kubectl apply -f k8s/services/backend.yaml
kubectl apply -f k8s/services/frontend.yaml
kubectl apply -f k8s/networking/ingress.yaml

# Vérification du déploiement
kubectl -n agenda get all
kubectl -n agenda get ingress
kubectl -n agenda logs deployment/backend-deployment

Commandes de Debug et Maintenance
# Accès aux pods
kubectl -n agenda get pods
kubectl -n agenda exec -it frontend-pod -- /bin/sh

# Logs en temps réel
kubectl -n agenda logs -f deployment/backend-deployment
kubectl -n agenda logs -f deployment/frontend-deployment

# Scale des services
kubectl -n agenda scale deployment/backend-deployment --replicas=3
kubectl -n agenda scale deployment/frontend-deployment --replicas=2

# Rollback manuel
kubectl -n agenda rollout undo deployment/backend-deployment
kubectl -n agenda rollout undo deployment/frontend-deployment

Utilitaires de Développement
# Port-forward pour accès local
kubectl -n agenda port-forward service/backend-service 8000:8000
kubectl -n agenda port-forward service/frontend-service 4200:80

# Inspection des configurations
kubectl -n agenda describe deployment/backend-deployment
kubectl -n agenda get configmap/backend-config -o yaml

# Nettoyage des environnements preview
kubectl delete namespace agenda-preview-123


🧪 Commandes de Test des Conteneurs
Docker Compose (Développement)
# Vérifier que les conteneurs tournent
docker-compose ps

# Voir les logs
docker-compose logs -f frontend
docker-compose logs -f backend
docker-compose logs -f mysql

# Tester l'accessibilité
curl http://localhost:4200
curl http://localhost:8000/api/events

# Tester la BDD
docker-compose exec mysql mysql -u user -pmd_pass -e "SHOW DATABASES;"

# Accès shell dans les conteneurs
docker-compose exec backend /bin/sh
docker-compose exec frontend /bin/sh