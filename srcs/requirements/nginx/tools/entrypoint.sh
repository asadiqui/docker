#!/usr/bin/env sh
set -eu

CERT_DIR=/etc/nginx/certs
DOMAIN=${DOMAIN_NAME:-localhost}

CRT=${CERT_DIR}/server.crt
KEY=${CERT_DIR}/server.key

if [ ! -f "$CRT" ] || [ ! -f "$KEY" ]; then
  echo "Generating self-signed TLS certificate for ${DOMAIN}..."
  openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
    -keyout "$KEY" -out "$CRT" \
    -subj "/CN=${DOMAIN}" >/dev/null 2>&1
fi

echo "Starting NGINX..."
exec nginx -g 'daemon off;'
