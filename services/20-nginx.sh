#!/bin/bash

set -e

if [ "${DEBUG}" = true ]; then
  set -x
fi

DISABLE_NGINX=${DISABLE_NGINX:-0}

if [ ! "${DISABLE_NGINX}" -eq 0 ]; then
  touch /etc/service/nginx/down
  touch /etc/service/nginx-log-forwarder/down
else
  rm -f /etc/service/nginx/down
  rm -f /etc/service/nginx-log-forwarder/down
fi

if [ ! -f /etc/nginx/conf.d/default.conf ]; then
  cp /config/etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf
fi

if [ ! -f /var/www/html/index.html ]; then
  mkdir -p /var/www/html
  cp /config/var/www/html/index.html /var/www/html/index.html
  cp /config/var/www/html/403.html /var/www/html/403.html
  cp /config/var/www/html/404.html /var/www/html/404.html
  cp /config/var/www/html/405.html /var/www/html/405.html
  cp /config/var/www/html/50x.html /var/www/html/50x.html
  cp /config/var/www/html/favicon.ico /var/www/html/favicon.ico

  chown -R www-data:www-data /var/www/html/*
  touch /var/www/html/.403test
  chmod 640 /var/www/html/.403test
fi
