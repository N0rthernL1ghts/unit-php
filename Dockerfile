ARG UNIT_VERSION=1.29.0
ARG PHP_VERSION=8.1

################################################
# NGINX UNIT DOWNLOADER - Stage #1             #
################################################
FROM alpine:3.17 AS nginx-unit-downloader

ARG UNIT_VERSION
WORKDIR "/tmp/unit"
ADD ["https://codeload.github.com/nginx/unit/tar.gz/refs/tags/${UNIT_VERSION}", "/tmp/unit.tar.gz"]
RUN tar zxvf /tmp/unit.tar.gz --strip=1 -C "/tmp/unit"



################################################
# NGINX UNIT BUILDER - Stage #2                #
################################################
ARG PHP_VERSION
FROM php:${PHP_VERSION}-zts-alpine3.17 AS nginx-unit-builder

RUN set -eux \
    && apk add --update --no-cache alpine-sdk curl openssl-dev pcre-dev

COPY --from=nginx-unit-downloader ["/tmp/unit", "/build/unit/"]
ENV DESTDIR /opt/unit/
WORKDIR "/build/unit/"
ARG PHP_VERSION

RUN set -eux \
    && ./configure --log=/var/log/unitd.log \
    && ./configure php --module="php${PHP_VERSION//./}" \
    && make -j "$(nproc)" \
    && make -j "$(nproc)" install \
    && make clean

################################################
# Root FS builder / docker overlay - Stage #3  #
################################################
FROM scratch AS rootfs

COPY --from=nginx-unit-builder ["/opt/unit/", "/opt/unit/"]
COPY --from=nlss/s6-rootfs ["/", "/"]

# Rootfs
COPY ["./rootfs", "/"]



################################################
# Final stage                                  #
################################################
ARG PHP_VERSION
FROM php:${PHP_VERSION}-zts-alpine3.17

RUN apk add --update --no-cache pcre-dev

RUN set -eux \
    && apk add --update --no-cache socat \
    && ln -sf /opt/unit/sbin/unitd /sbin/unitd \
    && mkdir /var/lib/unit/state/certs -p

COPY --from=rootfs ["/", "/"]


ARG UNIT_VERSION
ENV UNIT_VERSION=${UNIT_VERSION}
ENV UNIT_SOCKET="/run/control.unit.sock"
ENV UNIT_CONFIGURATION_FILE="/etc/unit/config.json"
ENV S6_KEEP_ENV=1
ENV S6_VERBOSITY=5
ENV S6_CMD_RECEIVE_SIGNALS=1

ENTRYPOINT ["/init"]
