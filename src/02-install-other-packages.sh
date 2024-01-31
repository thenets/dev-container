#!/bin/bash

set -ex

# Docker
curl -sSL get.docker.io | sh

# Python packages
pip install \
    ansible-navigator \
    ansible-creator \
    ansible-lint
#pip install ansible-dev-tools
