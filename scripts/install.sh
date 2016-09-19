#!/bin/bash
set -e
export LC_ALL=C
export DEBIAN_FRONTEND=noninteractive

if [ "${DEBUG}" == true ]; then
  set -x
fi

NGINX_CONFIG_PATH=/build/config/nginx

apt-get update

## Install Nginx and runit service
/build/services/nginx/nginx.sh

cp ${NGINX_CONFIG_PATH}/default.conf /etc/nginx/conf.d/default.conf
