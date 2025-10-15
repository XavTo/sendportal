FROM dunglas/frankenphp:php8.2-bookworm

RUN install-php-extensions pcntl bcmath pdo pdo_mysql

WORKDIR /app
COPY . .

RUN composer install --no-interaction --optimize-autoloader

CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8080"]
