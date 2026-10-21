# syntax=docker/dockerfile:1.4
FROM alpine:3.24

LABEL maintainer="kyxap"
LABEL org.opencontainers.image.authors="kyxap"
LABEL org.opencontainers.image.description="Selfoss, a multipurpose RSS reader, on Alpine with a selectable PHP version."
LABEL org.opencontainers.image.documentation="https://github.com/kyxap1/docker-selfoss/blob/master/README.md"
LABEL org.opencontainers.image.source="https://github.com/kyxap1/docker-selfoss"
LABEL org.opencontainers.image.title="kyxap/selfoss"
LABEL org.opencontainers.image.url="https://github.com/kyxap1/docker-selfoss"

ARG PHP=84
ARG VERSION=2.19
ARG SHA256_HASH="e49c4750e9723277963ca699b602f09f9148e2b9f258fce6b14429498af0e4fc"

ENV GID=991 UID=991 CRON_PERIOD=15m UPLOAD_MAX_SIZE=25M LOG_TO_STDOUT=false MEMORY_LIMIT=128M

RUN apk upgrade --no-cache \
 && apk add --no-cache \
    ca-certificates \
    libwebp \
    musl \
    nginx \
    php${PHP} \
    php${PHP}-ctype \
    php${PHP}-curl \
    php${PHP}-dom \
    php${PHP}-fpm \
    php${PHP}-gd \
    php${PHP}-iconv \
    php${PHP}-mbstring \
    php${PHP}-pdo_mysql \
    php${PHP}-pdo_pgsql \
    php${PHP}-pdo_sqlite \
    php${PHP}-pecl-imagick \
    php${PHP}-session \
    php${PHP}-simplexml \
    php${PHP}-tidy \
    php${PHP}-xml \
    php${PHP}-xmlwriter \
    php${PHP}-zlib \
    s6 \
    su-exec \
    tini \
 && ln -s /usr/bin/php${PHP} /usr/local/bin/php \
 && ln -s /usr/sbin/php-fpm${PHP} /usr/local/bin/php-fpm \
 && wget -q https://dl.cloudsmith.io/public/fossar/selfoss-git/raw/names/selfoss.zip/versions/${VERSION}/selfoss-${VERSION}.zip -P /tmp \
 && CHECKSUM=$(sha256sum /tmp/selfoss-$VERSION.zip | awk '{print $1}') \
 && if [ "${CHECKSUM}" != "${SHA256_HASH}" ]; then echo "Warning! Checksum does not match!" && exit 1; fi \
 && mkdir /selfoss && unzip -q /tmp/selfoss-$VERSION.zip -d / \
 && rm -rf /tmp/*

COPY --link rootfs /
RUN chmod +x /usr/local/bin/run.sh /services/*/run /services/.s6-svscan/*

VOLUME /selfoss/data
EXPOSE 8888
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
    CMD wget -q --spider 127.0.0.1:8888/ || exit 1

CMD ["run.sh"]
