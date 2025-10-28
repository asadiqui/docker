FROM alpine:3.20

RUN apk add --no-cache nginx openssl bash

RUN mkdir -p /run/nginx /etc/nginx/certs && \
    chown -R root:root /etc/nginx /run/nginx

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

VOLUME ["/etc/nginx/certs", "/var/www/html"]

EXPOSE 443

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
