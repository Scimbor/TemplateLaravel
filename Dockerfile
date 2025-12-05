FROM debian:bookworm-slim 

# Version arguments
ARG PHP_VERSION=8.4
ARG NODE_VERSION=23
ARG COMPOSER_VERSION=2.8.4

# Laravel env vars
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV COMPOSER_MEMORY_LIMIT=-1
ENV APP_ENV=production
ENV APP_DEBUG=false
ENV LANG=en_US.UTF-8
# Make PHP_VERSION available as ENV variable
ENV PHP_VERSION=${PHP_VERSION}

USER root

# System setup and locales
RUN apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y locales \
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen en_US.UTF-8

# Install system tools and dependencies
RUN apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y \
    wget \
    curl \
    gnupg2 \
    ca-certificates \
    lsb-release \
    apt-transport-https \
    unzip \
    supervisor \
    logrotate \
    nginx-light \
    cron \
    git \
    nano \
    rsync \
    mc \
    bash \
    openssl \
    exim4 \
    dos2unix

# Add Sury PHP repository and install PHP

RUN curl -sSL https://packages.sury.org/php/apt.gpg -o /etc/apt/trusted.gpg.d/sury-php.gpg \
    && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/sury-php.list \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
        php$PHP_VERSION \
        php$PHP_VERSION-fpm \
        php$PHP_VERSION-cli \
        php$PHP_VERSION-dev \
        php$PHP_VERSION-common \
        php$PHP_VERSION-mysql \
        php$PHP_VERSION-pgsql \
        php$PHP_VERSION-sqlite3 \
        php$PHP_VERSION-curl \
        php$PHP_VERSION-gd \
        php$PHP_VERSION-intl \
        php$PHP_VERSION-xsl \
        php$PHP_VERSION-xml \
        php$PHP_VERSION-zip \
        php$PHP_VERSION-soap \
        php$PHP_VERSION-imagick \
        php$PHP_VERSION-opcache \
        php$PHP_VERSION-mbstring \
        php$PHP_VERSION-dom \
        php$PHP_VERSION-bcmath \
        php$PHP_VERSION-redis \
        php$PHP_VERSION-tokenizer \
        php$PHP_VERSION-fileinfo \
        php$PHP_VERSION-iconv \
    && update-alternatives --install /usr/bin/php php /usr/bin/php$PHP_VERSION 1 \
    && update-alternatives --install /usr/bin/php-config php-config /usr/bin/php-config$PHP_VERSION 1 \
    && update-alternatives --install /usr/bin/phpize phpize /usr/bin/phpize$PHP_VERSION 1

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer --version="${COMPOSER_VERSION}" \
    && composer global require laravel/installer

# Install Node.js and npm
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@latest

# Clean up
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/*

# Set up user and permissions
RUN usermod -u 1000 www-data \
    && usermod -a -G users www-data \
    && mkdir -p /var/www/html \
    && chown -R www-data:www-data /var/www/html

# Copy application files
COPY --chown=www-data:www-data app /var/www/html
COPY php/www.conf /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf
COPY php/php.ini /etc/php/${PHP_VERSION}/fpm/php.ini
COPY ./start.sh /root/start.sh

# Convert line endings and set execution permissions for start.sh
RUN dos2unix /root/start.sh && chmod +x /root/start.sh

# Set working directory
WORKDIR /var/www/html

# Create Laravel required directories and set permissions
RUN mkdir -p \
    storage/app/public \
    storage/framework/cache/data \
    storage/framework/sessions \
    storage/framework/testing \
    storage/framework/views \
    storage/logs \
    storage/database \
    bootstrap/cache \
    packages \
    && chown -R www-data:www-data storage bootstrap/cache packages \
    && chmod -R 775 storage bootstrap/cache packages

EXPOSE 443 80 9000

ENTRYPOINT ["/bin/bash", "/root/start.sh"]