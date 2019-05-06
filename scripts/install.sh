#!/bin/bash
set -e
export LC_ALL=C
export DEBIAN_FRONTEND=noninteractive

if [ "${DEBUG}" = true ]; then
  set -x
fi

NGINX_CONFIG_PATH=/build/config/nginx

apt-get update

## Install Project
apt-get install -y --no-install-recommends git-core

cp /build/services/15-project.sh /etc/my_init.d
chmod 750 /etc/my_init.d/15-project.sh

## Install Nginx and runit service
/build/services/nginx/nginx.sh

mkdir -p /config/etc/nginx/conf.d
mkdir -p /config/var/www/html

cp ${NGINX_CONFIG_PATH}/default.conf /config/etc/nginx/conf.d/default.conf
cp ${NGINX_CONFIG_PATH}/index.html /config/var/www/html/index.html
cp ${NGINX_CONFIG_PATH}/403.html /config/var/www/html/403.html
cp ${NGINX_CONFIG_PATH}/404.html /config/var/www/html/404.html
cp ${NGINX_CONFIG_PATH}/405.html /config/var/www/html/405.html
cp ${NGINX_CONFIG_PATH}/50x.html /config/var/www/html/50x.html
cp ${NGINX_CONFIG_PATH}/favicon.ico /config/var/www/html/favicon.ico

mkdir -p /etc/my_init.d
cp /build/services/20-nginx.sh /etc/my_init.d
chmod 750 /etc/my_init.d/20-nginx.sh

cp /build/bin/gen-systemd-unit /usr/local/bin
chmod 750 /usr/local/bin/nginx-systemd-unit

