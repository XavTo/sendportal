#!/bin/sh
set -e

# APP_KEY : si manquante, on la génère (prérequis pour Laravel/SendPortal).
if [ -z "${APP_KEY}" ] || [ "${APP_KEY}" = "null" ] || [ "${APP_KEY}" = '""' ]; then
  php artisan key:generate --force
fi

# Caches (optionnel, mais recommandé en prod)
php artisan config:cache || true
php artisan route:cache || true
php artisan view:cache || true

# Publier les fichiers SendPortal (config, vues, langues, assets dont mix-manifest)
php artisan vendor:publish --provider="Sendportal\\Base\\SendportalBaseServiceProvider" --force

# Migrations
php artisan migrate --force

# Si vous utilisez la queue "database", créer la table jobs
if [ "${QUEUE_CONNECTION}" = "database" ]; then
  php artisan queue:table || true
  php artisan migrate --force
fi

# Démarrage du serveur (Caddy + FrankenPHP)
exec frankenphp
