#!/usr/bin/with-contenv sh
# shellcheck shell=sh
set -e

SIDECAR_SNMPTRAPD=${SIDECAR_SNMPTRAPD:-0}
LIBRENMS_SNMP_COMMUNITY=${LIBRENMS_SNMP_COMMUNITY:-librenmsdocker}
SNMP_PROCESSING_TYPE=${SNMP_PROCESSING_TYPE:-log,execute,net}
SNMP_USER=${SNMP_USER:-librenms_user}
SNMP_AUTH=${SNMP_AUTH:-auth_pass}
SNMP_PRIV=${SNMP_PRIV:-priv_pass}
SNMP_AUTH_PROTO=${SNMP_AUTH_PROTO:-SHA}
SNMP_PRIV_PROTO=${SNMP_PRIV_PROTO:-AES}
SNMP_SECURITY_LEVEL=${SNMP_SECURITY_LEVEL:-priv}
SNMP_ENGINEID=${SNMP_ENGINEID:-1234567890}
SNMP_DISABLE_AUTHORIZATION=${SNMP_DISABLE_AUTHORIZATION:-yes}

# Continue only if sidecar snmptrapd container
if [ "$SIDECAR_SNMPTRAPD" != "1" ]; then
  exit 0
fi

echo ">>"
echo ">> Sidecar snmptrapd container detected"
echo ">>"

mkdir -p /run/snmptrapd
chown -R librenms:librenms /run/snmptrapd

sed -ie "s/@LIBRENMS_SNMP_COMMUNITY@/${LIBRENMS_SNMP_COMMUNITY}/" /etc/snmp/snmptrapd.conf
sed -ie "s/@SNMP_PROCESSING_TYPE@/${SNMP_PROCESSING_TYPE}/" /etc/snmp/snmptrapd.conf
sed -ie "s/@SNMP_USER@/${SNMP_USER}/" /etc/snmp/snmptrapd.conf
sed -ie "s/@SNMP_AUTH@/${SNMP_AUTH}/" /etc/snmp/snmptrapd.conf
sed -ie "s/@SNMP_PRIV@/${SNMP_PRIV}/" /etc/snmp/snmptrapd.conf
sed -ie "s/@SNMP_AUTH_PROTO@/${SNMP_AUTH_PROTO}/" /etc/snmp/snmptrapd.conf
sed -ie "s/@SNMP_PRIV_PROTO@/${SNMP_PRIV_PROTO}/" /etc/snmp/snmptrapd.conf
sed -ie "s/@SNMP_SECURITY_LEVEL@/${SNMP_SECURITY_LEVEL}/" /etc/snmp/snmptrapd.conf
sed -ie "s/@SNMP_ENGINEID@/${SNMP_ENGINEID}/" /etc/snmp/snmptrapd.conf
sed -ie "s/@SNMP_DISABLE_AUTHORIZATION@/${SNMP_DISABLE_AUTHORIZATION}/" /etc/snmp/snmptrapd.conf

# Create service
mkdir -p /etc/services.d/snmptrapd
cat >/etc/services.d/snmptrapd/run <<EOL
#!/usr/bin/execlineb -P
with-contenv
/usr/sbin/snmptrapd -f -m ALL -M /opt/librenms/mibs:/opt/librenms/mibs/cisco$:{SNMP_EXTRA_MIB_DIRS} udp:162 tcp:162
EOL
chmod +x /etc/services.d/snmptrapd/run
