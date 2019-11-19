#!/usr/bin/with-contenv sh

echo "Fixing perms..."
chown librenms. \
  /data \
  "${LIBRENMS_PATH}"
chown -R librenms. \
  /tpls \
  /var/lib/nginx \
  /var/log/nginx \
  /var/log/php7 \
  /var/run/nginx \
  /var/run/php-fpm \
  /var/tmp/nginx
