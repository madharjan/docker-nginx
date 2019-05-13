#!/bin/bash

set -e

if [ "${DEBUG}" = true ]; then
  set -x
fi

DISABLE_NGINX=${DISABLE_NGINX:-0}
DEFAULT_PROXY=${DEFAULT_PROXY:-0}
PROXY_HOST=${PROXY_HOST:-}
PROXY_PORT=${PROXY_PORT:-8080}
PROXY_SCHEME=${PROXY_SCHEME:-http}

if [ ! "${DISABLE_NGINX}" -eq 0 ]; then
  touch /etc/service/nginx/down
  touch /etc/service/nginx-log-forwarder/down
else
  rm -f /etc/service/nginx/down
  rm -f /etc/service/nginx-log-forwarder/down
fi

if [ -f /etc/nginx/conf.d/default.conf ]; then
   echo "Nginx config already exists"
else
  if [ ! "${DEFAULT_PROXY}" -eq 0 ]; then
    if [ -n "${PROXY_HOST}" ]; then
      cp /config/etc/nginx/conf.d/proxy.conf /etc/nginx/conf.d/default.conf
      sed -i "s/##PROXY_HOST##/${PROXY_HOST}/" /etc/nginx/conf.d/default.conf
      sed -i "s/##PROXY_PORT##/${PROXY_PORT}/" /etc/nginx/conf.d/default.conf
      sed -i "s/##PROXY_SCHEME##/${PROXY_SCHEME}/" /etc/nginx/conf.d/default.conf
    fi
  else 
    cp /config/etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf
  fi
fi

if [ -f /var/www/html/index.html ]; then
   echo "Nginx content already exists"
else
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
