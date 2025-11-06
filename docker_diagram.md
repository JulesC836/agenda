# Test Diagramme
Structure des Images Docker

docker/
├── frontend.Dockerfile          # Multi-stage: Build Angular + Nginx
├── backend.Dockerfile           # PHP-FPM + Laravel + Composer  
├── mysql.Dockerfile            # MariaDB avec init SQL
└── docker-compose.yml          # Orchestration développement

Diagramme Architecture Docker
┌─────────────────────────────────────────────────────────┐
│                    DOCKER HOST                          │
└─────────────────────────────────────────────────────────┘

┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  FRONTEND   │    │   BACKEND   │    │   MYSQL     │
│  Container  │    │  Container  │    │  Container  │
│             │    │             │    │             │
│ Angular 18  │◄──►│ Laravel 11  │◄──►│ MariaDB     │
│ Nginx       │    │ PHP-FPM     │    │  8.0        │
│ Port: 4200  │    │ Port: 8000  │    │ Port: 3306  │
└─────────────┘    └─────────────┘    └─────────────┘
       │                   │                   │
       └───────────────────┼───────────────────┘
                           │
                 ┌─────────┴─────────┐
                 │ Docker Compose    │
                 │ Network: bridge   │
                 └───────────────────┘

                 🔧 Détails des Dockerfiles
Frontend.Dockerfile (Multi-stage)
# Stage 1: Build Angular
FROM node:18-alpine as builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build --prod

# Stage 2: Production avec Nginx  
FROM nginx:alpine
COPY --from=builder /app/dist/frontend /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80

Backend.Dockerfile
FROM php:8.2-fpm-alpine

# Extensions PHP
RUN docker-php-ext-install pdo pdo_mysql

# Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Application
WORKDIR /var/www/html
COPY . .
RUN composer install --no-dev --optimize-autoloader

EXPOSE 8000

MySQL.Dockerfile
FROM mysql:8.0

# Initialisation BDD
COPY init.sql /docker-entrypoint-initdb.d/

# Configuration
ENV MYSQL_ROOT_PASSWORD=supersecure
ENV MYSQL_DATABASE=agenda
ENV MYSQL_USER=user
ENV MYSQL_PASSWORD=md_pass

EXPOSE 3306


