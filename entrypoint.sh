#!/bin/sh
set -e

# 1) APP_KEY si absente
if [ -z "${APP_KEY}" ] || [ "${APP_KEY}" = "null" ] || [ "${APP_KEY}" = '""' ]; then
  php artisan key:generate --force
fi

# 2) Caches "safe" (pas de route:cache pour éviter les conflits de nom)
php artisan config:clear || true
php artisan view:clear   || true
php artisan config:cache || true
php artisan view:cache   || true

# 3) Publier les assets SendPortal (génère le mix-manifest attendu)
php artisan vendor:publish --provider="Sendportal\\Base\\SendportalBaseServiceProvider" --force

# 4) Migrations
php artisan migrate --force

# 5) Queue (optionnel)
if [ "${QUEUE_CONNECTION}" = "database" ]; then
  php artisan queue:table || true
  php artisan migrate --force
fi

# 6) Démarrage serveur (← CHANGEMENT ICI)
exec frankenphp run --config /etc/frankenphp/Caddyfile
