RELEASE_IMAGE_TAG ?= quay.io/thenets/dev-container:latest

# ----------------- Build -----------------

## Build release container image
release-build:
	docker build -t $(RELEASE_IMAGE_TAG) \
		-f ./src/Containerfile \
		./src/

## Shell into the RELEASE container
release-shell:
	docker run -it --rm \
		--privileged \
		$(RELEASE_IMAGE_TAG) \
		bash

## Push the RELEASE container image to the registry
release-push:
	docker push $(RELEASE_IMAGE_TAG)

# ----------------- Test -----------------
TEST_ROOTLESS_IMAGE ?= thenets/dev-container:rootless

## Run all tests
test:
# - I added them in multiple lines to make the target more readable
	make test-rootless_podman-in-rootful_docker
	make test-rootful_podman-in-rootful_docker

_test-build: release-build
	docker build -t $(TEST_ROOTLESS_IMAGE) \
		-f ./tests/rootless.containerfile \
		./tests/

test-rootless_podman-in-rootful_docker: _test-build
	docker run -it --rm \
		--privileged \
		$(TEST_ROOTLESS_IMAGE) \
		podman run -it --rm docker.io/busybox uname -a

test-rootful_podman-in-rootful_docker: _test-build
	docker run -it --rm \
		--privileged \
		$(RELEASE_IMAGE_TAG) \
		podman run -it --rm docker.io/busybox uname -a
