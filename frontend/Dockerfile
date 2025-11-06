# --- ÉTAPE 1 : CONSTRUCTION (Nommée "builder") ---
FROM node:20-alpine AS builder

WORKDIR /usr/src/app

# Installer pnpm globalement
RUN npm install -g pnpm

# Copier les fichiers de dépendances
COPY package*.json ./
COPY pnpm-lock.yaml ./

# Installer les dépendances
RUN pnpm install --frozen-lockfile

# Copier le reste du code source
COPY . .

# Construire l'application Angular
# La configuration de production doit être dans angular.json
RUN pnpm run build --configuration=production

# --- ÉTAPE 2 : PRODUCTION (Serveur Nginx léger) ---
FROM nginx:alpine

# Supprimer la configuration par défaut de Nginx
RUN rm -rf /usr/share/nginx/html/*

# Copier les fichiers buildés depuis l'étape builder
# Adapter le chemin selon votre configuration Angular
COPY --from=builder /usr/src/app/dist/frontend/browser /usr/share/nginx/html

# Copier la configuration Nginx personnalisée
COPY agenda.conf /etc/nginx/conf.d/default.conf

# S'assurer que les fichiers sont accessibles
RUN chown -R nginx:nginx /usr/share/nginx/html
RUN chmod -R +r /usr/share/nginx/html

# Exposer le port 80
EXPOSE 80

# Démarrer Nginx
CMD ["nginx", "-g", "daemon off;"]