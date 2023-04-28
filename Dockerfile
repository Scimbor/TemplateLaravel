FROM debian:bullseye-slim

ENV COMPOSER_VERSION = 2.5.5
ENV COMPOSER_ALLOW_SUPERUSER = 1
ENV COMPOSER_MEMORY_LIMIT=-1

USER root

RUN export DEBIAN_FRONTEND=noninteractive; \
	\
	apt-get update; \
	apt-get install --no-install-recommends --no-install-suggests -y locales; \
	echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen; \
	locale-gen; \
	export LANG=en_US.UTF8; \
	echo 'export LANG=en_US.UTF8' | tee -a /etc/profile | tee -a /etc/bash.bashrc; \
	dpkg-reconfigure locales; \
	##
	apt-get install  --no-install-recommends --no-install-suggests -y wget gnupg ca-certificates apt-transport-https; \
	wget -q https://packages.sury.org/php/apt.gpg -O- | apt-key add -; \
	echo "deb https://packages.sury.org/php/ bullseye main" | tee -a /etc/apt/sources.list.d/php.list; \
	apt-get update; \
	##
	apt-get install --no-install-recommends --no-install-suggests -y -m \
	curl \
	supervisor \
	logrotate \
	nginx-light \
	unzip \
	php-xdebug \
	cron \
	git \
	nano \
	php8.2 \
	php8.2-fpm \
	php8.2-cli \
	php8.2-mysql \
	php8.2-curl \
	php8.2-gd \
	php8.2-intl \
	# php8.2-json \
	php8.2-sqlite3 \
	php8.2-xsl \
	php8.2-xml \
	php8.2-zip \
	php8.2-soap \
	php8.2-imagick \
	php8.2-opcache \
	php8.2-sybase \
	php8.2-mbstring \
	php8.2-dom \
	ca-certificates \
	exim4 \
	wget \
	rsync \
	mc
    
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer\
    openssl req -x509 -nodes -days 365 \
    -subj  "/C=CA/ST=QC/O=Company Inc/CN=example.com" \
     -newkey rsa:2048 -keyout etc/ssl/private/nginx-selfsigned.key \
     -out etc/ssl/certs/nginx-selfsigned.crt;

RUN usermod -u 1000 www-data; \
usermod -a -G users www-data;

RUN composer global require laravel/installer

COPY app /var/www/html
COPY certs/certificate.crt /etc/ssl/certs/certificate.crt
COPY certs/privateKey.key /etc/ssl/private/private.key
COPY php/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY php/php.ini /etc/php/8.2/fpm/php.ini
COPY ./start.sh /root/start.sh

WORKDIR /var/www/html

EXPOSE 443 80 9000

CMD ["/root/start.sh"]