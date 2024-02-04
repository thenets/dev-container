#!/bin/bash

set -ex

# OS upgrade
dnf upgrade -y

# Repos
dnf install -y dnf-plugins-core
dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo

# Groups
dnf groupinstall -y "Development Tools" "Development Libraries"

# OS packages
dnf install -y \
    sudo make git htop procps-ng net-tools iputils \
    iproute bind9-next-utils hostname \
    python3-pip golang rust cargo \
    openssl \
    ansible \
    terraform \
    curl wget \
    vim nano
