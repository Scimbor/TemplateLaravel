#!/bin/bash
set -e

echo "Generating SSL certificates..."
openssl genpkey -algorithm RSA -out /etc/ssl/private/nginx-selfsigned.key 2>/dev/null
openssl req -new -key /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/private/nginx-selfsigned.csr \
    -subj "/C=PL/ST=PL/O=Laravel/CN=localhost" 2>/dev/null
openssl x509 -req -days 365 -in /etc/ssl/private/nginx-selfsigned.csr \
    -signkey /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt 2>/dev/null

cd /var/www/html

# Check if Laravel is installed
if [ ! -f "composer.json" ]; then
    echo "Creating new Laravel project..."
    cd /var/www
    composer create-project --prefer-dist laravel/laravel:^12.0 temp_project
    mv temp_project/* temp_project/.* html/ 2>/dev/null || true
    rm -rf temp_project
    cd /var/www/html
fi

echo "Installing dependencies..."
composer install --no-interaction --optimize-autoloader
npm install
npm run build

echo "Setting up Laravel..."
mkdir -p storage/{app/public,framework/{cache/data,sessions,testing,views},logs,database} bootstrap/cache packages

[ ! -f "storage/database/database.sqlite" ] && touch storage/database/database.sqlite

chown -R www-data:www-data storage bootstrap/cache packages
chmod -R 775 storage bootstrap/cache packages
[ -f "storage/database/database.sqlite" ] && chmod 666 storage/database/database.sqlite

if [ ! -f ".env" ]; then
    cp .env.example .env
fi

php artisan migrate --force
php artisan optimize

echo "Starting services..."
/usr/sbin/service php8.4-fpm start
/usr/sbin/service nginx start

echo "Laravel is ready!"
tail -f /dev/null