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

### Backend
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