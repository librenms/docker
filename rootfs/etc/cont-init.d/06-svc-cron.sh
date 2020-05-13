#!/usr/bin/with-contenv sh

CRONTAB_PATH="/var/spool/cron/crontabs"
SIDECAR_CRON=${SIDECAR_CRON:-0}

LIBRENMS_POLLER_THREADS=${LIBRENMS_POLLER_THREADS:-16}
LIBRENMS_POLLER_INTERVAL=${LIBRENMS_POLLER_INTERVAL:-5}

LIBRENMS_CRON_DISCOVERY_ENABLE=${LIBRENMS_CRON_DISCOVERY_ENABLE:-true}
LIBRENMS_CRON_DISCOVERY_WRAPPER_WORKERS=${LIBRENMS_CRON_DISCOVERY_WRAPPER_WORKERS:-1}
LIBRENMS_CRON_DAILY_ENABLE=${LIBRENMS_CRON_DAILY_ENABLE:-true}
LIBRENMS_CRON_ALERTS_ENABLE=${LIBRENMS_CRON_ALERTS_ENABLE:-true}
LIBRENMS_CRON_BILLING_ENABLE=${LIBRENMS_CRON_BILLING_ENABLE:-true}
LIBRENMS_CRON_BILLING_CALCULATE_ENABLE=${LIBRENMS_CRON_BILLING_CALCULATE_ENABLE:-true}
LIBRENMS_CRON_CHECK_SERVICES_ENABLE=${LIBRENMS_CRON_CHECK_SERVICES_ENABLE:-true}
LIBRENMS_CRON_POLLER_ENABLE=${LIBRENMS_CRON_POLLER_ENABLE:-true}
LIBRENMS_CRON_SNMPSCAN_ENABLE=${LIBRENMS_CRON_SNMPSCAN_ENABLE:-false}
LIBRENMS_CRON_SNMPSCAN_INTERVAL=${LIBRENMS_CRON_SNMPSCAN_INTERVAL:-"5 0"}
LIBRENMS_CRON_SNMPSCAN_NETS=${LIBRENMS_CRON_SNMPSCAN_NETS:-""}
LIBRENMS_CRON_SNMPSCAN_NETS=${LIBRENMS_CRON_SNMPSCAN_NETS:+",$LIBRENMS_CRON_SNMPSCAN_NETS"}
LIBRENMS_CRON_SNMPSCAN_NETS=${LIBRENMS_CRON_SNMPSCAN_NETS//,/ -r }
LIBRENMS_CRON_SNMPSCAN_THREADS=${LIBRENMS_CRON_SNMPSCAN_THREADS:-32}
LIBRENMS_CRON_SNMPSCAN_LOGFILE=${LIBRENMS_CRON_SNMPSCAN_LOGFILE:-/dev/null}

# Continue only if sidecar cron container
if [ "$SIDECAR_CRON" != "1" ]; then
  exit 0
fi

echo ">>> WARNING: Sidecar cron container is deprecated and will be removed soon."
echo ">>> Please switch to the dispatcher service."
echo ">>> https://github.com/librenms/docker/blob/master/doc/notes/dispatcher-service.md"

rm -rf ${CRONTAB_PATH}
mkdir -m 0644 -p ${CRONTAB_PATH}
touch ${CRONTAB_PATH}/librenms

# Add crontab
cat "${LIBRENMS_PATH}/librenms.nonroot.cron" > ${CRONTAB_PATH}/librenms
sed -i -e "s/ librenms //" ${CRONTAB_PATH}/librenms

if [ "$LIBRENMS_CRON_DISCOVERY_ENABLE" != "true" ]; then
  echo "Disable discovery cron"
  sed -i "/discovery-wrapper.py/d" ${CRONTAB_PATH}/librenms
  sed -i "/discovery.php/d" ${CRONTAB_PATH}/librenms
else
  echo "Enable discovery cron"
  sed -i -e "s/discovery-wrapper.py 1/discovery-wrapper.py ${LIBRENMS_CRON_DISCOVERY_WRAPPER_WORKERS}/" ${CRONTAB_PATH}/librenms
fi

if [ "$LIBRENMS_CRON_DAILY_ENABLE" != "true" ]; then
  echo "Disable daily script cron"
  sed -i "/daily.sh/d" ${CRONTAB_PATH}/librenms
else
  echo "Enable daily script cron"
fi

if [ "$LIBRENMS_CRON_ALERTS_ENABLE" != "true" ]; then
  echo "Disable alerts generation cron"
  sed -i "/alerts.php/d" ${CRONTAB_PATH}/librenms
else
  echo "Enable alerts generation cron"
fi

if [ "$LIBRENMS_CRON_BILLING_ENABLE" != "true" ]; then
  echo "Disable billing polling cron"
  sed -i "/poll-billing.php/d" ${CRONTAB_PATH}/librenms
else
  echo "Enable billing polling cron"
fi

if [ "$LIBRENMS_CRON_BILLING_CALCULATE_ENABLE" != "true" ]; then
  echo "Disable billing cron"
  sed -i "/billing-calculate.php/d" ${CRONTAB_PATH}/librenms
else
  echo "Enable billing cron"
fi

if [ "$LIBRENMS_CRON_CHECK_SERVICES_ENABLE" != "true" ]; then
  echo "Disable service checks cron"
  sed -i "/check-services.php/d" ${CRONTAB_PATH}/librenms
else
  echo "Enable service checks cron"
fi

sed -i "/poller-wrapper.py/d" ${CRONTAB_PATH}/librenms
if [ "$LIBRENMS_CRON_POLLER_ENABLE" = "true" ]; then
  echo "Enable polling cron"
  cat >> ${CRONTAB_PATH}/librenms <<EOL
*/${LIBRENMS_POLLER_INTERVAL}  *    * * *     /opt/librenms/cronic /opt/librenms/poller-wrapper.py ${LIBRENMS_POLLER_THREADS}
EOL
else
  echo "Disable polling cron"
fi

if [ "$LIBRENMS_CRON_SNMPSCAN_ENABLE" = "true" ]; then
  echo "Enable snmp-scan cron"
  cat >> ${CRONTAB_PATH}/librenms <<EOL
${LIBRENMS_CRON_SNMPSCAN_INTERVAL}    * * *     /opt/librenms/snmp-scan.py ${LIBRENMS_CRON_SNMPSCAN_NETS} -t ${LIBRENMS_CRON_SNMPSCAN_THREADS} >> ${LIBRENMS_CRON_SNMPSCAN_LOGFILE} 2>&1
EOL
else
  echo "Disable snmp-scan cron"
fi

# Fix perms
echo "Fixing crontabs permissions..."
chmod -R 0644 ${CRONTAB_PATH}

# Create service
mkdir -p /etc/services.d/cron
cat > /etc/services.d/cron/run <<EOL
#!/usr/bin/execlineb -P
with-contenv
exec busybox crond -f -L /dev/stdout
EOL
chmod +x /etc/services.d/cron/run
