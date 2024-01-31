#!/bin/bash

# Podman Setup Rootless
#
# **WARNING**: maybe in the future it will also support rootless Docker
#
# This script creates a new user and sets up rootless podman for the user.
#
# This is required for running podman as a non-root user inside a container,
# also known as PINP (Podman in Podman) or PIND (Podman in Docker).
# Learn more at https://www.redhat.com/sysadmin/podman-inside-container
#
# Usage: ./03-rootless-container.sh _USERNAME


# Helpers
# =========================
if [ -z "$TERM" ] || [ "$TERM" == "dumb" ]; then
    tput() {
        return 0
    }
fi
if ! type tput >/dev/null 2>&1; then
    tput() {
        return 0
    }
fi
log_info() {
    local CYAN=$(tput setaf 6)
    local NC=$(tput sgr0)
    echo "${CYAN}[INFO   ]${NC} $*" 1>&2
}
log_warning() {
    local YELLOW=$(tput setaf 3)
    local NC=$(tput sgr0)
    echo "${YELLOW}[WARNING]${NC} $*" 1>&2
}
log_error() {
    local RED=$(tput setaf 1)
    local NC=$(tput sgr0)
    echo "${RED}[ERROR  ]${NC} $*" 1>&2
}
log_success() {
    local GREEN=$(tput setaf 2)
    local NC=$(tput sgr0)
    echo "${GREEN}[SUCCESS]${NC} $*" 1>&2
}
log_title() {
    local GREEN=$(tput setaf 2)
    local BOLD=$(tput bold)
    local NC=$(tput sgr0)
    echo 1>&2
    echo "${GREEN}${BOLD}---- $* ----${NC}" 1>&2
}
h_run() {
    local ORANGE=$(tput setaf 3)
    local NC=$(tput sgr0)
    echo "${ORANGE}\$${NC} $*" 1>&2
    eval "$*"
}


# Validation
# =========================

# Parameters
# - _USERNAME: The user to setup rootless podman for

_HELP="This script sets up rootless podman for a user.
Usage: $0 _USERNAME
  _USERNAME: The user to setup rootless podman for"

set -e

if [ "$EUID" -ne 0 ]; then
  log_error "Please run as root"
  exit 1
fi

if [ -z "$1" ]; then
    log_error "Please provide the user to setup rootless podman for"
    log_error "$_HELP"
  exit 1
fi

_USERNAME="$1"

# Check if user exists, fail if exists
if id -u "$_USERNAME" >/dev/null 2>&1; then
    log_error "User $_USERNAME already exists"
    exit 1
fi

# Setup
# =========================

set -x

# Don't include container-selinux and remove
# directories used by yum that are just taking
# up space.
dnf reinstall -y shadow-utils
dnf install -y podman fuse-overlayfs --exclude container-selinux

# Create user
useradd ${_USERNAME}; \
echo ${_USERNAME}:10000:5000 > /etc/subuid; \
echo ${_USERNAME}:10000:5000 > /etc/subgid;

# FILE: /etc/containers/containers.conf
mkdir -p /etc/containers
cat > /etc/containers/containers.conf <<EOF
[containers]
netns="host"
userns="host"
ipcns="host"
utsns="host"
cgroupns="host"
cgroups="disabled"
log_driver = "k8s-file"
[engine]
cgroup_manager = "cgroupfs"
events_logger="file"
runtime="crun"
EOF

# FILE: /home/${_USERNAME}/.config/containers/containers.conf
mkdir -p /home/${_USERNAME}/.config/containers
cat > /home/${_USERNAME}/.config/containers/containers.conf <<EOF
[containers]
volumes = [
	"/proc:/proc",
]
default_sysctls = []
EOF

# HACK for some reason, the /etc/containers/storage.conf doesn't exist, so I'm creating it
#sed -i -e 's|^#mount_program|mount_program|g' -e '/additionalimage.*/a "/var/lib/shared",' -e 's|^mountopt[[:space:]]*=.*$|mountopt = "nodev,fsync=0"|g' /etc/containers/storage.conf
# FILE: /etc/containers/storage.conf
mkdir -p /etc/containers
cat > /etc/containers/storage.conf <<EOF
[storage]
driver = "overlay"
runroot = "/run/containers/storage"
graphroot = "/var/lib/containers/storage"

[storage.options]
additionalimagestores = [
"/var/lib/shared",
]
pull_options = {enable_partial_images = "false", use_hard_links = "false", ostree_repos=""}

[storage.options.overlay]
mount_program = "/usr/bin/fuse-overlayfs"
mountopt = "nodev,fsync=0"

[storage.options.thinpool]
EOF

# Fix permissions
chown ${_USERNAME}:${_USERNAME} -R /home/${_USERNAME}
chmod 644 /etc/containers/containers.conf

mkdir -p /var/lib/shared/overlay-images /var/lib/shared/overlay-layers /var/lib/shared/vfs-images /var/lib/shared/vfs-layers
touch /var/lib/shared/overlay-images/images.lock
touch /var/lib/shared/overlay-layers/layers.lock
touch /var/lib/shared/vfs-images/images.lock
touch /var/lib/shared/vfs-layers/layers.lock

# Set /etc/environment
# _CONTAINERS_USERNS_CONFIGURED=""
echo 'CONTAINERS_USERNS_CONFIGURED="cafe"' >> /etc/environment

# Done
log_warning "Do not forget to set the volume in the Containerfile after invoking this script."
log_warning "  VOLUME /home/${_USERNAME}/.local/share/containers"
