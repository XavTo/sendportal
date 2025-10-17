#!/bin/sh
set -e

# 1) Caches "safe"
php artisan config:clear || true
php artisan view:clear   || true
php artisan config:cache || true
php artisan view:cache   || true

# 2) Publier les assets SendPortal (génère mix-manifest)
php artisan vendor:publish --provider="Sendportal\\Base\\SendportalBaseServiceProvider" --force
echo "---- MIX MANIFEST ----"
php -r 'echo @file_get_contents("public/vendor/sendportal/mix-manifest.json") ?: "absent\n";'

# 3) Migrations
php artisan migrate --force

# 4) Démarrer un worker de queue si nécessaire
if [ -n "${QUEUE_CONNECTION}" ] && [ "${QUEUE_CONNECTION}" != "sync" ]; then
  echo "Starting queue worker for connection: ${QUEUE_CONNECTION}"
  php artisan queue:work "${QUEUE_CONNECTION}" \
    --sleep=1 \
    --tries=3 \
    --max-time=0 \
    > /var/log/queue.log 2>&1 &
fi

# Optionnel : petit check Redis pour log de santé
if [ "${QUEUE_CONNECTION}" = "redis" ]; then
  php -r 'try{echo "Redis PING: ".(app()->make(Illuminate\\Redis\\RedisManager::class)->connection()->ping()).PHP_EOL;}catch(Throwable $e){fwrite(STDERR,"Redis error: ".$e->getMessage().PHP_EOL);}' || true
fi

# 5) Lancer le serveur Web (Caddy/FrankenPHP)
exec frankenphp run --config /etc/frankenphp/Caddyfile

