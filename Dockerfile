FROM debian:11.10-slim

ENV COMPOSER_VERSION=2.7.7
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV COMPOSER_MEMORY_LIMIT=-1

USER root

RUN export DEBIAN_FRONTEND=noninteractive; \
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
	php8.3 \
	php8.3-fpm \
	php8.3-cli \
	php8.3-mysql \
	php8.3-curl \
	php8.3-gd \
	php8.3-intl \
	# php8.3-json \
	php8.3-sqlite3 \
	php8.3-xsl \
	php8.3-xml \
	php8.3-zip \
	php8.3-soap \
	php8.3-imagick \
	php8.3-opcache \
	php8.3-sybase \
	php8.3-mbstring \
	php8.3-dom \
	ca-certificates \
	exim4 \
	wget \
	rsync \
	mc \
	openssl
    
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN usermod -u 1000 www-data; \
usermod -a -G users www-data;

RUN chown -R www-data:www-data /var/www/html

RUN composer global require laravel/installer

COPY app /var/www/html
COPY php/www.conf /etc/php/8.3/fpm/pool.d/www.conf
COPY php/php.ini /etc/php/8.3/fpm/php.ini
COPY ./start.sh /root/start.sh

WORKDIR /var/www/html

EXPOSE 443 80 9000

CMD ["/root/start.sh"]