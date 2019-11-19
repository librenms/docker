#!/usr/bin/with-contenv sh

if [ -n "${PGID}" ] && [ "${PGID}" != "$(id -g librenms)" ]; then
  echo "Switching to PGID ${PGID}..."
  sed -i -e "s/^librenms:\([^:]*\):[0-9]*/librenms:\1:${PGID}/" /etc/group
  sed -i -e "s/^librenms:\([^:]*\):\([0-9]*\):[0-9]*/librenms:\1:\2:${PGID}/" /etc/passwd
fi
if [ -n "${PUID}" ] && [ "${PUID}" != "$(id -u librenms)" ]; then
  echo "Switching to PUID ${PUID}..."
  sed -i -e "s/^librenms:\([^:]*\):[0-9]*:\([0-9]*\)/librenms:\1:${PUID}:\2/" /etc/passwd
fi
