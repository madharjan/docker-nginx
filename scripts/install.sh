#!/bin/bash
set -e
source /build/config/buildconfig
set -x

NGINX_CONFIG_PATH=/build/config

apt-get update
apt-get upgrade -y --no-install-recommends

## Install Nginx and runit service
/build/services/nginx/nginx.sh

cp ${NGINX_CONFIG_PATH}/nginx-default.conf /etc/nginx/conf.d/default.conf
