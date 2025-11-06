#!/bin/bash

echo "🔍 Diagnostic des services Agenda"
echo "=================================="
echo ""

# Vérifier le namespace
echo "📦 Namespace 'agenda':"
kubectl get ns agenda 2>/dev/null || echo "❌ Namespace 'agenda' introuvable"
echo ""

# Vérifier les pods
echo "🐳 État des Pods:"
kubectl get pods -n agenda
echo ""

# Détails des pods en erreur
echo "⚠️  Pods en erreur (si présents):"
kubectl get pods -n agenda --field-selector=status.phase!=Running,status.phase!=Succeeded 2>/dev/null
echo ""

# Logs du backend
echo "📋 Logs Backend (dernières 50 lignes):"
echo "---------------------------------------"
BACKEND_POD=$(kubectl get pods -n agenda -l app=backend -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -n "$BACKEND_POD" ]; then
    echo "Pod: $BACKEND_POD"
    kubectl logs -n agenda $BACKEND_POD --tail=50
else
    echo "❌ Aucun pod backend trouvé"
fi
echo ""

# Logs du frontend
echo "📋 Logs Frontend (dernières 50 lignes):"
echo "---------------------------------------"
FRONTEND_POD=$(kubectl get pods -n agenda -l app=frontend -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -n "$FRONTEND_POD" ]; then
    echo "Pod: $FRONTEND_POD"
    kubectl logs -n agenda $FRONTEND_POD --tail=50
else
    echo "❌ Aucun pod frontend trouvé"
fi
echo ""

# Logs de MariaDB
echo "📋 Logs MariaDB (dernières 30 lignes):"
echo "---------------------------------------"
MARIADB_POD=$(kubectl get pods -n agenda -l app=mariadb -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -n "$MARIADB_POD" ]; then
    echo "Pod: $MARIADB_POD"
    kubectl logs -n agenda $MARIADB_POD --tail=30
else
    echo "❌ Aucun pod MariaDB trouvé"
fi
echo ""

# Vérifier les services
echo "🌐 Services:"
kubectl get svc -n agenda
echo ""

# Vérifier les configmaps et secrets
echo "🔐 ConfigMaps et Secrets:"
kubectl get configmap,secret -n agenda
echo ""

# Tester la connectivité backend
echo "🔌 Test de connectivité Backend:"
if [ -n "$BACKEND_POD" ]; then
    echo "Test depuis le pod backend vers MariaDB..."
    kubectl exec -n agenda $BACKEND_POD -- ping -c 2 mariadb-service 2>/dev/null || echo "❌ Impossible de pinger MariaDB"
    
    echo "Vérification des variables d'environnement du backend:"
    kubectl exec -n agenda $BACKEND_POD -- env | grep -E "DB_|APP_" || echo "❌ Variables d'environnement introuvables"
fi
echo ""

# Describe des pods en erreur
echo "🔍 Description détaillée des pods backend:"
if [ -n "$BACKEND_POD" ]; then
    kubectl describe pod -n agenda $BACKEND_POD | tail -30
fi
echo ""

echo "✅ Diagnostic terminé"
echo ""
echo "💡 Commandes utiles supplémentaires:"
echo "   - Voir tous les événements: kubectl get events -n agenda --sort-by='.lastTimestamp'"
echo "   - Shell dans le backend: kubectl exec -it -n agenda $BACKEND_POD -- /bin/bash"
echo "   - Vérifier la base de données: kubectl exec -it -n agenda $MARIADB_POD -- mysql -u user -pmd_pass agenda"