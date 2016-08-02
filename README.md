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

### Development Environment
using VirtualBox & Ubuntu Cloud Image (Mac & Windows)

**Install Tools**

* [VirtualBox][virtualbox] 4.3.10 or greater
* [Vagrant][vagrant] 1.6 or greater
* [Cygwin][cygwin] (if using Windows)

Install `vagrant-vbguest` plugin to auto install VirtualBox Guest Addition to virtual machine.
```
vagrant plugin install vagrant-vbguest
```

[virtualbox]: https://www.virtualbox.org/
[vagrant]: https://www.vagrantup.com/downloads.html
[cygwin]: https://cygwin.com/install.html

**Clone this project**

```
git clone https://github.com/madharjan/docker-nginx
cd docker-nginx
```

**Startup Ubuntu VM on VirtualBox**

```
vagrant up
```

**Build Container**

```
# login to DockerHub
vagrant ssh -c "docker login"  

# build
vagrant ssh -c "cd /vagrant; make"

# test
vagrant ssh -c "cd /vagrant; make test"

# tag
vagrant ssh -c "cd /vagrant; make tag_latest"

# update Makefile & Changelog.md
# release
vagrant ssh -c "cd /vagrant; make release"
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
  madharjan/docker-nginx:1.4.6 /sbin/my_init
```

**Prepare folder on host for container volumes**
```
sudo mkdir -p /opt/docker/nginx/etc/
sudo mkdir -p /opt/docker/nginx/html/
sudo mkdir -p /opt/docker/nginx/log/
```

**Copy default configuration and html files to host**
```
sudo docker cp nginx:/etc/nginx/conf.d/default.conf /opt/docker/nginx/etc/
sudo docker cp nginx:/usr/share/nginx/html/index.html /opt/docker/nginx/html/
sudo docker cp nginx:/usr/share/nginx/html/50x.html /opt/docker/nginx/html/
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
  madharjan/docker-nginx:1.4.6 /sbin/my_init
```

**Restart `nginx`** (runit service)
```
docker exec -t \
  nginx-ssl \
  /bin/bash -c "/usr/bin/sv stop nginx; sleep 1; /usr/bin/sv start nginx;"
```
