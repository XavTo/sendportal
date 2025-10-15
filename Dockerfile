FROM dunglas/frankenphp:php8.2-bookworm

# Installer les extensions PHP nécessaires et zip
RUN install-php-extensions pcntl bcmath pdo_pgsql pgsql zip

# Installer les bibliothèques système nécessaires (si besoin)
RUN apt-get update && apt-get install -y libzip-dev unzip \
    && rm -rf /var/lib/apt/lists/*

# Copier le Caddyfile dans l’emplacement attendu
COPY Caddyfile /etc/frankenphp/Caddyfile

WORKDIR /app
COPY . .

# Installer Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Installer les dépendances PHP
RUN composer install --no-interaction --optimize-autoloader

# (Optionnel) générer les assets si tu as le `package.json` dans le bon dossier, sinon les inclure déjà
# Si tu génères localement, tu ne fais rien ici
# RUN cd vendor/mettle/sendportal-core && npm install && npm run production

# Exécuter les migrations (et éventuellement sp:install) via commande d’entrée ou script
# Tu peux lancer ici :
RUN php artisan migrate --force

# Définir la commande de démarrage : lancer FrankenPHP (qui démarre le serveur + Caddy)
CMD ["frankenphp"]
