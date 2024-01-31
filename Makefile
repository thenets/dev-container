PRODUCTION_IMAGE_TAG = quay.io/thenets/dev-container:latest


# ----------------- Build -----------------

## Build production container image
production-build:
	docker build -t $(PRODUCTION_IMAGE_TAG) \
		-f ./src/Containerfile \
		./src/

## Shell into the production container
production-shell:
	docker run -it --rm \
		--privileged \
		$(PRODUCTION_IMAGE_TAG) \
		bash

## Push the production container image to the registry
production-push:
	docker push $(PRODUCTION_IMAGE_TAG)

# ----------------- Test -----------------
TEST_ROOTLESS_IMAGE = thenets/dev-container:rootless

## Run all tests
test:
# - I added them in multiple lines to make the target more readable
	make test-rootful_docker-in-rootless_podman
	make test-rootful_docker-in-rootful_podman

_test-build: production-build
	docker build -t $(TEST_ROOTLESS_IMAGE) \
		-f ./tests/rootless.containerfile \
		./tests/

test-rootful_docker-in-rootless_podman: _test-build
	docker run -it --rm \
		--privileged \
		$(TEST_ROOTLESS_IMAGE) \
		podman run -it --rm docker.io/busybox uname -a

test-rootful_docker-in-rootful_podman: _test-build
	docker run -it --rm \
		--privileged \
		$(PRODUCTION_IMAGE_TAG) \
		podman run -it --rm docker.io/busybox uname -a
