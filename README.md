# docker-nginx

[![](https://images.microbadger.com/badges/image/madharjan/docker-nginx.svg)](http://microbadger.com/images/madharjan/docker-nginx "Get your own image badge on microbadger.com")

Docker container for Nginx based on [madharjan/docker-base](https://github.com/madharjan/docker-base/)

* Nginx 1.4.6 (docker-nginx)

**Environment**

| Variable       | Default | Example        |
|----------------|---------|----------------|
| DISABLE_NGINX  | 0       | 1 (to disable) |

## Build

**Clone this project**
```
git clone https://github.com/madharjan/docker-nginx
cd docker-nginx
```

**Build Containers**
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

**Tag and Commit to Git**
```
git tag 1.4.6
git push origin 1.4.6
```

## Run Container

### Nginx

**Prepare folder on host for container volumes**
```
sudo mkdir -p /opt/docker/nginx/etc/
sudo mkdir -p /opt/docker/nginx/html/
sudo mkdir -p /opt/docker/nginx/log/
```

**Run `docker-nginx`**
```
docker stop nginx
docker rm nginx

docker run -d \
  -p 80:80 \
  -v /opt/docker/nginx/etc:/etc/nginx/conf.d \
  -v /opt/docker/nginx/html:/usr/share/nginx/html \
  -v /opt/docker/nginx/log:/var/log/nginx \
  --name nginx \
  madharjan/docker-nginx:1.4.6
```

**Systemd Unit File**
```
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
ExecStartPre=-/usr/bin/docker pull madharjan/docker-nginx:1.4.6

ExecStart=/usr/bin/docker run \
  -p 80:80 \
  -v /opt/docker/nginx/etc/conf.d:/etc/nginx/conf.d \
  -v /opt/docker/nginx/html:/usr/share/nginx/html \
  -v /opt/docker/nginx/log:/var/log/nginx \
  --name nginx \
  madharjan/docker-nginx:1.4.6

ExecStop=/usr/bin/docker stop -t 2 nginx

[Install]
WantedBy=multi-user.target
```
