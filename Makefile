
NAME = madharjan/docker-nginx
VERSION = 1.10.3

DEBUG ?= true

.PHONY: all build run tests stop clean tag_latest release clean_images

all: build

build:
	docker build \
	 --build-arg NGINX_VERSION=${VERSION} \
	 --build-arg VCS_REF=`git rev-parse --short HEAD` \
	 --build-arg DEBUG=$(DEBUG) \
	 -t $(NAME):$(VERSION) --rm .

run:
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

tests:
	sleep 2
	./bats/bin/bats test/tests.bats

stop:
	docker exec nginx /bin/bash -c "rm -rf /etc/nginx/conf.d/*" || true
	docker exec nginx /bin/bash -c "rm -rf /var/www/html/*" || true
	docker exec nginx_project /bin/bash -c "rm -rf /etc/nginx/conf.d/*" || true
	docker exec nginx_project /bin/bash -c "rm -rf /var/www/html/*" || true
	docker exec nginx_project /bin/bash -c "rm -rf /var/www/html/.git" || true
	docker stop nginx nginx_no_nginx nginx_project || true

clean: stop
	docker rm nginx nginx_no_nginx nginx_project || true
	rm -rf /tmp/nginx || true
	rm -rf /tmp/nginx_project || true

tag_latest:
	docker tag $(NAME):$(VERSION) $(NAME):latest

release: run tests clean tag_latest
	@if ! docker images $(NAME) | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME) version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	docker push $(NAME)
	@echo "*** Don't forget to create a tag. git tag $(VERSION) && git push origin $(VERSION) ***"
	curl -s -X POST https://hooks.microbadger.com/images/madharjan/docker-nginx/JEGoeIhTzcKmaiXUikL3HE6W26k=

clean_images:
	docker rmi $(NAME):latest $(NAME):$(VERSION) || true
