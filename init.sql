-- Accorder les permissions à l'utilisateur `user_laravel` pour se connecter depuis n'importe quel hôte ('%')
GRANT ALL PRIVILEGES ON agenda.* TO 'user_laravel'@'%' IDENTIFIED BY 'supersecure';

-- Optionnel, mais fortement recommandé : pour l'accès CLI
GRANT ALL PRIVILEGES ON *.* TO 'user_laravel'@'%' IDENTIFIED BY 'supersecure';

FLUSH PRIVILEGES;