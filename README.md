[![Container release auto patch](https://github.com/thenets/dev-container/actions/workflows/container-release-auto-patch.yml/badge.svg)](https://github.com/thenets/dev-container/actions/workflows/container-release-auto-patch.yml)

# TheNets : Dev Container

A full-featured Fedora container image designed for development.

---

Container images:
- [Quay.io](https://quay.io/repository/thenets/rinetd)
  - `quay.io/thenets/rinetd:latest`

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
podman run -it --rm quay.io/thenets/rinetd:latest htop
```

### 3.2. Rootfull Podman in Rootfull Docker, with `--privileged` flag

```bash
# Start the container in privileged mode


```

### 3.3. Rootfull Docker in Rootfull Docker, with socket sharing

```dockerfile
FROM quay.io/thenets/dev-container:latest

# Create a new user using the `04-rootless-container.sh` script
# Example: Create a new user called `dednets`
RUN /opt/dev/04-rootless-container.sh dednets

# Switch to the new user
USER dednets
```

```bash

```

## 4. References

Most of this work was create on top of the following blog post and git repo:

- https://www.redhat.com/sysadmin/podman-inside-container
- https://github.com/containers/podman/tree/main/contrib/podmanimage/stable
