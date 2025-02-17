#!/bin/bash

echo "Generating SSL certificates"

openssl genpkey -algorithm RSA -out /etc/ssl/private/nginx-selfsigned.key
openssl req -new -key /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/private/nginx-selfsigned.csr \
    -subj "/C=CA/ST=QC/O=Company Inc/CN=example.com"
openssl x509 -req -days 365 -in /etc/ssl/private/nginx-selfsigned.csr -signkey /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt

echo "Create directories in storage"

mkdir -p "storage"
mkdir -p "packages"
mkdir -p "bootstrap/cache"

chmod -R 777 "storage" && chmod -R 777 "bootstrap/cache" && chmod -R 777 "packages"

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