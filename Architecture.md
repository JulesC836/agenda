# Architecture de l'Application Agenda

## Vue d'ensemble

### Architecture Locale
```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              FRONTEND (Angular)                             │
│                            http://localhost:4200                            │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                 HTTP/REST API
                                      │
┌─────────────────────────────────────────────────────────────────────────────┐
│                              BACKEND (Laravel)                              │
│                            http://localhost:8000                            │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                   Database
                                      │
┌─────────────────────────────────────────────────────────────────────────────┐
│                                MySQL/SQLite                                 │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Architecture Kubernetes
```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                INGRESS                                      │
│                          http://agenda.local                               │
└─────────────────────────────────────────────────────────────────────────────┘
                    │                              │
               / (Frontend)                   /api (Backend)
                    │                              │
┌─────────────────────────────────┐    ┌─────────────────────────────────┐
│        Frontend Service         │    │        Backend Service          │
│         (Port 80)               │    │         (Port 8000)             │
└─────────────────────────────────┘    └─────────────────────────────────┘
                    │                              │
┌─────────────────────────────────┐    ┌─────────────────────────────────┐
│     Frontend Deployment         │    │     Backend Deployment          │
│       (2 replicas)              │    │       (2 replicas)              │
└─────────────────────────────────┘    └─────────────────────────────────┘
                                                   │
                                       ┌─────────────────────────────────┐
                                       │        MySQL Service            │
                                       │         (Port 3306)             │
                                       └─────────────────────────────────┘
                                                   │
                                       ┌─────────────────────────────────┐
                                       │      MySQL Deployment           │
                                       │    + PersistentVolume           │
                                       └─────────────────────────────────┘
```

## Architecture Frontend (Angular)

```
src/app/
├── components/
│   ├── auth/
│   │   ├── login.component.*           # Connexion utilisateur
│   │   └── register.component.*        # Inscription utilisateur
│   ├── calendar/
│   │   └── calendar.component.*        # Vue calendrier principal
│   ├── day-events/
│   │   └── day-events.component.*      # Modale événements du jour
│   └── event/
│       └── event-form.component.*      # Formulaire CRUD événements
├── services/
│   ├── auth.service.ts                 # Gestion authentification
│   └── event.service.ts                # API événements
├── guards/
│   └── auth.guard.ts                   # Protection routes
├── interceptors/
│   └── auth.interceptor.ts             # Injection token JWT
├── models/
│   ├── event.model.ts                  # Interface Event
│   └── user.model.ts                   # Interface User
└── app.routes.ts                       # Configuration routes
```

## Architecture Backend (Laravel)

```
app/
├── Http/
│   ├── Controllers/
│   │   ├── AuthController.php          # Authentification JWT + UserRepository
│   │   └── EventController.php         # CRUD événements + EventRepository
│   ├── Requests/
│   │   ├── EventRequest.php            # Validation événements + rappels
│   │   ├── LoginRequest.php            # Validation connexion
│   │   └── RegisterRequest.php         # Validation inscription
│   ├── Resources/
│   │   └── EventResource.php           # Formatage JSON
│   └── Middleware/
│       └── auth:api                    # Vérification JWT
├── Jobs/
│   └── SendEventReminderJob.php        # Job envoi emails rappels
├── Console/
│   ├── Commands/
│   │   └── SendEventReminders.php      # Command traitement rappels
│   └── Kernel.php                      # Programmation tâches
├── Repositories/
│   ├── Contracts/
│   │   ├── EventRepositoryInterface.php # Interface Event Repository
│   │   └── UserRepositoryInterface.php  # Interface User Repository
│   └── Eloquent/
│       ├── EventRepository.php         # Implémentation Event Repository
│       └── UserRepository.php          # Implémentation User Repository
├── Models/
│   ├── User.php                        # Modèle utilisateur
│   └── Event.php                       # Modèle événement + rappels
├── Policies/
│   └── EventPolicy.php                 # Autorisation événements
└── Providers/
    └── AppServiceProvider.php          # Configuration policies + repositories
```

## Base de Données

```
┌─────────────────┐    ┌─────────────────────────────────────┐
│     users       │    │              events                 │
├─────────────────┤    ├─────────────────────────────────────┤
│ id (PK)         │◄───┤ user_id (FK)                        │
│ name            │    │ id (PK)                             │
│ email           │    │ title                               │
│ password        │    │ description                         │
│ timezone        │    │ start_date                          │
│ created_at      │    │ end_date                            │
│ updated_at      │    │ location                            │
└─────────────────┘    │ color                               │
                       │ is_all_day                          │
                       │ has_reminder                        │
                       │ reminder_minutes                    │
                       │ reminder_sent                       │
                       │ created_at                          │
                       │ updated_at                          │
                       │ deleted_at (soft delete)            │
                       └─────────────────────────────────────┘
```

## Flux d'Interactions

### 1. Authentification

```
Frontend                    Backend                     Database
   │                          │                           │
   │ POST /api/auth/login     │                           │
   ├─────────────────────────►│ AuthController::login     │
   │                          ├──────────────────────────►│ SELECT users
   │                          │◄──────────────────────────┤
   │◄─────────────────────────┤ JWT Token                 │
   │ Store token              │                           │
```

### 2. Chargement du Calendrier

```
Frontend                    Backend                     Repository              Database
   │                          │                           │                       │
   │ GET /api/events          │                           │                       │
   │ ?start_date=2025-10-01   │                           │                       │
   │ &end_date=2025-10-31     │                           │                       │
   ├─────────────────────────►│ EventController::index    │                       │
   │                          ├──────────────────────────►│ EventRepository::     │
   │                          │                           │ findByUserAndDateRange│
   │                          │                           ├──────────────────────►│ SELECT events
   │                          │                           │◄──────────────────────┤ WHERE user_id
   │                          │◄──────────────────────────┤                       │ AND dates
   │◄─────────────────────────┤ EventResource::collection │                       │
   │ Display in calendar      │                           │                       │
