#!/bin/bash
set -e
source /build/config/buildconfig
set -x

NGINX_CONFIG_PATH=/build/config/nginx

apt-get update

## Install Nginx and runit service
/build/services/nginx/nginx.sh

cp ${NGINX_CONFIG_PATH}/default.conf /etc/nginx/conf.d/default.conf
