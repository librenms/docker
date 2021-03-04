#!/usr/bin/with-contenv sh

SIDECAR_SNMPTRAPD=${SIDECAR_SNMPTRAPD:-0}
SNMPV3_USER=${SNMPV3_USER:-insecureuser}
SNMPV3_AUTH_PROTO=${SNMPV3_AUTH_PROTO:-sha}
SNMPV3_AUTH_KEY=${SNMPV3_AUTH_KEY:-insecurekey}
SNMPV3_PRIV_PROTO=${SNMPV3_PRIV_PROTO:-aes}
SNMPV3_PRIV_KEY=${SNMPV3_PRIV_KEY:-insecurekey}
DISABLE_SNMP_AUTHORIZATION=${DISABLE_SNMP_AUTHROZATION:-no}
SNMP_TRAP_PROCESSING=${SNMP_TRAP_PROCESSING:-log,execute,net}
SNMP_COMMUNITY=${SNMP_COMMUNITY:-public}

# Continue only if sidecar snmptrapd container
if [ "$SIDECAR_SNMPTRAPD" != "1" ]; then
  exit 0
fi

echo ">>"
echo ">> Sidecar snmptrapd container detected"
echo ">>"

if [ "$DISABLE_SNMP_AUTHORIZATION" = "yes" ]; then
cat > /tmp/snmptrapd.conf <<EOF
disableAuthorization $DISABLE_SNMP_AUTHORIZATION
EOF
fi

cat >> /tmp/snmptrapd.conf <<EOF
createUser $SNMPV3_USER $SNMPV3_AUTH_PROTO $SNMPV3_AUTH_KEY $SNMPV3_PRIV_PROTO $SNMPV3_PRIV_KEY
authUser $SNMP_TRAP_PROCESSING $SNMPV3_USER
authCommunity $SNMP_TRAP_PROCESSING $SNMP_COMMUNITY
traphandle default /opt/librenms/snmptrap.php
EOF

# Create service
mkdir -p /etc/services.d/snmptrapd
cat > /etc/services.d/snmptrapd/run <<EOL
#!/usr/bin/execlineb -P
with-contenv
/usr/sbin/snmptrapd -f -C -c /tmp/snmptrapd.conf -Lo
EOL
chmod +x /etc/services.d/snmptrapd/run
