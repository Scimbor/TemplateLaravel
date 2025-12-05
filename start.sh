#!/bin/bash

echo "Generating SSL certificates"

openssl genpkey -algorithm RSA -out /etc/ssl/private/nginx-selfsigned.key
openssl req -new -key /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/private/nginx-selfsigned.csr \
    -subj "/C=CA/ST=QC/O=Company Inc/CN=example.com"
openssl x509 -req -days 365 -in /etc/ssl/private/nginx-selfsigned.csr -signkey /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt

cd /var/www/html

# Check if Laravel is installed
if [ ! -f "composer.json" ]; then
    echo "Creating new Laravel 12 project..."
    cd /var/www
    composer create-project --prefer-dist laravel/laravel:^12.0 temp_project
    mv temp_project/* temp_project/.* html/ 2>/dev/null || true
    rm -rf temp_project
    cd /var/www/html
fi

echo "Installing/Updating dependencies..."
composer install --no-interaction --optimize-autoloader
npm install

echo "Creating directories and setting permissions..."

# Create all necessary directories
mkdir -p \
    storage/app/public \
    storage/framework/cache/data \
    storage/framework/sessions \
    storage/framework/testing \
    storage/framework/views \
    storage/logs \
    storage/database \
    bootstrap/cache \
    packages

# Create SQLite database
touch storage/database/database.sqlite

# Set permissions for all directories and files
chown -R www-data:www-data storage bootstrap/cache packages
chmod -R 775 storage bootstrap/cache packages
chmod 666 storage/database/database.sqlite

# Generate app key if not exists
if [ ! -f ".env" ]; then
    cp .env.example .env
    php artisan key:generate
fi

php artisan migrate --force
php artisan optimize

/usr/sbin/service php8.4-fpm start
/usr/sbin/service nginx start
tail -f /dev/null