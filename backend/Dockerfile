# Build stage
FROM php:8.2-fpm AS builder

RUN apt-get update && apt-get install -y \
    git unzip libpq-dev libzip-dev \
    && docker-php-ext-install pdo pdo_mysql zip \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

COPY composer.json composer.lock ./
RUN composer install --optimize-autoloader --no-scripts

COPY ./ ./

# Production stage
FROM php:8.2-fpm

RUN apt-get update && apt-get install -y \
    libpq-dev libzip-dev \
    && docker-php-ext-install pdo pdo_mysql zip \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd -g 1000 appuser \
    && useradd -u 1000 -g appuser -m appuser

WORKDIR /var/www

COPY --from=builder --chown=appuser:appuser /var/www .

RUN mkdir -p storage/logs storage/framework/{cache,sessions,views} bootstrap/cache \
    && chown -R appuser:appuser storage bootstrap/cache

USER appuser

EXPOSE 8000

CMD php artisan serve --host=0.0.0.0 --port=8000

