FROM quay.io/thenets/dev-container:latest

ARG USER=dednets

#VOLUME /home/${USER}/.local/share/containers

RUN /opt/dev/04-rootless-container.sh ${USER}

USER ${USER}
