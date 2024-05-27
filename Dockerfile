ARG UNIT_VERSION=1.29.0
ARG PHP_VERSION=8.2
ARG PHP_ALPINE_VERSION=3.19

################################################
# NGINX UNIT DOWNLOADER - Stage #1             #
################################################
FROM --platform=${TARGETPLATFORM} alpine:3.20 AS nginx-unit-downloader

ARG UNIT_VERSION
WORKDIR "/tmp/unit"
ADD ["https://codeload.github.com/nginx/unit/tar.gz/refs/tags/${UNIT_VERSION}", "/tmp/unit.tar.gz"]
RUN tar zxvf /tmp/unit.tar.gz --strip=1 -C "/tmp/unit"



################################################
# NGINX UNIT BUILDER - Stage #2                #
################################################
ARG PHP_VERSION
ARG PHP_ALPINE_VERSION
FROM --platform=${TARGETPLATFORM} php:${PHP_VERSION}-zts-alpine${PHP_ALPINE_VERSION} AS nginx-unit-builder

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
FROM alpine:3.20 AS rootfs

COPY --from=nginx-unit-builder ["/opt/unit/", "/opt/unit/"]
COPY --from=ghcr.io/n0rthernl1ghts/s6-rootfs:3.1.6.2 ["/", "/rootfs-build"]

# Rootfs
COPY ["./rootfs", "/rootfs-build"]

# Prepare unit
COPY --chmod=0775 ["./src/setup-unit.sh", "/tmp/setup-unit.sh"]

RUN set -eux \
    && apk add --update --no-cache bash rsync \
    && /tmp/setup-unit.sh



################################################
# Final stage                                  #
################################################
ARG PHP_VERSION
ARG PHP_ALPINE_VERSION
FROM --platform=${TARGETPLATFORM} php:${PHP_VERSION}-zts-alpine${PHP_ALPINE_VERSION}

RUN set -eux \
    && apk add --update --no-cache bash pcre-dev socat

COPY --from=rootfs ["/rootfs-build/", "/"]


ARG UNIT_VERSION
ENV UNIT_VERSION=${UNIT_VERSION}
ENV UNIT_SOCKET="/run/control.unit.sock"
ENV UNIT_CONFIGURATION_FILE="/etc/unit/config.json"
ENV S6_KEEP_ENV=1
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2
ENV S6_SERVICES_GRACETIME=6000
ENV S6_VERBOSITY=5
ENV S6_CMD_RECEIVE_SIGNALS=1

LABEL maintainer="Aleksandar Puharic <aleksandar@puharic.com>" \
      org.opencontainers.image.source="https://github.com/N0rthernL1ghts/unit-php" \
      org.opencontainers.image.description="NGINX Unit ${UNIT_VERSION} - Alpine Build ${TARGETPLATFORM}" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.version="${UNIT_VERSION}"

ENTRYPOINT ["/init"]
