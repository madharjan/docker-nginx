
NAME = madharjan/docker-nginx
VERSION = 1.4.6

.PHONY: all build clean_images test tag_latest release

all: build

build:
	docker build -t $(NAME):$(VERSION) --rm .
	docker build -f Dockerfile.onbuild -t $(NAME)-onbuild:$(VERSION) --rm .
clean_images:
	docker rmi $(NAME):latest $(NAME):$(VERSION) || true
	docker rmi $(NAME):latest $(NAME)-onbuild:$(VERSION) || true

test:
	env NAME=$(NAME) VERSION=$(VERSION) ./test/test.sh

tag_latest:
	docker tag $(NAME):$(VERSION) $(NAME):latest
	docker tag $(NAME)-onbuild:$(VERSION) $(NAME)-onbuild:latest

release: test tag_latest
	@if ! docker images $(NAME) | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME) version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@if ! docker images $(NAME)-onbuild | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME)-onbuild version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@if ! head -n 1 Changelog.md | grep -q 'release date'; then echo 'Please note the release date in Changelog.md.' && false; fi
	docker push $(NAME)
	docker push $(NAME)-onbuild
	@echo "*** Don't forget to create a tag. git tag $(VERSION) && git push origin $(VERSION) ***"
