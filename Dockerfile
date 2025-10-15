FROM dunglas/frankenphp:php8.2-bookworm

# Installer les extensions PHP nécessaires
RUN install-php-extensions pcntl bcmath pdo_mysql zip

# Installer les bibliothèques système pour zip (libzip) si nécessaire
RUN apt-get update && apt-get install -y libzip-dev unzip \
    && rm -rf /var/lib/apt/lists/*

# Installer Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

WORKDIR /app
COPY . .

# Si tu veux forcer la pause des vérifications de plateforme (à utiliser avec prudence)
# RUN composer install --no-interaction --optimize-autoloader --ignore-platform-req=ext-zip

RUN composer install --no-interaction --optimize-autoloader

CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8080"]
