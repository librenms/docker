#!/usr/bin/with-contenv sh
# shellcheck shell=sh
set -e

SIDECAR_SYSLOGNG=${SIDECAR_SYSLOGNG:-0}

# Continue only if sidecar syslogng container
if [ "$SIDECAR_SYSLOGNG" != "1" ]; then
  exit 0
fi

echo ">>"
echo ">> Sidecar syslog-ng container detected"
echo ">>"

mkdir -p /data/syslog-ng /run/syslog-ng
chown librenms:librenms /data/syslog-ng
chown -R librenms:librenms /run/syslog-ng

# Create service
mkdir -p /etc/services.d/syslogng
cat >/etc/services.d/syslogng/run <<EOL
#!/usr/bin/execlineb -P
with-contenv
/usr/sbin/syslog-ng -F
EOL
chmod +x /etc/services.d/syslogng/run
