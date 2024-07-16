#!/bin/bash



echo "Create directories in storage"

mkdir -p "storage"
mkdir -p "bootstrap/cache"

chmod -R 777 "storage" && chmod -R 777 "bootstrap/cache"

mkdir -p "storage/app"
mkdir -p "storage/app/public"
mkdir -p "storage/framework"
mkdir -p "storage/framework/cache"
mkdir -p "storage/framework/cache/data"
mkdir -p "storage/framework/sessions"
mkdir -p "storage/framework/testing"
mkdir -p "storage/framework/views"
mkdir -p "storage/logs"
mkdir -p "storage/database"

touch storage/database/database.sqlite && chmod -R 777 storage/database/database.sqlite

composer install

cd /var/www/html
php artisan migrate --force
php artisan optimize

/usr/sbin/service php8.3-fpm start
/usr/sbin/service nginx start
tail -f /dev/null