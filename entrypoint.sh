#!/bin/sh
set -e

# 0) Publier Horizon si la config n'existe pas encore (premier run)
php artisan horizon:publish || true

# 1) Caches "safe"
php artisan config:clear || true
php artisan view:clear   || true
php artisan config:cache || true
php artisan view:cache   || true

# 2) Assets SendPortal (mix-manifest public/vendor/sendportal)
php artisan vendor:publish --provider="Sendportal\\Base\\SendportalBaseServiceProvider" --force
echo "---- MIX MANIFEST ----"
php -r 'echo @file_get_contents("public/vendor/sendportal/mix-manifest.json") ?: "absent\n";'

# 3) Migrations
php artisan migrate --force

# 4) Lancer Horizon (remplace queue:work)
php artisan horizon > /var/log/horizon.log 2>&1 &

# (optionnel) petit healthcheck Redis (phpredis)
php -r '
$h=getenv("REDIS_HOST")?: "127.0.0.1";
$p=(int)(getenv("REDIS_PORT")?:6379);
$pw=getenv("REDIS_PASSWORD");
$r=new Redis();
$r->connect($h,$p,2.0);
if ($pw) { $r->auth($pw); }
echo "Redis PING: ".$r->ping().PHP_EOL;
' || true

# 5) Web server (Caddy/FrankenPHP)
exec frankenphp run --config /etc/frankenphp/Caddyfile
