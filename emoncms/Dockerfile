ARG BUILD_FROM=ghcr.io/hassio-addons/base/amd64:11.1.2

FROM php:7.4-fpm-alpine AS buildmosquitto
RUN \
    apk add --no-cache \
        $PHPIZE_DEPS \
        mosquitto-dev
COPY lib/Mosquitto-PHP /src

WORKDIR /src

RUN \
    phpize \
    && ./configure --with-mosquitto=/usr/lib/ \
    && make


# hadolint ignore=DL3006
FROM ${BUILD_FROM}
# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Setup base
RUN \
    apk add --no-cache \
        nginx=1.20.2-r0 \
        mariadb-client=10.6.7-r0 \
        mosquitto-libs=2.0.14-r0 \
        php7-ctype=7.4.29-r0 \
        php7-curl=7.4.29-r0 \
        php7-fpm=7.4.29-r0 \
        php7-gettext=7.4.29-r0 \
        php7-json=7.4.29-r0 \
        php7-mbstring=7.4.29-r0 \
        php7-mysqli=7.4.29-r0 \
        php7-opcache=7.4.29-r0 \
        php7-session=7.4.29-r0 \
        php7-zip=7.4.29-r0 \
        php7=7.4.29-r0

COPY --from=buildmosquitto /src/modules/mosquitto.so /usr/lib/php7/modules/mosquitto.so
RUN \
    echo 'extension=mosquitto.so' > /etc/php7/conf.d/00_mosquitto.ini

ARG EMONCMS_TAG=10.8.5
ARG EMONCMS_DASHBOARD_TAG=2.1.5
ARG EMONCMS_GRAPH_TAG=2.1.1
ARG EMONCMS_APP_TAG=2.3.2
ARG EMONCMS_DEVICE_TAG=2.1.2
RUN \
    apk add --no-cache --virtual .build-dependencies \
        git=2.34.2-r0 \
    \
    && git clone --branch ${EMONCMS_TAG} --depth=1 \
        https://github.com/emoncms/emoncms.git /var/www/emoncms ; cd /var/www/emoncms \
    && git clone --branch ${EMONCMS_DASHBOARD_TAG} --depth=1 \
        https://github.com/emoncms/dashboard.git /var/www/emoncms/Modules/dashboard \
    && git clone --branch ${EMONCMS_GRAPH_TAG} --depth=1 \
        https://github.com/emoncms/graph.git /var/www/emoncms/Modules/graph \
    && git clone --branch ${EMONCMS_APP_TAG} --depth=1 \
        https://github.com/emoncms/app.git /var/www/emoncms/Modules/app \
    && git clone --branch ${EMONCMS_DEVICE_TAG} --depth=1 \
        https://github.com/emoncms/device.git /var/www/emoncms/Modules/device \
    \
    && apk del --no-cache --purge .build-dependencies \
    \
    && find /var/www/emoncms -type d -name ".git" -delete \
    && find /var/www/emoncms -type f -name ".htaccess" -depth -exec rm -f {} \; \
    && find /var/www/emoncms -type f -name "*.md" -depth -exec rm -f {} \; \
    && find /var/www/emoncms -type f -name ".gitignore" -depth -exec rm -f {} \; \
    && find /var/www/emoncms -type f -name ".empty" -depth -exec rm -f {} \;

# Copy root filesystem
COPY rootfs /

# patch MQTT script so it starts properly
RUN \
    apk add --no-cache patch \
    && cd /var/www/emoncms/scripts/ \
    && patch phpmqtt_input.php phpmqtt_input.php.patch \
    && rm phpmqtt_input.php.patch \
    && apk del --no-cache --purge patch


# Build arguments
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_REF
ARG BUILD_VERSION

# Labels
LABEL \
    io.hass.name="Emoncms" \
    io.hass.description="Emoncms is a powerful open-source web-app for processing, logging and visualising energy, temperature and other environmental data." \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version="${BUILD_VERSION}" \
    maintainer="Tom Whitwell" \
    org.opencontainers.image.title="Emoncms" \
    org.opencontainers.image.description="Emoncms is a powerful open-source web-app for processing, logging and visualising energy, temperature and other environmental data." \
    org.opencontainers.image.vendor="Tom Whitwell" \
    org.opencontainers.image.authors="Tom Whitwell" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.url="https://github.com/whi-tw/hassio-addon-emoncms" \
    org.opencontainers.image.source="https://github.com/whi-tw/hassio-addon-emoncms" \
    org.opencontainers.image.documentation="https://github.com/whi-tw/hassio-addon-emoncms/blob/master/README.md" \
    org.opencontainers.image.created="${BUILD_DATE}" \
    org.opencontainers.image.revision="${BUILD_REF}" \
    org.opencontainers.image.version="${BUILD_VERSION}" \
    org.opencontainers.image.base.name="${BUILD_FROM}"
