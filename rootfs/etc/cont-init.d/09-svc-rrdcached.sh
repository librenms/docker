#!/usr/bin/with-contenv sh

MONOLITHIC=${MONOLITHIC:-0}
SIDECAR_RRDCACHED=${SIDECAR_RRDCACHED:-0}

# Continue only if sidecar rrdcached container
if [ "$MONOLITHIC" == "1" ]; then
  echo "Configuring rrdcached in monolithic mode"
elif [ "$SIDECAR_RRDCACHED" != "1" ]; then
  exit 0
else
  echo ">>"
  echo ">> Sidecar rrdcached container detected"
  echo ">>"
fi

RRDCACHED_WRITE_TIMEOUT=${RRDCACHED_WRITE_TIMEOUT:-1800}
RRDCACHED_WRITE_JITTER=${RRDCACHED_WRITE_JITTER:-1800}
RRDCACHED_WRITE_THREADS=${RRDCACHED_WRITE_THREADS:-4}
RRDCACHED_FLUSH_INTERVAL=${RRDCACHED_FLUSH_INTERVAL:-3600}

mkdir -p /data/rrdcached /var/lib/rrdcached /run/rrdcached
chown -R librenms. /data/rrdcached /run/rrdcached

# Create service
mkdir -p /etc/services.d/rrdcached
cat > /etc/services.d/rrdcached/run <<EOL
#!/usr/bin/execlineb -P
with-contenv
/usr/sbin/rrdcached \
 -g -B -R -F \
 -w ${RRDCACHED_WRITE_TIMEOUT} \
 -z ${RRDCACHED_WRITE_JITTER} \
 -f ${RRDCACHED_FLUSH_INTERVAL} \
 -t ${RRDCACHED_WRITE_THREADS} \
 -U librenms -G librenms \
 -p /run/rrdcached/rrdcached.pid \
 -j /var/lib/rrdcached/journal/ \
 -V LOG_DEBUG \
 -l 0:42217 \
 -b /data/rrd/
EOL
chmod +x /etc/services.d/rrdcached/run

