#!/bin/bash

/usr/sbin/service php8.2-fpm start
/usr/sbin/service nginx start
tail -f /dev/null