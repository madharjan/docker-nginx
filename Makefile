
NAME = madharjan/docker-nginx
VERSION = 1.4.6

.PHONY: all build run tests clean tag_latest release clean_images

all: build

build:
	docker build \
	 --build-arg NGINX_VERSION=${VERSION} \
	 --build-arg VCS_REF=`git rev-parse --short HEAD` \
	 --build-arg DEBUG=true \
	 -t $(NAME):$(VERSION) --rm .

run:
	rm -rf /tmp/nginx
	mkdir -p /tmp/nginx/etc
	mkdir -p /tmp/nginx/html
	docker run -d \
		-e DEBUG=true \
		-v /tmp/nginx/etc:/etc/nginx/conf.d \
		-v /tmp/nginx/html:/usr/share/nginx/html \
		--name nginx $(NAME):$(VERSION)

	docker run -d \
		-e DEBUG=true \
		-e DISABLE_NGINX=1 \
		--name nginx_no_nginx $(NAME):$(VERSION)

tests:
		./bats/bin/bats test/tests.bats

clean:
	docker exec nginx /bin/bash -c "rm -rf /etc/nginx/conf.d/*" || true
	docker exec nginx /bin/bash -c "rm -rf /usr/share/nginx/html/*" || true
	docker stop nginx nginx_no_nginx || true
	docker rm nginx nginx_no_nginx || true
	rm -rf /tmp/nginx || true

tag_latest:
	docker tag $(NAME):$(VERSION) $(NAME):latest

release: run tests clean tag_latest
	@if ! docker images $(NAME) | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME) version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@if ! head -n 1 Changelog.md | grep -q 'release date'; then echo 'Please note the release date in Changelog.md.' && false; fi
	docker push $(NAME)
	@echo "*** Don't forget to create a tag. git tag $(VERSION) && git push origin $(VERSION) ***"
	curl -X POST https://hooks.microbadger.com/images/madharjan/docker-nginx/Y7V64vqIP3mXfQarb7lAU8uE2XU=

clean_images:
	docker rmi $(NAME):latest $(NAME):$(VERSION) || true
