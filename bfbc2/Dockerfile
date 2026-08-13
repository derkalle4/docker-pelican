FROM debian:bookworm-slim

LABEL author="Kalle" \
      maintainer="support@kandru.de" \
      org.opencontainers.image.licenses="GPLv3"

ARG DEBIAN_FRONTEND=noninteractive

ENV USER=container \
    HOME=/home/container \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    WINEARCH=win32 \
    WINEPREFIX=/home/container/.wine_bfbc2 \
    WINEDEBUG=-all \
    DISPLAY=:0 \
    DISPLAY_WIDTH=1280 \
    DISPLAY_HEIGHT=720 \
    DISPLAY_DEPTH=24 \
    XVFB=1 \
    DEBIAN_FRONTEND=noninteractive

RUN dpkg --add-architecture i386 \
    && if [ -f /etc/apt/sources.list.d/debian.sources ]; then \
         sed -i 's/^Components: main$/Components: main contrib non-free non-free-firmware/' /etc/apt/sources.list.d/debian.sources; \
       elif [ -f /etc/apt/sources.list ]; then \
         sed -i 's/ main$/ main contrib non-free non-free-firmware/' /etc/apt/sources.list; \
       fi \
    && apt-get update \
    && apt-get install --no-install-recommends -y \
        apt-transport-https \
        bash \
        ca-certificates \
        cabextract \
        dbus \
        file \
        gnupg2 \
        iproute2 \
        locales \
        net-tools \
        passwd \
        p7zip-full \
        screen \
        tzdata \
        unzip \
        wget \
        winbind \
        xauth \
        xvfb \
    && sed -i 's/^# *en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen en_US.UTF-8 \
    && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
    && useradd --create-home --home-dir /home/container --shell /bin/bash container \
    && mkdir -p /home/container/.wine_bfbc2 \
    && chown -R container:container /home/container \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p -m 0755 /etc/apt/keyrings \
    && wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key \
    && wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources

RUN apt-get update \
    && apt-get install --install-recommends -y \
        winehq-stable \
        winetricks \
    && rm -rf /var/lib/apt/lists/*

USER container

WORKDIR /home/container

ENV WINEARCH=win32 \
    WINEPREFIX=/home/container/.wine_bfbc2

RUN xvfb-run -a -s "-screen 0 ${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}x${DISPLAY_DEPTH}" wineboot --init \
    && xvfb-run -a -s "-screen 0 ${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}x${DISPLAY_DEPTH}" winetricks -q \
        dinput8 \
        vcrun2005 \
        vcrun2008 \
        vcrun2010 \
        mono \
    && wineserver -k

COPY --chown=container:container ./bin/entrypoint.sh /entrypoint.sh
RUN chmod 0755 /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]