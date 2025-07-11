FROM --platform=$TARGETOS/$TARGETARCH mono:latest

LABEL author="Kalle Minkner" maintainer="support@kandru.de"
LABEL org.opencontainers.image.licenses=GPLv3

# Install dependencies
RUN apt-get update && apt-get install -y \
    unixodbc \
    unixodbc-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy and install MySQL ODBC connector 5.1
COPY mysql-connector-odbc-5.1.13-linux-debian6.0-x86-64bit.tar.gz /tmp/
RUN cd /tmp && \
    tar -xzf mysql-connector-odbc-5.1.13-linux-debian6.0-x86-64bit.tar.gz && \
    cd mysql-connector-odbc-5.1.13-linux-debian6.0-x86-64bit && \
    ls -la lib/ && \
    cp lib/libmyodbc5.so /usr/lib/x86_64-linux-gnu/odbc/ && \
    cd / && \
    rm -rf /tmp/mysql-connector-odbc-*

# Configure ODBC drivers (without Setup library since it's not available)
RUN echo "[MySQL ODBC 5.1 Driver]" >> /etc/odbcinst.ini && \
    echo "Description=MySQL ODBC 5.1 Driver" >> /etc/odbcinst.ini && \
    echo "Driver=/usr/lib/x86_64-linux-gnu/odbc/libmyodbc5.so" >> /etc/odbcinst.ini && \
    echo "CPTimeout=" >> /etc/odbcinst.ini && \
    echo "CPReuse=" >> /etc/odbcinst.ini

# OS environment
ENV USER=container \
    HOME=/home/container

USER container
WORKDIR /home/container

COPY ./bin/entrypoint.sh /entrypoint.sh
CMD [ "/bin/bash", "/entrypoint.sh" ]