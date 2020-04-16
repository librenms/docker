#!/usr/bin/with-contenv sh

SIDECAR_DISPATCHER=${SIDECAR_DISPATCHER:-0}

# Continue only if sidecar dispatcher container
if [ "$SIDECAR_DISPATCHER" != "1" ]; then
  exit 0
fi

echo ">>"
echo ">> Sidecar dispatcher container detected"
echo ">>"

# Create service
mkdir -p /etc/services.d/librenms
cat > /etc/services.d/librenms/run <<EOL
#!/usr/bin/execlineb -P
with-contenv
/opt/librenms/librenms-service.py -v
EOL
chmod +x /etc/services.d/librenms/run
