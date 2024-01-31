FROM quay.io/thenets/dev-container:latest

RUN /opt/dev/04-rootless-container.sh dednets

USER dednets
