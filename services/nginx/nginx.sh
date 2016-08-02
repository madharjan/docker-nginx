#!/bin/bash
set -e
source /build/config/buildconfig
set -x

NGINX_BUILD_PATH=/build/services/nginx

## Install Nginx.
$minimal_apt_get_install nginx

cp ${NGINX_BUILD_PATH}/nginx.conf /etc/nginx/
rm -rf /etc/nginx/sites-enabled
rm -rf /etc/nginx/sites-available

mkdir -p /etc/service/nginx
cp ${NGINX_BUILD_PATH}/nginx.runit /etc/service/nginx/run
chmod 750 /etc/service/nginx/run

mkdir -p /etc/service/nginx-log-forwarder
cp ${NGINX_BUILD_PATH}/nginx-log-forwarder.runit /etc/service/nginx-log-forwarder/run
chmod 750 /etc/service/nginx-log-forwarder/run

mkdir -p /var/lib/nginx
chown -R www-data:www-data /var/lib/nginx

## Configure logrotate.
sed -i 's|invoke-rc.d nginx rotate|sv 1 nginx|' /etc/logrotate.d/nginx
