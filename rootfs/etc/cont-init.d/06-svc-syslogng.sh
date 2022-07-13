#!/usr/bin/with-contenv sh

MONOLITHIC=${MONOLITHIC:-0}
SIDECAR_SYSLOGNG=${SIDECAR_SYSLOGNG:-0}

# Continue only if sidecar syslogng container
if [ "$MONOLITHIC" == "1" ]; then
  echo "Configuring syslog-ng in monolithic mode"
elif [ "$SIDECAR_SYSLOGNG" != "1" ]; then
  exit 0
else
  echo ">>"
  echo ">> Sidecar syslog-ng container detected"
  echo ">>"
fi



mkdir -p /data/syslog-ng /run/syslog-ng
chown librenms. /data/syslog-ng
chown -R librenms. /run/syslog-ng

# Create service
mkdir -p /etc/services.d/syslogng
cat > /etc/services.d/syslogng/run <<EOL
#!/usr/bin/execlineb -P
with-contenv
/usr/sbin/syslog-ng -F
EOL
chmod +x /etc/services.d/syslogng/run
