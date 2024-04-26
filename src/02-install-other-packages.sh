#!/bin/bash

set -ex

# Python packages
pip install \
    ansible-navigator \
    ansible-creator \
    ansible-lint

# -- yq
if ! command -v yq &> /dev/null; then
    echo "yq not found in PATH, installing it..."
    curl -sfL -o /usr/bin/yq https://github.com/mikefarah/yq/releases/download/v4.43.1/yq_linux_amd64
    chmod 755 /usr/bin/yq
fi

# -- AWS CLI
if ! command -v aws &> /dev/null; then
    echo "aws not found in PATH, installing it..."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip -qq awscliv2.zip
    ./aws/install -i /usr/local/aws-cli -b /usr/bin
    rm -f ./awscliv2.zip
    rm -rf ./aws/
fi

# -- ROSA CLI
if ! command -v rosa &> /dev/null; then
    echo "rosa not found in PATH, installing it..."
    wget -q https://github.com/openshift/rosa/releases/download/v1.2.37/rosa-linux-amd64
    chmod +x rosa-linux-amd64
    mv rosa-linux-amd64 /usr/local/bin/rosa
fi
