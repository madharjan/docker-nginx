# docker-nginx

[![Build Status](https://travis-ci.com/madharjan/docker-nginx.svg?branch=master)](https://travis-ci.com/madharjan/docker-nginx)
[![Layers](https://images.microbadger.com/badges/image/madharjan/docker-nginx.svg)](http://microbadger.com/images/madharjan/docker-nginx)

Docker container for Nginx based on [madharjan/docker-base](https://github.com/madharjan/docker-base/)

## Features

* Nginx error log forwarded to Docker logs
* Bats ([bats-core/bats-core](https://github.com/bats-core/bats-core)) based test cases

## Nginx 1.10.3 (docker-nginx)

### Environment

| Variable       | Default | Example        |
|----------------|---------|----------------|
| DISABLE_NGINX  | 0       | 1 (to disable) |

## Build

### Clone this project

```bash
git clone https://github.com/madharjan/docker-nginx
cd docker-nginx
```

### Build Container
```
# login to DockerHub
docker login

# build
make

# tests
make run
make tests
make clean

# tag
make tag_latest

# update Changelog.md
# release
make release
```

### Tag and Commit to Git

```bash
git tag 1.10.3
git push origin 1.10.3
```

# Run Container

### Nginx

### Prepare folder on host for container volumes

```bash
sudo mkdir -p /opt/docker/nginx/etc/
sudo mkdir -p /opt/docker/nginx/html/
sudo mkdir -p /opt/docker/nginx/log/
```

### Run `docker-nginx`

```bash
docker stop nginx
docker rm nginx

docker run -d \
  -p 80:80 \
  -v /opt/docker/nginx/etc:/etc/nginx/conf.d \
  -v /opt/docker/nginx/html:/var/www/html \
  -v /opt/docker/nginx/log:/var/log/nginx \
  --name nginx \
  madharjan/docker-nginx:1.10.3
```

### Systemd Unit File

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
