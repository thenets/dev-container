[![Container release auto patch](https://github.com/thenets/dev-container/actions/workflows/container-release-auto-patch.yml/badge.svg)](https://github.com/thenets/dev-container/actions/workflows/container-release-auto-patch.yml)

# TheNets : Dev Container

A full-featured Fedora container image designed for development.

---

Container images:
- [Quay.io](https://quay.io/repository/thenets/dev-container)
  - `quay.io/thenets/dev-container:latest`

## 1. Use-cases

- Coder Workspace
- VS Code container (WIP)

## 2. Features

- Most build tools. Maybe suitable for pipelines too.
- Container-in-container supported scenarios:
    - [ ] Rootless Podman in Rootless Podman
    - [x] Rootfull Podman in Rootfull Docker, with `--privileged` flag
    - [ ] Rootfull Docker in Rootfull Docker, with `--privileged` flag
    - [x] Rootfull Docker in Rootfull Docker, with socket sharing

## 3. Usage per scenario

### 3.1. No inner container

Just run the container as usual.

```bash
# Example: Run htop
podman run -it --rm quay.io/thenets/dev-container:latest htop
```

### 3.2. Rootfull Podman in Rootfull Docker, with `--privileged` flag

```bash
# Start a Docker container in privileged mode
docker run -it --rm --privileged quay.io/thenets/dev-container:latest

# (inside the container)
# Run a podman container
podman run -it --rm docker.io/alpine echo 'hello'
```

### 3.3. Rootfull Docker in Rootfull Docker, with socket sharing

```bash
# Start a Docker container, mapping it's daemon socket
docker run -ti --rm -v /var/run/docker.sock:/var/run/docker.sock:rw quay.io/thenets/dev-container:latest

# (inside the container)
# Run a docker container
docker run -it --rm docker.io/alpine echo 'hello'
```

## 4. References

Most of this work was create on top of the following blog post and git repo:

- https://www.redhat.com/sysadmin/podman-inside-container
- https://github.com/containers/podman/tree/main/contrib/podmanimage/stable
