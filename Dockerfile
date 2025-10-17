FROM dunglas/frankenphp:php8.2-bookworm

# Extensions PHP (PostgreSQL + Redis + utilitaires)
RUN install-php-extensions pcntl bcmath pdo_pgsql pgsql zip redis

RUN apt-get update && apt-get install -y libzip-dev unzip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .
COPY Caddyfile /etc/frankenphp/Caddyfile

# Composer
RUN curl -sS https://getcomposer.org/installer \
  | php -- --install-dir=/usr/local/bin --filename=composer

# Dépendances PHP
RUN composer install --no-interaction --no-dev --prefer-dist --optimize-autoloader

# Permissions
RUN chown -R www-data:www-data storage bootstrap/cache && \
    chmod -R ug+rwx storage bootstrap/cache

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]
