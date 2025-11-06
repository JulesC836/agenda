# --- ÉTAPE 1 : CONSTRUCTION (Nommée "builder") ---
# Utilisez une image Node pour compiler l'application Angular
FROM node:20-alpine AS builder

# Définir le répertoire de travail
WORKDIR /usr/src/app

# Installer pnpm globalement (gestionnaire de paquets)
RUN npm install -g pnpm


COPY package*.json ./
COPY pnpm-lock.yaml ./

# Installer toutes les dépendances (y compris les dépendances de développement)
# Cela est crucial pour que le compilateur Angular trouve @types/node.
RUN pnpm install @types/node --save-dev
RUN pnpm install --frozen-lockfile

# Copier le reste du code source (pour la compilation)
COPY . .

# Construire l'application Angular

RUN npm run build --output-path=./dist/frontend --configuration=production

# --- ÉTAPE 2 : PRODUCTION (Serveur Nginx léger) ---
FROM nginx:alpine

RUN rm /usr/share/nginx/html/*.html

COPY --from=builder /usr/src/app/dist/frontend/. /usr/share/nginx/html

# Copier le fichier de configuration Nginx DEPUIS le contexte de construction
COPY agenda.conf /etc/nginx/conf.d/agenda.conf

RUN chmod -R 755 /usr/share/nginx/html



# Exposer le port par défaut de Nginx
EXPOSE 80

# Le conteneur démarre Nginx par défaut
CMD ["nginx", "-g", "daemon off;"]
