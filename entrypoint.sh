#!/bin/sh
set -e

# 1) Caches "safe" (pas de route:cache pour éviter les conflits de nom)
php artisan config:clear || true
php artisan view:clear   || true
php artisan config:cache || true
php artisan view:cache   || true

# 2) Publier les assets SendPortal (génère le mix-manifest attendu)
php artisan vendor:publish --provider="Sendportal\\Base\\SendportalBaseServiceProvider" --force
echo "---- MIX MANIFEST ----"
php -r 'echo @file_get_contents("public/vendor/sendportal/mix-manifest.json") ?: "absent\n";'

# 3) Migrations
php artisan migrate --force

# 4) Queue (optionnel)
if [ "${QUEUE_CONNECTION}" = "database" ]; then
  php artisan queue:table || true
  php artisan migrate --force
fi

# 5) Démarrage serveur (← CHANGEMENT ICI)
exec frankenphp run --config /etc/frankenphp/Caddyfile
