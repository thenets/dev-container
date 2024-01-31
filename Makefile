RELEASE_IMAGE_TAG ?= quay.io/thenets/dev-container:latest

# ----------------- Build -----------------

## Build the container image (dev)
build:
	docker build -t $(RELEASE_IMAGE_TAG) \
		-f ./src/Containerfile \
		$(ADDITIONAL_BUILD_ARGS) \
		./src/

## Build release container image (squash the layers)
release-build:
	podman build -t $(RELEASE_IMAGE_TAG) \
		-f ./src/Containerfile \
		--squash \
		./src/

## Shell into the release container
release-shell:
	podman run -it --rm \
		--privileged \
		$(RELEASE_IMAGE_TAG) \
		bash

## Push the release container image to the registry
release-push:
	podman push $(RELEASE_IMAGE_TAG)

# ----------------- Test -----------------
TEST_ROOTLESS_IMAGE ?= thenets/dev-container:rootless

## Run all tests
test:
# - I added them in multiple lines to make the target more readable
	make test-rootful_docker-in-rootful_docker-using_socket
	make test-rootful_podman-in-rootful_docker

_test-build: release-build
	docker build -t $(TEST_ROOTLESS_IMAGE) \
		-f ./tests/rootless.containerfile \
		./tests/

test-rootful_podman-in-rootful_docker: _test-build
	docker run --rm \
		--privileged \
		$(RELEASE_IMAGE_TAG) \
		podman run --rm docker.io/busybox uname -a

test-rootful_docker-in-rootful_docker-using_socket: _test-build
	docker run --rm \
		--privileged \
		-v /var/run/docker.sock:/var/run/docker.sock:rw \
		$(RELEASE_IMAGE_TAG) \
		docker run --rm docker.io/busybox uname -a

# WIP rootless
test-rootless_podman-in-rootful_docker: _test-build
# - Easier scenario
	docker run --rm \
		--privileged \
		$(TEST_ROOTLESS_IMAGE) \
			podman run --detach --name=podmanctr --net=host --security-opt label=disable --security-opt seccomp=unconfined --device /dev/fuse:rw -v /var/lib/mycontainer:/var/lib/containers:Z --privileged docker.io/busybox sh -c 'while true ;do sleep 100000 ; done'

# - Hard scenario, using defaults
	docker run --rm \
		--privileged \
		$(TEST_ROOTLESS_IMAGE) \
		podman run --rm docker.io/busybox uname -a