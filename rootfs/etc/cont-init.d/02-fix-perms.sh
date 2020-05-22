#!/usr/bin/with-contenv sh

echo "Fixing perms..."
mkdir -p /data \
  /var/run/nginx \
  /var/run/php-fpm
chown librenms. \
  /data \
  "${LIBRENMS_PATH}" \
  "${LIBRENMS_PATH}/html/plugins/Weathermap/output"
chown -R librenms. \
  /tpls \
  /var/lib/nginx \
  /var/log/nginx \
  /var/log/php7 \
  /var/run/nginx \
  /var/run/php-fpm
