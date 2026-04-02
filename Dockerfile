# Use PHP 8.2 CLI as base image
FROM php:8.2-cli

# Set working directory
WORKDIR /var/www/html

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    nodejs \
    npm \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy composer files
COPY composer.json composer.lock* ./

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Copy package files
COPY package.json package-lock.json* ./

# Install React dependencies
RUN npm install

# Copy application code
COPY . .

# Build React assets
RUN npm run build

# Set environment variable for port (default to 8000 if not set)
ENV PORT=8000

# Expose the port
EXPOSE $PORT

# Run Laravel server
CMD php artisan serve --host=0.0.0.0 --port=$PORT