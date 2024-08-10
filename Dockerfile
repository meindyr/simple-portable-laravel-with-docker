# Usa una imagen base de PHP con Apache
FROM php:8.2-apache

# Instala dependencias adicionales para PHP y SQLite
RUN apt-get update && apt-get install -y \
    libsqlite3-dev \
    unzip \
    && docker-php-ext-install pdo_sqlite

# Instala Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Instala Node.js y NPM
RUN apt-get install -y nodejs npm

RUN apt-get install toilet -y

WORKDIR /var/www/html/

# Instala dependencias de Composer
COPY composer.json /var/www/html/composer.json

# Instala dependencias de NPM
COPY package.json /var/www/html/package.json

# Configura Apache
COPY 000-default.conf /etc/apache2/sites-available/000-default.conf

# Copia el script de inicio
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# Ajusta permisos y propiedad
RUN chown -R www-data:www-data /var/www/html

# Exponer el puerto 80 para Apache
EXPOSE 80

# Establece el script de entrada
ENTRYPOINT ["start.sh"]
