FROM --platform=$TARGETOS/$TARGETARCH ubuntu:jammy

LABEL author="Kalle Minkner" maintainer="support@kandru.de"
LABEL org.opencontainers.image.licenses=GPLv3

# OS environment
ENV USER=container \
    HOME=/home/container \
    WINEARCH=win64 \
    WINEPREFIX="/home/container/.wine_bfbc2" \
    WINEDLLOVERRIDES="mscoree,mshtml=" \
    WINEDEBUG=-all \
    DISPLAY=:0 \
    DISPLAY_WIDTH=1280 \
    DISPLAY_HEIGHT=720 \
    DISPLAY_DEPTH=24 \
    XVFB=1 \
    DEBIAN_FRONTEND=noninteractive

# install core os
RUN apt update \
    && apt install --no-install-recommends -y binutils iproute2 net-tools \
    gnupg2 apt-transport-https software-properties-common ca-certificates tzdata locales \
    && update-locale lang=en_US.UTF-8 \
    && dpkg-reconfigure --frontend noninteractive locales \
    && useradd -m -d /home/container -s /bin/bash container

# install gameserver os requirements
RUN dpkg --add-architecture i386 \
    && apt update && apt install --no-install-recommends -y \
        xvfb \
        libgl1-mesa-glx:i386 \
        winbind \
    && apt clean

# install latest WINE
RUN mkdir -pm755 /etc/apt/keyrings \
    && wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key \
    && wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources \
    && apt update && apt install --no-install-recommends -y winehq-stable

# remove apt cache data
RUN rm -rf /var/lib/apt/lists/*

USER container
WORKDIR /home/container

COPY ./bin/entrypoint.sh /entrypoint.sh
CMD [ "/bin/bash", "/entrypoint.sh" ]