FROM timsmart/debian-rbx:latest

ENV S6_VERSION="1.11.0.1"

RUN PACKAGES="nginx sudo" && \
    BUILD_PACKAGES="curl" && \
# install packages
    apt-get update && \
    apt-get install -y --no-install-recommends $PACKAGES $BUILD_PACKAGES && \
# gem config
    echo 'gem: --no-rdoc --no-ri ' > /etc/gemrc && \
# bundler
    gem install bundler puma && \
# app src directory
    mkdir -p /usr/src/app && \
    cd /usr/src && \
# s6 overlay
    curl -LO https://github.com/just-containers/s6-overlay/releases/download/v$S6_VERSION/s6-overlay-amd64.tar.gz && \
    tar -xzf s6-overlay-amd64.tar.gz -C / && \
# directories
    mkdir -p /var/run/puma && chown www-data:www-data /var/run/puma && \
# permissions
    chmod +x /etc/services.d/nginx/* && \
    chmod +x /etc/services.d/puma/* && \
# nginx log redirection
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log && \
# clean up
    apt-get purge --auto-remove -y $BUILD_PACKAGES && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/* \
        /usr/src/*.tar.gz

ADD etc/ /etc/

WORKDIR /usr/src/app
EXPOSE 3000
ENTRYPOINT ["/init"]
