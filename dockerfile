# Gunakan base image PHP dengan server Apache
FROM php:8.2-fpm-alpine3.21

# Instal dependensi sistem yang dibutuhkan
RUN apk update && apk add --no-cache \
    zip unzip git curl libzip-dev libpng-dev libxml2-dev oniguruma-dev

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

COPY . /var/www/html

# Permissions storage dan cache
RUN chgrp -R 0 /var/www/html/storage /var/www/html/bootstrap/cache && \
    chmod -R g=u /var/www/html/storage /var/www/html/bootstrap/cache
# RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache && \
#     chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Copy Laravel app ke dalam container

# Install dependencies Laravel (jika vendor belum ada)
RUN cd /var/www/html && \
    if [ ! -d "vendor" ]; then composer install; fi && \
    if [ ! -f ".env" ]; then cp .env.example .env; fi && \
    php artisan key:generate

# Jalankan perintah untuk membuat symbolic link
RUN cd /var/www/html && php artisan storage:link
     
EXPOSE 8000
    
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]