#!/usr/bin/with-contenv sh

SIDECAR_SNNMPTRAPD=${SIDECAR_SNNMPTRAPD:-0}
LIBRENMS_SNMP_COMMUNITY=${LIBRENMS_SNMP_COMMUNITY:-librenmsdocker}
SNMP_ACTION=${SNMP_ACTION:-log,execute,net}
SNMPV3_USER=${SNMPV3_USER:-librenms_user}
SNMPV3_AUTH=${SNMPV3_AUTH:-auth_pass}
SNMPV3_PRIV=${SNMPV3_PRIV:-priv_pass}
SNMPV3_AUTH_PROTO=${SNMPV3_AUTH_PROTO:-SHA}
SNMPV3_PRIV_PROTO=${SNMPV3_PRIV_PROTO:-AES}
SNMPV3_SECURITY_LEVEL=${SNMPV3_SECURITY_LEVEL:-priv}
SNMP_ENGINEID=${SNMP_ENGINEID:-1234567890}
DISABLE_AUTHORIZATION=${DISABLE_AUTHORIZATION:-yes}

# Continue only if sidecar snmptrapd container
if [ "$SIDECAR_SNNMPTRAPD" != "1" ]; then
  exit 0
fi

echo ">>"
echo ">> Sidecar snmptrapd container detected"
echo ">>"

mkdir -p /run/snmptrapd
chown -R librenms. /run/snmptrapd

sed -ie "s/@LIBRENMS_SNMP_COMMUNITY@/${LIBRENMS_SNMP_COMMUNITY}/" /etc/snmp/snmptrapd.conf
sed -ie "s/@SNMP_ACTION@/${SNMP_ACTION}/" /etc/snmp/snmptrapd.conf
sed -ie "s/@SNMPV3_USER@/${SNMPV3_USER}/" /etc/snmp/snmptrapd.conf
sed -ie "s/@SNMPV3_AUTH@/${SNMPV3_AUTH}/" /etc/snmp/snmptrapd.conf
sed -ie "s/@SNMPV3_PRIV@/${SNMPV3_PRIV}/" /etc/snmp/snmptrapd.conf
sed -ie "s/@SNMPV3_AUTH_PROTO@/${SNMPV3_AUTH_PROTO}/" /etc/snmp/snmptrapd.conf
sed -ie "s/@SNMPV3_PRIV_PROTO@/${SNMPV3_PRIV_PROTO}/" /etc/snmp/snmptrapd.conf
sed -ie "s/@SNMPV3_SECURITY_LEVEL@/${SNMPV3_SECURITY_LEVEL}/" /etc/snmp/snmptrapd.conf
sed -ie "s/@SNMP_ENGINEID@/${SNMP_ENGINEID}/" /etc/snmp/snmptrapd.conf
sed -ie "s/@DISABLE_AUTHORIZATION@/${DISABLE_AUTHORIZATION}/" /etc/snmp/snmptrapd.conf

# Create service
mkdir -p /etc/services.d/snmptrapd
cat > /etc/services.d/snmptrapd/run <<EOL
#!/usr/bin/execlineb -P
with-contenv
/usr/sbin/snmptrapd -f -m ALL -M /opt/librenms/mibs:/opt/librenms/mibs/cisco udp:162 tcp:162
EOL
chmod +x /etc/services.d/snmptrapd/run
