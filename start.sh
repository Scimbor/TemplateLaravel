#!/bin/bash

composer install

/usr/sbin/service php8.3-fpm start
/usr/sbin/service nginx start
tail -f /dev/null