#!/usr/bin/with-contenv bash

CRONTAB_PATH="/var/spool/cron/crontabs"

LIBRENMS_WEATHERMAP=${LIBRENMS_WEATHERMAP:-false}
LIBRENMS_WEATHERMAP_SCHEDULE=${LIBRENMS_WEATHERMAP_SCHEDULE:-*/5 * * * *}

SIDECAR_DISPATCHER=${SIDECAR_DISPATCHER:-0}
SIDECAR_SYSLOGNG=${SIDECAR_SYSLOGNG:-0}

if [ "$SIDECAR_DISPATCHER" = "1" ] || [ "$SIDECAR_SYSLOGNG" = "1" ] || [ "$LIBRENMS_WEATHERMAP" != "true" ]; then
  exit 0
fi

# Init
rm -rf ${CRONTAB_PATH}
mkdir -m 0644 -p ${CRONTAB_PATH}
touch ${CRONTAB_PATH}/librenms

# Cron
if [ -n "$LIBRENMS_WEATHERMAP_SCHEDULE" ]; then
  echo "Creating LibreNMS Weathermap cron task with the following period fields: $LIBRENMS_WEATHERMAP_SCHEDULE"
  echo "${LIBRENMS_WEATHERMAP_SCHEDULE} php -f /opt/librenms/html/plugins/Weathermap/map-poller.php" >> ${CRONTAB_PATH}/librenms
fi

# Fix perms
echo "Fixing crontabs permissions..."
chmod -R 0644 ${CRONTAB_PATH}

# Create service
mkdir -p /etc/services.d/weathermap
cat > /etc/services.d/weathermap/run <<EOL
#!/usr/bin/execlineb -P
with-contenv
exec busybox crond -f -L /dev/stdout
EOL
chmod +x /etc/services.d/weathermap/run
