#!/usr/bin/with-contenv sh
# shellcheck shell=sh
set -e

echo "Fixing perms..."
mkdir -p /data \
  /var/run/nginx \
  /var/run/php-fpm
chown librenms:librenms \
  /data \
  "${LIBRENMS_PATH}" \
  "${LIBRENMS_PATH}/.env" \
  "${LIBRENMS_PATH}/cache" \
  "${LIBRENMS_PATH}/rrd"
chown -R librenms:librenms \
  /home/librenms \
  /tpls \
  /var/lib/nginx \
  /var/log/nginx \
  /var/log/php82 \
  /var/run/nginx \
  /var/run/php-fpm
