#!/usr/bin/with-contenv sh
# shellcheck shell=sh
set -e

INSTALL_PLUGINS=${INSTALL_PLUGINS:-0}

# Continue only if plugins are needed
if [ "$INSTALL_PLUGINS" = "0" ]; then
  exit 0
fi

echo ">>"
echo ">> Plugin configuration detected"
echo ">>"

# Fix perms
echo "Fixing perms..."
chown librenms:librenms \
  ${LIBRENMS_PATH}/composer.* \
  ${LIBRENMS_PATH}/logs/librenms.log \
  ${LIBRENMS_PATH}/scripts/composer_wrapper.php
chown -R librenms:librenms \
  ${LIBRENMS_PATH}/scripts \
  ${LIBRENMS_PATH}/vendor \
  ${LIBRENMS_PATH}/bootstrap

# Create service
IFS=, read -ra PLUGINS <<< "$INSTALL_PLUGINS"

for plugin in "${PLUGINS[@]}"; do
  echo "Installing plugin: $plugin"

  if ! lnms plugin:installed "$plugin"; then
    if ! lnms plugin:add "$plugin"; then  
      echo "Error installing $plugin" >&2
      exit 1
    fi
    echo "Installed $plugin"
  else
    echo "$plugin already installed"
  fi

done
