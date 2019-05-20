# docker-nginx

[![Build Status](https://travis-ci.com/madharjan/docker-nginx.svg?branch=master)](https://travis-ci.com/madharjan/docker-nginx)
[![Layers](https://images.microbadger.com/badges/image/madharjan/docker-nginx.svg)](http://microbadger.com/images/madharjan/docker-nginx)

Docker container for Nginx based on [madharjan/docker-base](https://github.com/madharjan/docker-base/)

## Features

* Nginx error log forwarded to Docker logs
* Bats [bats-core/bats-core](https://github.com/bats-core/bats-core) based test cases
* Deploy/update web projects from git
* Setup reverse proxy

## Nginx 1.10.3 (docker-nginx)

### Environment

| Variable             | Default          | Example                                                          |
|----------------------|------------------|------------------------------------------------------------------|
| DISABLE_NGINX        | 0                | 1 (to disable)                                                   |
| INSTALL_PROJECT      | 0                | 1 (to enable)                                                    |
| PROJECT_GIT_REPO     |                  | https://github.com/BlackrockDigital/startbootstrap-creative.git  |
| PROJECT_GIT_TAG      | HEAD             | v5.1.4                                                           |
| DEFAULT_PROXY        | 0                | 1 (to enable)                                                    |
| PROXY_SCHEME         | http             | https                                                            |
| PROXY_HOST           |                  | 127.0.0.1                                                        |
| PROXY_PORT           | 8080             | 8000                                                             |
| LINK_PROXY_CONTAINER |                  |                                                                  |

## Build

```bash
# clone project
git clone https://github.com/madharjan/docker-nginx
cd docker-nginx

# build
make

# tests
make run
make test

# clean
make clean
```

## Run

**Note**: update environment variables below as necessary

```bash
# prepare foldor on host for container volumes
sudo mkdir -p /opt/docker/nginx/etc/conf.d
sudo mkdir -p /opt/docker/nginx/html/
sudo mkdir -p /opt/docker/nginx/log/

# stop & remove previous instances
docker stop nginx
docker rm nginx

# run container
docker run -d \
  -p 80:80 \
  -v /opt/docker/nginx/etc/conf.d:/etc/nginx/conf.d \
  -v /opt/docker/nginx/html:/var/www/html \
  -v /opt/docker/nginx/log:/var/log/nginx \
  --name nginx \
  madharjan/docker-nginx:1.10.3
```

## Systemd Unit File

**Note**: update environment variables below as necessary

```txt
[Unit]
Description=Nginx

After=docker.service

[Service]
TimeoutStartSec=0

ExecStartPre=-/bin/mkdir -p /opt/docker/nginx/etc/conf.d
ExecStartPre=-/bin/mkdir -p /opt/docker/nginx/html
ExecStartPre=-/bin/mkdir -p /opt/docker/nginx/log
ExecStartPre=-/usr/bin/docker stop nginx
ExecStartPre=-/usr/bin/docker rm nginx
ExecStartPre=-/usr/bin/docker pull madharjan/docker-nginx:1.10.3

ExecStart=/usr/bin/docker run \
  -p 80:80 \
  -v /opt/docker/nginx/etc/conf.d:/etc/nginx/conf.d \
  -v /opt/docker/nginx/html:/var/www/html \
  -v /opt/docker/nginx/log:/var/log/nginx \
  --name nginx \
  madharjan/docker-nginx:1.10.3

ExecStop=/usr/bin/docker stop -t 2 nginx

[Install]
WantedBy=multi-user.target
```

## Generate Systemd Unit File

| Variable             | Default          | Example                                                          |
|----------------------|------------------|------------------------------------------------------------------|
| PORT                 |                  | 8080                                                             |
| VOLUME_HOME          | /opt/docker      | /opt/data                                                        |
| NAME                 | ngnix            |                                                                  |
| INSTALL_PROJECT      | 0                | 1 (to enable)                                                    |
| PROJECT_GIT_REPO     |                  | https://github.com/BlackrockDigital/startbootstrap-creative.git  |
| PROJECT_GIT_TAG      | HEAD             | v5.1.4                                                           |
| DEFAULT_PROXY        | 0                | 1 (to enable)                                                    |
| PROXY_SCHEME         | http             | https                                                            |
| PROXY_HOST           |                  | 127.0.0.1                                                        |
| PROXY_PORT           | 8080             | 8000                                                             |
| LINK_CONTAINERS      |                  | nginx-web2py:app,nginx:website                                   |

### With deploy web projects

```bash
# generate nginx.service
docker run --rm \
  -e PORT=80 \
  -e INSTALL_PROJECT=1 \
  -e PROJECT_GIT_REPO=https://github.com/BlackrockDigital/startbootstrap-creative.git \
  -e PROJECT_GIT_TAG=v5.1.4 \
  madharjan/docker-nginx:1.10.3 \
  nginx-systemd-unit | \
  sudo tee /etc/systemd/system/nginx.service

sudo systemctl enable nginx
sudo systemctl start nginx
```

### With reverse proxy

```bash
# generate nginx.service
docker run --rm \
  -e PORT=80 \
  -e DEFAULT_PROXY=1 \
  -e PROXY_HOST=odoo \
  -e PROXY_PORT=8080 \
  -e LINK_CONTAINERS=odoo:odoo,nginx:website \
  madharjan/docker-nginx:1.10.3 \
  nginx-systemd-unit | \
  sudo tee /etc/systemd/system/nginx.service

sudo systemctl enable nginx
sudo systemctl start nginx
```

## Add virtualhost reverse proxy config

| Variable             | Default          | Example                                                          |
|----------------------|------------------|------------------------------------------------------------------|
| PROXY_VHOST_NAME     |                  | myapp.local                                                      |
| PROXY_SCHEME         | http             | https                                                            |
| PROXY_HOST           |                  | 127.0.0.1                                                        |
| PROXY_PORT           | 8080             | 8000                                                             |

```bash
# add proxy.conf
docker exec -it \
  -e PROXY_VHOST_NAME=myapp \
  -e PROXY_HOST=172.18.0.5 \
  -e PROXY_PORT=8080 \
  nginx \
  nginx-vhost-proxy-conf
```
