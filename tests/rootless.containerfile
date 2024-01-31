FROM quay.io/thenets/dev-container:latest

RUN /opt/dev/03-podman-setup-rootless.sh dednets

USER dednets
