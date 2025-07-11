FROM --platform=$TARGETOS/$TARGETARCH mono:latest

LABEL author="Kalle Minkner" maintainer="support@kandru.de"
LABEL org.opencontainers.image.licenses=GPLv3

# Install dependencies
RUN apt-get update && apt-get install -y \
    unixodbc \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy and install MySQL ODBC connector
COPY mysql-connector-odbc-setup_9.3.0-1debian12_amd64.deb /tmp/
RUN dpkg -i /tmp/mysql-connector-odbc-setup_9.3.0-1debian12_amd64.deb || apt-get install -f -y \
    && rm /tmp/mysql-connector-odbc-setup_9.3.0-1debian12_amd64.deb

# OS environment
ENV USER=container \
    HOME=/home/container

USER container
WORKDIR /home/container

COPY ./bin/entrypoint.sh /entrypoint.sh
CMD [ "/bin/bash", "/entrypoint.sh" ]