```

### 3. Sélection d'un Jour

```
Frontend                    Backend                     Repository              Database
   │                          │                           │                       │
   │ GET /api/events/day/     │                           │                       │
   │ 2025-10-22               │                           │                       │
   ├─────────────────────────►│ EventController::        │                       │
   │                          │ getEventsByDay            │                       │
   │                          ├──────────────────────────►│ EventRepository::     │
   │                          │                           │ findByUserAndDay      │
   │                          │                           ├──────────────────────►│ SELECT events
   │                          │                           │◄──────────────────────┤ WHERE date
   │                          │◄──────────────────────────┤                       │
   │◄─────────────────────────┤ EventResource::collection │                       │
   │ Show day-events modal    │                           │                       │
```

### 4. CRUD Événements

```
Frontend                    Backend                     Repository              Database
   │                          │                           │                       │
   │ POST /api/events         │                           │                       │
   ├─────────────────────────►│ EventController::store    │                       │
   │                          ├──────────────────────────►│ EventRepository::     │
   │                          │                           │ create                │
   │                          │                           ├──────────────────────►│ INSERT event
   │                          │                           │◄──────────────────────┤
   │                          │◄──────────────────────────┤                       │
   │◄─────────────────────────┤ EventResource             │                       │
   │                          │                           │                       │
   │ PUT /api/events/{id}     │                           │                       │
   ├─────────────────────────►│ EventController::update   │                       │
   │                          ├──────────────────────────►│ EventRepository::     │
   │                          │                           │ update                │
   │                          │                           ├──────────────────────►│ UPDATE event
   │                          │                           │◄──────────────────────┤
   │                          │◄──────────────────────────┤                       │
   │◄─────────────────────────┤ EventResource             │                       │
   │                          │                           │                       │
   │ DELETE /api/events/{id}  │                           │                       │
   ├─────────────────────────►│ EventController::destroy  │                       │
   │                          ├──────────────────────────►│ EventRepository::     │
   │                          │                           │ delete                │
   │                          │                           ├──────────────────────►│ DELETE event
   │                          │                           │◄──────────────────────┤
   │                          │◄──────────────────────────┤                       │
   │◄─────────────────────────┤ Success message           │                       │
```

## Sécurité

### JWT Flow
```
1. Login → JWT Token généré
2. Token stocké dans localStorage
3. AuthInterceptor ajoute "Bearer {token}" à chaque requête
4. Backend vérifie le token via middleware auth:api
5. EventPolicy vérifie que user_id = auth()->id()
```

### Protection des Routes
```
Frontend: AuthGuard → Vérifie token valide
Backend: auth:api middleware → Vérifie JWT
Backend: EventPolicy → Vérifie propriété des événements
```

## Technologies Utilisées

### Frontend
- **Angular 18** : Framework principal
- **TypeScript** : Langage
- **RxJS** : Gestion asynchrone
- **HTTP Client** : Communication API

### Backend
- **Laravel 11** : Framework PHP
- **JWT Auth** : Authentification
- **Repository Pattern** : Séparation logique métier
- **Eloquent ORM** : Base de données
- **API Resources** : Formatage JSON
- **Dependency Injection** : Inversion de contrôle

### Base de Données
- **MySQL/SQLite** : Stockage
- **Migrations** : Versioning schéma
- **Soft Deletes** : Suppression logique
- **Jobs/Queues** : Traitement asynchrone emails

## Infrastructure (Docker/Kubernetes)

### Architecture Conteneurisée

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              KUBERNETES CLUSTER                             │
├─────────────────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐                     │
│  │  Frontend   │    │   Backend   │    │    MySQL    │                     │
│  │  (Nginx)    │    │  (Laravel)  │    │ (Database)  │                     │
│  │  Port: 80   │    │  Port: 8000 │    │ Port: 3306  │                     │
│  │  2 replicas │    │  2 replicas │    │  1 replica  │                     │
│  └─────────────┘    └─────────────┘    └─────────────┘                     │
│         │                   │                   │                           │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                        INGRESS                                     │   │
│  │  / → Frontend Service                                              │   │
│  │  /api → Backend Service                                            │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Services Kubernetes

- **Namespace**: `agenda` - Isolation des ressources
- **MySQL**: PersistentVolumeClaim 1Gi + Service
- **Backend**: Deployment 2 replicas + ConfigMap + Service
- **Frontend**: Deployment 2 replicas + Service
- **Ingress**: Routage intelligent (/ → frontend, /api → backend)

### Docker Images

```
# Backend
FROM php:8.2-fpm
+ Composer
+ Extensions MySQL/ZIP
+ Laravel optimisé

# Frontend  
FROM node:18-alpine (build)
+ Angular build
FROM nginx:alpine (runtime)
+ Fichiers statiques
+ Configuration Nginx
```

## Fonctionnalités Avancées

### Rappels Email

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Scheduler     │    │   Queue Job     │    │   SMTP Server   │
│  (Cron/K8s)     │    │  (Laravel)      │    │   (Gmail/etc)   │
├─────────────────┤    ├─────────────────┤    ├─────────────────┤
│ Chaque minute   │───►│ SendEventReminder│───►│ Envoi email     │
│ Vérifie rappels │    │ Job             │    │ utilisateur     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Déploiement

```bash
# Développement local
docker-compose up --build

# Production Kubernetes
./k8s/deploy.sh

# Monitoring
kubectl get pods -n agenda
kubectl logs -f deployment/backend -n agenda
```