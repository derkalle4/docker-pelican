FROM --platform=$TARGETOS/$TARGETARCH mono:latest

LABEL author="Kalle Minkner" maintainer="support@kandru.de"
LABEL org.opencontainers.image.licenses=GPLv3

# OS environment
ENV USER=container \
    HOME=/home/container

USER container
WORKDIR /home/container

COPY ./bin/entrypoint.sh /entrypoint.sh
CMD [ "/bin/bash", "/entrypoint.sh" ]