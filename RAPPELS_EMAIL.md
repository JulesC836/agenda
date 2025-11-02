# Fonctionnalité de Rappel par Email

## Fonctionnalités ajoutées

### Backend
1. **Migration** : Ajout des champs `has_reminder`, `reminder_minutes`, `reminder_sent` à la table events
2. **Job** : `SendEventReminderJob` pour envoyer les emails
3. **Command** : `SendEventReminders` pour traiter les rappels (programmée chaque minute)
4. **Template email** : Vue Blade pour les rappels

### Frontend
1. **Interface** : Champs de rappel ajoutés au formulaire d'événement
2. **Options** : 15min, 30min, 1h, 2h, 1 jour avant l'événement

## Installation

### 1. Backend
```bash
cd backend
php artisan migrate
php artisan queue:work &
```

### 2. Configuration email (optionnel)
Dans `.env`, remplacer `MAIL_MAILER=log` par :
```env
MAIL_MAILER=smtp
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=votre-email@gmail.com
MAIL_PASSWORD=votre-mot-de-passe-app
MAIL_ENCRYPTION=tls
```

### 3. Programmation des rappels
Ajouter au crontab :
```bash
* * * * * cd /path/to/agenda/backend && php artisan schedule:run >> /dev/null 2>&1
```

## Utilisation

1. Créer/modifier un événement
2. Cocher "Rappel par email"
3. Choisir le délai (15min à 1 jour)
4. Le rappel sera envoyé automatiquement
