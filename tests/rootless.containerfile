FROM quay.io/thenets/dev-container:latest

RUN /opt/scripts/03-podman-setup-rootless.sh dednets

USER dednets
