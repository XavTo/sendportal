FROM dunglas/frankenphp:php8.2-bookworm

# Installer les extensions PHP nécessaires
RUN install-php-extensions pcntl bcmath pdo_mysql zip

# Installer les bibliothèques système pour zip (libzip), node, npm, etc.
RUN apt-get update && apt-get install -y \
        libzip-dev unzip \
        nodejs npm \
    && rm -rf /var/lib/apt/lists/*

# Installer Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

WORKDIR /app

COPY . .

# Installer dépendances PHP
RUN composer install --no-interaction --optimize-autoloader

# Installer dépendances Node / NPM et compiler les assets front-end
RUN npm install \
    && npm run production

# (Optionnel) si tu veux nettoyer les dev deps ou node_modules, mais attention aux assets
# RUN npm prune --production

# S’assurer que les permissions sur les dossiers public soient correctes
RUN chown -R www-data:www-data public
RUN chmod -R 755 public

# Commande de démarrage — ici on utilise `artisan serve`, mais tu peux utiliser Caddy/nginx selon ta configuration
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8080"]
