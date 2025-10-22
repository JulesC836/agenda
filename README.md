# Application Agenda - Guide d'Installation

## Prérequis

- **PHP** >= 8.2
- **Composer** >= 2.0
- **Node.js** >= 18.0
- **npm** >= 9.0
- **MySQL** >= 8.0 ou **SQLite**

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

## Structure du Projet

```
angenda/
├── backend/           # API Laravel
│   ├── app/
│   ├── database/
│   └── routes/
├── frontend/          # Application Angular
│   ├── src/
│   └── angular.json
└── README.md
```

## Fonctionnalités

- ✅ **Authentification** : Inscription/Connexion avec JWT
- ✅ **Calendrier** : Vue mensuelle interactive
- ✅ **Événements** : CRUD complet (Créer, Lire, Modifier, Supprimer)
- ✅ **Vue par jour** : Liste détaillée des événements
- ✅ **Couleurs** : Personnalisation visuelle des événements
- ✅ **Responsive** : Interface adaptée mobile/desktop

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

## Architecture

Voir le fichier [Architecture.md](Architecture.md) pour une vue détaillée de l'architecture du projet.