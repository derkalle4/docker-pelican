FROM --platform=$TARGETOS/$TARGETARCH ubuntu:jammy

LABEL author="Kalle Minkner" maintainer="support@kandru.de"
LABEL org.opencontainers.image.licenses=GPLv3

# OS environment
ENV USER=container \
    HOME=/home/container \
    WINEARCH=win32 \
    WINEPREFIX="/home/container/.wine32" \
    DISPLAY=:0 \
    DISPLAY_WIDTH=1024 \
    DISPLAY_HEIGHT=768 \
    DISPLAY_DEPTH=16 \
    AUTO_UPDATE=1 \
    XVFB=1 \
    DEBIAN_FRONTEND=noninteractive

# install core os
RUN apt update && apt upgrade -y \
    && apt install -y git wget curl tar zip unzip binutils xz-utils liblzo2-2 cabextract iproute2 net-tools \
    gnupg2 apt-transport-https software-properties-common ca-certificates tzdata locales \
    && update-locale lang=en_US.UTF-8 \
    && dpkg-reconfigure --frontend noninteractive locales \
    && useradd -m -d /home/container -s /bin/bash container

# install gameserver os requirements
RUN dpkg --add-architecture i386 \
    && apt update && apt upgrade -y \
        xvfb \
        libgl1-mesa-glx:i386 \
        ca-certificates \
        unrar \
        winbind \
    && apt clean

# install latest WINE
RUN mkdir -pm755 /etc/apt/keyrings \
    && wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key \
    && wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources \
    && apt update && apt install -y winehq-stable

RUN wget  https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks -O /bin/winetricks \
    && chmod +x /bin/winetricks

USER container
WORKDIR /home/container

# install gameserver wine requirements
RUN mkdir -p /home/container/server/ \
    && wineboot \
    && xvfb-run -e /dev/stdout -a -s "-nolisten tcp -screen 0 ${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}x${DISPLAY_DEPTH}" winetricks -q \
        dinput8 \
        vcrun2005 \
        vcrun2008 \
        vcrun2010

COPY ./bin/entrypoint.sh /entrypoint.sh
CMD [ "/bin/bash", "/entrypoint.sh" ]