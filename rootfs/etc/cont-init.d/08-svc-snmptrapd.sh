#!/usr/bin/with-contenv sh

SIDECAR_SNNMPTRAPD=${SIDECAR_SNNMPTRAPD:-0}
LIBRENMS_SNMP_COMMUNITY=${LIBRENMS_SNMP_COMMUNITY:-librenmsdocker}

# Continue only if sidecar snmptrapd container
if [ "$SIDECAR_SNNMPTRAPD" != "1" ]; then
  exit 0
fi

echo ">>"
echo ">> Sidecar snmptrapd container detected"
echo ">>"

mkdir -p /data/snmptrapd /run/snmptrapd
chown librenms. /data/snmptrapd
chown -R librenms. /run/snmptrapd

sed -ie "s/@LIBRENMS_SNMP_COMMUNITY@/${LIBRENMS_SNMP_COMMUNITY}/" /etc/snmp/snmptrapd.conf

# Create service
mkdir -p /etc/services.d/snmptrapd
cat > /etc/services.d/snmptrapd/run <<EOL
#!/usr/bin/execlineb -P
with-contenv
/usr/sbin/snmptrapd -f -m ALL -M /opt/librenms/mibs:/opt/librenms/mibs/cisco udp:162 tcp:162
EOL
chmod +x /etc/services.d/snmptrapd/run
