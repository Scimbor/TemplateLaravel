FROM debian:bookworm-slim 

ARG COMPOSER_VERSION=2.8.1
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV COMPOSER_MEMORY_LIMIT=-1

USER root

RUN export DEBIAN_FRONTEND=noninteractive; \
    apt-get update; \
    apt-get install --no-install-recommends --no-install-suggests -y locales; \
    echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen; \
    locale-gen; \
    echo 'export LANG=en_US.UTF-8' | tee -a /etc/profile | tee -a /etc/bash.bashrc; \
    dpkg-reconfigure locales; \
    ## Instalacja narzędzi systemowych
    apt-get install --no-install-recommends --no-install-suggests -y \
        wget \
        curl \
        gnupg \
        ca-certificates \
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
        exim4; \
    ## Dodanie repozytorium Sury dla PHP 8.3
    wget -qO - https://packages.sury.org/php/apt.gpg | gpg --dearmor -o /usr/share/keyrings/sury-php.gpg; \
    echo "deb [signed-by=/usr/share/keyrings/sury-php.gpg] https://packages.sury.org/php/ bookworm main" | tee /etc/apt/sources.list.d/php.list; \
    apt-get update; \
    ## Instalacja PHP 8.3 i rozszerzeń
    apt-get install --no-install-recommends --no-install-suggests -y \
        php8.3 \
        php8.3-fpm \
        php8.3-cli \
        php8.3-mysql \
        php8.3-curl \
        php8.3-gd \
        php8.3-intl \
        php8.3-sqlite3 \
        php8.3-xsl \
        php8.3-xml \
        php8.3-zip \
        php8.3-soap \
        php8.3-imagick \
        php8.3-opcache \
        php8.3-mbstring \
        php8.3-dom; \
    ## Ustawienie domyślnej wersji PHP na 8.3
    update-alternatives --set php /usr/bin/php8.3; \
    update-alternatives --set php-config /usr/bin/php-config8.3; \
    update-alternatives --set phpize /usr/bin/phpize8.3; \
    ## Instalacja Composera
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer --version="${COMPOSER_VERSION}"; \
    ## Czystka
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

RUN usermod -u 1000 www-data; \
    usermod -a -G users www-data

RUN chown -R www-data:www-data /var/www/html

RUN composer global require laravel/installer

RUN curl -fsSL https://deb.nodesource.com/setup_23.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm@latest

COPY app /var/www/html
COPY php/www.conf /etc/php/8.3/fpm/pool.d/www.conf
COPY php/php.ini /etc/php/8.3/fpm/php.ini
COPY ./start.sh /root/start.sh

WORKDIR /var/www/html

EXPOSE 443 80 9000

ENTRYPOINT ["/root/start.sh"]