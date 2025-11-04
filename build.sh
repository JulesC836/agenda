#!/bin/bash

set -e

echo "🏗️ Construction des images Docker pour l'application Agenda"

# Variables
BACKEND_IMAGE="agenda-backend"
FRONTEND_IMAGE="agenda-frontend"
TAG=${1:-latest}

echo "📦 Tag utilisé: $TAG"

# Build backend
echo "🔨 Construction de l'image backend..."
docker build -t $BACKEND_IMAGE:$TAG ./backend
echo "✅ Backend construit: $BACKEND_IMAGE:$TAG"

# Build frontend
echo "🔨 Construction de l'image frontend..."
docker build -t $FRONTEND_IMAGE:$TAG ./frontend
echo "✅ Frontend construit: $FRONTEND_IMAGE:$TAG"

# Afficher les images
echo "📋 Images construites:"
docker images | grep agenda

echo "🎉 Construction terminée!"