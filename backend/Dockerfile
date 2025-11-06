# Build stage
FROM php:8.2-fpm AS builder

RUN apt-get update && apt-get install -y \
    git unzip libpq-dev libzip-dev \
    && docker-php-ext-install pdo pdo_mysql zip \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

COPY composer.json composer.lock ./
RUN composer install --optimize-autoloader --no-scripts --no-dev

COPY ./ ./

# Production stage
FROM php:8.2-fpm

RUN apt-get update && apt-get install -y \
    libpq-dev libzip-dev \
    && docker-php-ext-install pdo pdo_mysql zip \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd -g 1000 appuser \
    && useradd -u 1000 -g appuser -m appuser

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

COPY --from=builder --chown=appuser:appuser /var/www .

# Créer le fichier .env s'il n'existe pas (basé sur .env.example)
RUN if [ ! -f .env ]; then \
      if [ -f .env.example ]; then \
        cp .env.example .env; \
      else \
        touch .env; \
      fi; \
    fi

RUN mkdir -p storage/logs storage/framework/{cache,sessions,views} bootstrap/cache \
    && chown -R appuser:appuser storage bootstrap/cache .env

USER appuser

EXPOSE 8000

CMD php artisan serve --host=0.0.0.0 --port=8000
