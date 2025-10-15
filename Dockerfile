# ---------- BUILD (Composer) ----------
FROM composer:2 AS build
WORKDIR /app

# Copie des fichiers Composer
COPY composer.json composer.lock ./
# IMPORTANT : ignorer ext-pcntl à l'étape build
RUN composer install --no-dev --prefer-dist --no-interaction --no-scripts --optimize-autoloader --ignore-platform-req=ext-pcntl

# Copie du code
COPY . .
RUN composer dump-autoload --optimize

# ---------- RUNTIME ----------
FROM debian:stable-slim

# Paquets système & PHP
RUN apt-get update && apt-get install -y \
  nginx supervisor curl ca-certificates git unzip \
  php-fpm php-cli php-mbstring php-xml php-zip php-curl php-intl php-bcmath php-gd php-pgsql \
  php-redis php-dev pkg-php-tools build-essential \
  libpq-dev libicu-dev libjpeg62-turbo-dev libpng-dev \
  && rm -rf /var/lib/apt/lists/*

# Activer PCNTL (fourni par le paquet php-cli/fpm sur Debian) ; si nécessaire :
# RUN docker-php-ext-install pcntl  # <- à utiliser uniquement si vous partez d'une image "php:*"
# (Sur Debian + paquets php-*, pcntl est intégré à php-cli/fpm, rien à compiler.)

WORKDIR /var/www/html
COPY --from=build /app /var/www/html

# Permissions Laravel
RUN mkdir -p storage bootstrap/cache && chown -R www-data:www-data /var/www/html

# Nginx & PHP-FPM config
COPY docker/nginx.conf /etc/nginx/nginx.conf
COPY docker/site.conf /etc/nginx/conf.d/default.conf

# Supervisor (lance Nginx + PHP-FPM)
COPY docker/supervisor-web.conf /etc/supervisor/conf.d/web.conf

EXPOSE 8080

ENV APP_ENV=production \
    APP_DEBUG=false \
    LOG_CHANNEL=stderr

CMD ["/usr/bin/supervisord","-n","-c","/etc/supervisor/supervisord.conf"]
