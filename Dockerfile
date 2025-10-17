FROM dunglas/frankenphp:php8.2-bookworm

RUN install-php-extensions pcntl bcmath pdo_pgsql pgsql zip redis
RUN apt-get update && apt-get install -y libzip-dev unzip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .
COPY Caddyfile /etc/frankenphp/Caddyfile

RUN curl -sS https://getcomposer.org/installer | php -- \
      --install-dir=/usr/local/bin --filename=composer

# Ajout des paquets Postmark à l’image
RUN composer require symfony/postmark-mailer symfony/http-client \
      --no-interaction --no-scripts --prefer-dist

RUN composer require laravel/horizon --no-interaction --no-scripts --prefer-dist

# Installer (ou ré-optimiser) les deps
RUN composer install --no-interaction --no-dev --prefer-dist --optimize-autoloader

RUN chown -R www-data:www-data storage bootstrap/cache \
 && chmod -R ug+rwx storage bootstrap/cache

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]
