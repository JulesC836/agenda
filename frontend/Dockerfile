# --- ÉTAPE 1 : CONSTRUCTION (Nommée "builder") ---
# Utilisez une image Node pour compiler l'application Angular
FROM node:25-alpine AS builder

# Définir le répertoire de travail
WORKDIR /usr/src/app

# Copier package.json et package-lock.json
COPY frontend/package*.json ./

# Installer les dépendances
RUN npm install

# Copier le reste du code source
COPY frontend/ .

# Construire l'application Angular
# Assurez-vous d'utiliser l'option --output-path pour diriger la sortie vers /usr/src/app/dist/frontend
# et de configurer la variable de production appropriée si nécessaire.
RUN npm run build -- --output-path=./dist/frontend --configuration=production


# --- ÉTAPE 2 : PRODUCTION (Serveur Nginx léger) ---
# Utiliser une image Nginx légère pour servir les fichiers statiques
FROM nginx:alpine

# Copier les fichiers de construction (maintenant qu'elle est nommée "builder")
# La ligne suivante utilise l'alias 'builder' défini dans l'étape 1
COPY --from=builder /usr/src/app/dist/frontend /usr/share/nginx/html

# Copier le fichier de configuration Nginx
COPY frontend/nginx.conf /etc/nginx/nginx.conf

# Exposer le port par défaut de Nginx
EXPOSE 80

# Le conteneur démarre Nginx par défaut
CMD ["nginx", "-g", "daemon off;"]
