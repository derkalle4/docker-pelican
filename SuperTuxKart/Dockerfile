FROM --platform=$TARGETOS/$TARGETARCH debian:bookworm-slim

LABEL author="Kalle Minkner" maintainer="support@kandru.de"
LABEL org.opencontainers.image.licenses=GPLv3

# OS environment
ENV USER=container \
    HOME=/home/container \
    DEBIAN_FRONTEND=noninteractive \
    SDL_VIDEODRIVER=dummy

# install core os + libraries used by the official SuperTuxKart Linux build
RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        bash \
        ca-certificates \
        iproute2 \
        libcurl4 \
        libssl3 \
        libstdc++6 \
        locales \
        net-tools \
        tzdata \
        zlib1g \
    && sed -i 's/^# *en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen en_US.UTF-8 \
    && update-locale LANG=en_US.UTF-8 \
    && useradd -m -d /home/container -s /bin/bash container \
    && rm -rf /var/lib/apt/lists/*

USER container
WORKDIR /home/container

COPY ./bin/entrypoint.sh /entrypoint.sh
CMD [ "/bin/bash", "/entrypoint.sh" ]
