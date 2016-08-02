FROM madharjan/docker-base:14.04
MAINTAINER Madhav Raj Maharjan <madhav.maharjan@gmail.com>

LABEL description="Docker container for Nginx"
LABEL  os_version="Ubuntu 14.04"

ENV HOME /root

RUN mkdir -p /build
COPY . /build

RUN /build/scripts/install.sh
RUN /build/scripts/cleanup.sh

VOLUME /etc/nginx/conf.d
VOLUME /usr/share/nginx/html
VOLUME /var/log/nginx

WORKDIR /etc/nginx

CMD ["/sbin/my_init"]

EXPOSE 80
