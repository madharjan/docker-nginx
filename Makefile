
NAME = madharjan/docker-nginx
VERSION = 1.10.3

DEBUG ?= true

DOCKER_USERNAME ?= $(shell read -p "DockerHub Username: " pwd; echo $$pwd)
DOCKER_PASSWORD ?= $(shell stty -echo; read -p "DockerHub Password: " pwd; stty echo; echo $$pwd)
DOCKER_LOGIN ?= $(shell cat ~/.docker/config.json | grep "docker.io" | wc -l)

.PHONY: all build run test stop clean tag_latest release clean_images

all: build

docker_login:
ifeq ($(DOCKER_LOGIN), 1)
		@echo "Already login to DockerHub"
else
		@docker login -u $(DOCKER_USERNAME) -p $(DOCKER_PASSWORD)
endif

build:
	docker build \
	 --build-arg NGINX_VERSION=$(VERSION) \
	 --build-arg VCS_REF=`git rev-parse --short HEAD` \
	 --build-arg DEBUG=$(DEBUG)\
	 -t $(NAME):$(VERSION) --rm .

run:
	@if ! docker images $(NAME) | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME) version $(VERSION) is not yet built. Please run 'make build'"; false; fi

	rm -rf /tmp/nginx
	mkdir -p /tmp/nginx/etc
	mkdir -p /tmp/nginx/html

	docker run -d \
		-e DEBUG=$(DEBUG) \
		-v /tmp/nginx/etc:/etc/nginx/conf.d \
		-v /tmp/nginx/html:/var/www/html \
		--name nginx $(NAME):$(VERSION) \
		/sbin/my_init --log-level 3

	sleep 2

	docker run -d \
		-e DEBUG=$(DEBUG) \
		-e DISABLE_NGINX=1 \
		--name nginx_no_nginx $(NAME):$(VERSION)

	sleep 2

	rm -rf /tmp/nginx_project
	mkdir -p /tmp/nginx_project/etc
	mkdir -p /tmp/nginx_project/html

	docker run -d \
		-e DEBUG=$(DEBUG) \
		-v /tmp/nginx_project/etc:/etc/nginx/conf.d \
		-v /tmp/nginx_project/html:/var/www/html \
		-e INSTALL_PROJECT=1 \
		-e PROJECT_GIT_REPO=https://github.com/BlackrockDigital/startbootstrap-creative.git \
		-e PROJECT_GIT_TAG=v5.0.0 \
		--name nginx_project $(NAME):$(VERSION) 

	sleep 4

	docker run -d \
		--link nginx_project:project \
		-e DEBUG=$(DEBUG) \
		-e DEFAULT_PROXY=1 \
		-e PROXY_HOST=project \
		-e PROXY_PORT=80 \
		--name nginx_proxy $(NAME):$(VERSION)

	sleep 2

test:
	sleep 2
	./bats/bin/bats test/tests.bats

stop:
	docker exec nginx /bin/bash -c "rm -rf /etc/nginx/conf.d/*" 2> /dev/null || true
	docker exec nginx /bin/bash -c "rm -rf /var/www/html/*" 2> /dev/null || true
	docker exec nginx_project /bin/bash -c "rm -rf /etc/nginx/conf.d/*" 2> /dev/null || true
	docker exec nginx_project /bin/bash -c "rm -rf /var/www/html/*" 2> /dev/null || true
	docker exec nginx_project /bin/bash -c "rm -rf /var/www/html/.git" 2> /dev/null || true
	docker stop nginx nginx_no_nginx nginx_project nginx_proxy 2> /dev/null || true

clean: stop
	docker rm nginx nginx_no_nginx nginx_project nginx_proxy 2> /dev/null || true
	rm -rf /tmp/nginx || true
	rm -rf /tmp/nginx_project || true
	docker images | grep "<none>" | awk '{print$3 }' | xargs docker rmi 2> /dev/null || true

publish: docker_login run test clean
	docker push $(NAME)

tag_latest:
	docker tag $(NAME):$(VERSION) $(NAME):latest

release: docker_login  run test clean tag_latest
	docker push $(NAME)

clean_images: clean
	docker rmi $(NAME):latest $(NAME):$(VERSION) 2> /dev/null || true
	docker logout 


