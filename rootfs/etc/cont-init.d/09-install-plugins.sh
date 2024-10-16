#!/usr/bin/with-contenv sh
# shellcheck shell=sh
set -e

INSTALL_PLUGINS=${INSTALL_PLUGINS:-0}
SIDECAR_DISPATCHER=${SIDECAR_DISPATCHER:-0}
SIDECAR_SYSLOGNG=${SIDECAR_SYSLOGNG:-0}
SIDECAR_SNMPTRAPD=${SIDECAR_SNMPTRAPD:-0}

# Exit if any sidecar is enabled
if [ "$SIDECAR_DISPATCHER" = "1" ] || [ "$SIDECAR_SYSLOGNG" = "1" ] || [ "$SIDECAR_SNMPTRAPD" = "1" ]; then
  exit 0
fi

# Exit if plugins are not needed
if [ "$INSTALL_PLUGINS" = "0" ]; then
  exit 0
fi

echo ">> Plugin configuration detected"

echo "Fixing permissions..."
chown librenms:librenms \
  "${LIBRENMS_PATH}"/composer.* \
  "${LIBRENMS_PATH}/logs/librenms.log" \
  "${LIBRENMS_PATH}/scripts/composer_wrapper.php"

chown -R librenms:librenms \
  "${LIBRENMS_PATH}/scripts" \
  "${LIBRENMS_PATH}/vendor" \
  "${LIBRENMS_PATH}/bootstrap"

# Install plugins
lnms plugin:add "$INSTALL_PLUGINS"
