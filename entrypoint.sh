#!/bin/sh
set -e

php artisan config:clear || true
php artisan view:clear   || true
php artisan config:cache || true
php artisan view:cache   || true

php artisan vendor:publish --provider="Sendportal\\Base\\SendportalBaseServiceProvider" --force
php artisan migrate --force

# Démarrer le worker si la queue n’est pas "sync"
if [ -n "${QUEUE_CONNECTION}" ] && [ "${QUEUE_CONNECTION}" != "sync" ]; then
  echo "Starting queue worker for connection: ${QUEUE_CONNECTION}"
  php artisan queue:work "${QUEUE_CONNECTION}" --sleep=1 --tries=3 > /var/log/queue.log 2>&1 &
fi

# (Optionnel) Health-check Redis simple
php -r '
$h=getenv("REDIS_HOST")?: "127.0.0.1";
$p=(int)(getenv("REDIS_PORT")?:6379);
$pw=getenv("REDIS_PASSWORD");
$r=new Redis();
$r->connect($h,$p,2.0);
if ($pw) { $r->auth($pw); }
echo "Redis PING: ".$r->ping().PHP_EOL;
' || true

exec frankenphp run --config /etc/frankenphp/Caddyfile
