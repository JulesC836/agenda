# Agenda - Application de Calendrier

## 🚀 Démarrage Rapide

### Docker (Recommandé)
```bash
docker-compose up --build
# Frontend: http://localhost:4200
# Backend: http://localhost:8000
```

### Kubernetes
```bash
./k8s/deploy.sh
# Accès: http://agenda.local
```

## 📋 Prérequis

- **Docker** >= 20.0
- **Docker Compose** >= 2.0
- **Kubernetes** >= 1.20 (production)

## 🏗️ Développement Local

### Backend (Laravel)
```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate
php artisan jwt:secret
php artisan migrate
php artisan serve
```

### Frontend (Angular)
```bash
cd frontend
pnpm install
ng serve
```

## 📋 Structure

```
agenda/
├── backend/          # Laravel API
├── frontend/         # Angular App
├── k8s/              # Kubernetes
└── docker-compose.yml
```

## ✨ Fonctionnalités

- 🔐 Authentification JWT
- 📅 Calendrier interactif
- ➕ CRUD événements
- 🎨 Couleurs personnalisées
- 📧 Rappels email
- 📱 Interface responsive
- 🚀 Docker & Kubernetes

## 🔧 Technologies

- **Backend**: Laravel 11 + JWT + MariaDB
- **Frontend**: Angular 18 + TypeScript
- **Infrastructure**: Docker + Kubernetes

## 🔧 Commandes Utiles

```bash
# Tests
php artisan test
pnpm test

# Build production
./build.sh

# Dépannage
php artisan migrate:fresh
php artisan jwt:secret --force
```

## 📚 Documentation

- [Architecture.md](Architecture.md) - Architecture technique
- [DOCKER_K8S.md](DOCKER_K8S.md) - Déploiement