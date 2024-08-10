#!/bin/sh

if [ ! -f .env ]; then
    echo "Archivo .env no encontrado. Copiando .env.example a .env..."
    cp .env.example .env
fi

APP_CONTAINER_NAME=$(sed -n 's/^APP_CONTAINER_NAME=//p' .env)

toilet -f future -F border --filter metal -- "$APP_CONTAINER_NAME"

toilet -f term -F border -- "Composer Install"
composer install
toilet -f term -F border -- "Migrate"
rm /var/www/html/database/database.sqlite
php artisan migrate --force
toilet -f term -F border -- "key:generate"
php artisan key:generate
php artisan config:cache
toilet -f term -F border -- "NPM Install"
npm install

toilet -f term -F border -- "Assign /var/www/html to a www-data"
chown -R www-data:www-data /var/www/html


toilet -f term -F border -- "Assign Permissions to SQLite Database"
chown www-data:www-data /var/www/html/database/database.sqlite

toilet -f term -F border -- "Assign Permissions to Database"
chmod 755 /var/www/html/database
chmod 664 /var/www/html/database/database.sqlite

toilet -f term -F border -- "enable apache2 000-default.conf"
a2enconf 000-default.conf

toilet -f term -F border -- "rewrite module"
a2enmod rewrite

toilet -f future -F border -- "Starting Apache"
apache2-foreground

