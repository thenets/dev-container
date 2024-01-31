#!/bin/bash

# Rootful container support for Podman and Docker

set -ex

# Podman
dnf install -y podman fuse-overlayfs --exclude container-selinux

# Docker
curl -sSL get.docker.io | sh
