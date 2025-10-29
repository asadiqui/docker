FROM alpine:3.21

ENV PHP_INI_DIR=/etc/php82 \
    PHP_FPM_CONF_DIR=/etc/php82/php-fpm.d \
    WP_PATH=/var/www/html

RUN apk add --no-cache \
    php82 php82-cli php82-fpm php82-mysqli php82-json php82-curl php82-dom php82-exif \
    php82-fileinfo php82-mbstring php82-openssl php82-xml php82-zip php82-phar \
    curl tar ca-certificates netcat-openbsd bash \
 && ln -sf /usr/bin/php82 /usr/bin/php

# RUN adduser -D -H -u 82 -s /sbin/nologin www-data && \
#     mkdir -p ${WP_PATH} && chown -R www-data:www-data ${WP_PATH}

# Create service user/group only if missing; ensure consistent UID/GID 82
RUN addgroup -S -g 82 www-data 2>/dev/null || true \
 && id -u www-data >/dev/null 2>&1 || adduser -S -D -H -u 82 -G www-data -s /sbin/nologin www-data \
 && mkdir -p ${WP_PATH} \
 && chown -R 82:82 ${WP_PATH}

COPY conf/www.conf ${PHP_FPM_CONF_DIR}/www.conf
COPY tools/setup.sh /usr/local/bin/setup.sh

RUN chmod +x /usr/local/bin/setup.sh

VOLUME ["/var/www/html"]

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/setup.sh"]
