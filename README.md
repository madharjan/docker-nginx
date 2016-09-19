# docker-nginx
Docker container for Nginx based on [madharjan/docker-base](https://github.com/madharjan/docker-base/)

* Nginx 1.4.6 (docker-nginx)

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

# test
make test

# tag
make tag_latest

# update Makefile & Changelog.md
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

**Run `docker-nginx` container**
```
docker run -d -t \
  --name nginx \
  madharjan/docker-nginx:1.4.6
```

**Prepare folder on host for container volumes**
```
sudo mkdir -p /opt/docker/nginx/etc/
sudo mkdir -p /opt/docker/nginx/html/
sudo mkdir -p /opt/docker/nginx/log/
```

**Copy default configuration and html files to host**
```
sudo docker exec nginx tar Ccf /etc/nginx - conf.d | tar Cxf /opt/docker/nginx/etc -
sudo docker exec nginx tar Ccf /usr/share/nginx - html | tar Cxf /opt/docker/nginx -
```

**Update Nginx configuration as necessary**
```
sudo vi /opt/docker/nginx/etc/default.conf
```

**Update Webpage as necessary**
```
sudo vi /opt/docker/nginx/html/index.html
```

**Run `docker-nginx` with updated configuration**
```
docker stop nginx
docker rm nginx

docker run -d -t \
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

ExecStartPre=-/bin/mkdir -p /opt/docker/nginx/html
ExecStartPre=-/bin/mkdir -p /opt/docker/nginx/etc/conf.d
ExecStartPre=-/usr/bin/docker stop nginx
ExecStartPre=-/usr/bin/docker rm nginx
ExecStartPre=-/usr/bin/docker pull madharjan/docker-nginx:1.4.6

ExecStart=/usr/bin/docker run \
  -p 80:80 \
  -v /opt/docker/nginx/html:/usr/share/nginx/html \
  -v /opt/docker/nginx/etc/conf.d:/etc/nginx/conf.d \
  -v /opt/docker/nginx/log:/var/log/nginx \
  --name nginx \
  madharjan/docker-nginx:1.4.6

ExecStop=/usr/bin/docker stop -t 2 nginx

[Install]
WantedBy=multi-user.target
```
