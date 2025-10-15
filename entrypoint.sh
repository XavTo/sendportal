#!/bin/sh
set -e

# 1) Clé d’app (si absente)
if [ -z "${APP_KEY}" ] || [ "${APP_KEY}" = "null" ] || [ "${APP_KEY}" = '""' ]; then
  php artisan key:generate --force
fi

# 2) Caches "safe" (PAS de route:cache à cause du conflit de routes)
php artisan config:clear || true
php artisan view:clear || true
php artisan config:cache || true
php artisan view:cache   || true

# 3) Publier les fichiers SendPortal (config, vues, langues, assets -> public/vendor/sendportal/*)
php artisan vendor:publish --provider="Sendportal\\Base\\SendportalBaseServiceProvider" --force

# 4) Migrations (la connexion DB est dispo au runtime sur Railway)
php artisan migrate --force

# 5) Si la queue DB est utilisée, préparer la table des jobs (idempotent)
if [ "${QUEUE_CONNECTION}" = "database" ]; then
  php artisan queue:table || true
  php artisan migrate --force
fi

# 6) Démarrer FrankenPHP (Caddy + worker PHP) avec le Caddyfile
exec frankenphp
