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

if [ ! -f /usr/share/nginx/html/index.html ]; then
  cp /config/usr/share/nginx/html/index.html /usr/share/nginx/html/index.html
  cp /config/usr/share/nginx/html/50x.html /usr/share/nginx/html/50x.html
  cp /config/usr/share/nginx/html/favicon.ico /usr/share/nginx/html/favicon.ico

  chown -R www-data:www-data /usr/share/nginx/html/*
fi
