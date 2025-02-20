FROM --platform=$TARGETOS/$TARGETARCH debian:bookworm-slim

LABEL author="Zari0" maintainer="zarti0@zarti.cfd"

ARG PHP_VERSION="8.1"

ENV DEBIAN_FRONTEND=noninteractive

# Installation d'Apache et PHP 8.1 explicitly
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y apt-transport-https lsb-release curl unzip zip ca-certificates wget apache2 iproute2 \
    && wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
    && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        php${PHP_VERSION} \
        libapache2-mod-php${PHP_VERSION} \
        php${PHP_VERSION}-fpm \
        php${PHP_VERSION}-cli \
        php${PHP_VERSION}-common \
        php${PHP_VERSION}-mysqlnd \
        php${PHP_VERSION}-pdo \
        php${PHP_VERSION}-xml \
        php${PHP_VERSION}-bcmath \
        php${PHP_VERSION}-calendar \
        php${PHP_VERSION}-ctype \
        php${PHP_VERSION}-curl \
        php${PHP_VERSION}-dom \
        php${PHP_VERSION}-mbstring \
        php${PHP_VERSION}-fileinfo \
        php${PHP_VERSION}-ftp \
        php${PHP_VERSION}-gd \
        php${PHP_VERSION}-gettext \
        php${PHP_VERSION}-gmp \
        php${PHP_VERSION}-iconv \
        php${PHP_VERSION}-imagick \
        php${PHP_VERSION}-intl \
        php${PHP_VERSION}-ldap \
        php${PHP_VERSION}-exif \
        php${PHP_VERSION}-memcache \
        php${PHP_VERSION}-mongodb \
        php${PHP_VERSION}-msgpack \
        php${PHP_VERSION}-mysqli \
        php${PHP_VERSION}-odbc \
        php${PHP_VERSION}-pcov \
        php${PHP_VERSION}-pgsql \
        php${PHP_VERSION}-phar \
        php${PHP_VERSION}-posix \
        php${PHP_VERSION}-ps \
        php${PHP_VERSION}-pspell \
        php${PHP_VERSION}-readline \
        php${PHP_VERSION}-shmop \
        php${PHP_VERSION}-simplexml \
        php${PHP_VERSION}-soap \
        php${PHP_VERSION}-sockets \
        php${PHP_VERSION}-sqlite3 \
        php${PHP_VERSION}-sysvmsg \
        php${PHP_VERSION}-sysvsem \
        php${PHP_VERSION}-sysvshm \
        php${PHP_VERSION}-tokenizer \
        php${PHP_VERSION}-xmlreader \
        php${PHP_VERSION}-xmlwriter \
        php${PHP_VERSION}-xsl \
        php${PHP_VERSION}-zip \
        php${PHP_VERSION}-mailparse \
        php${PHP_VERSION}-memcached \
        php${PHP_VERSION}-inotify \
        php${PHP_VERSION}-maxminddb \
        php${PHP_VERSION}-protobuf \
        php${PHP_VERSION}-opcache \
    && apt-get purge -y --auto-remove \
    && rm -rf /var/lib/apt/lists/*

# Install ionCube Loader based on architecture (amd64 or arm64)
# Install ionCube Loader based on architecture (amd64 or arm64)
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
        wget -O /tmp/ioncube_loaders.tar.gz https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz; \
    elif [ "$ARCH" = "aarch64" ]; then \
        wget -O /tmp/ioncube_loaders.tar.gz https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_aarch64.tar.gz; \
    else \
        echo "Unsupported architecture: $ARCH" && exit 1; \
    fi && \
    tar -zxvf /tmp/ioncube_loaders.tar.gz -C /tmp/ && \
    PHP_EXTENSION_DIR=$(php -i | grep "^extension_dir" | awk '{print $3}') && \
    PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;") && \
    echo "PHP Extension Directory: $PHP_EXTENSION_DIR" && \
    echo "PHP Version: $PHP_VERSION" && \
    ls /tmp/ioncube && \
    cp /tmp/ioncube/ioncube_loader_lin_${PHP_VERSION}.so $PHP_EXTENSION_DIR || echo "Error: Failed to copy ionCube Loader to $PHP_EXTENSION_DIR"

# Enable ionCube loader in PHP
RUN echo "zend_extension=$(php -i | grep extension_dir | awk '{print $3}')/ioncube_loader_lin_${PHP_VERSION}.so" > /etc/php/${PHP_VERSION}/mods-available/ioncube.ini && \
    phpenmod ioncube

# Install cloudflared based on architecture (amd64 or arm64)
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
        wget -O /tmp/cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb; \
    elif [ "$ARCH" = "aarch64" ]; then \
        wget -O /tmp/cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64.deb; \
    else \
        echo "Unsupported architecture: $ARCH" && exit 1; \
    fi && \
    dpkg -i /tmp/cloudflared.deb && \
    rm /tmp/cloudflared.deb

RUN useradd -m -d /home/container/ -s /bin/bash container
ENV USER=container HOME=/home/container

WORKDIR /home/container

STOPSIGNAL SIGINT

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]
