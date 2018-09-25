FROM alpine:3.8

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

LABEL maintainer="CrazyMax" \
  org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.name="librenms" \
  org.label-schema.description="LibreNMS based on Alpine Linux and Nginx" \
  org.label-schema.version=$VERSION \
  org.label-schema.url="https://github.com/crazy-max/docker-librenms" \
  org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.vcs-url="https://github.com/crazy-max/docker-librenms" \
  org.label-schema.vendor="CrazyMax" \
  org.label-schema.schema-version="1.0"

RUN apk --update --no-cache add \
    acl \
    bash \
    binutils \
    ca-certificates \
    coreutils \
    curl \
    fping \
    git \
    graphviz \
    imagemagick \
    mtr \
    mysql-client \
    net-snmp \
    net-snmp-tools \
    nginx \
    nmap \
    openssl \
    php7 \
    php7-cli \
    php7-ctype \
    php7-curl \
    php7-fpm \
    php7-gd \
    php7-json \
    php7-mbstring \
    php7-mcrypt \
    php7-memcached \
    php7-mysqli \
    php7-opcache \
    php7-openssl \
    php7-pdo \
    php7-pdo_mysql \
    php7-phar \
    php7-posix \
    php7-session \
    php7-simplexml \
    php7-snmp \
    php7-tokenizer \
    php7-xml \
    php7-zip \
    py-mysqldb \
    py2-pip \
    python2 \
    rrdtool \
    runit \
    shadow \
    supervisor \
    syslog-ng \
    tzdata  \
    util-linux \
    whois \
    ttf-dejavu \
  && pip install python-memcached \
  && sed -i -e "s/;date\.timezone.*/date\.timezone = UTC/" /etc/php7/php.ini \
  && rm -rf /var/cache/apk/* /var/www/* /tmp/* \
  && setcap cap_net_raw+ep /usr/bin/nmap \
  && setcap cap_net_raw+ep /usr/sbin/fping

ENV LIBRENMS_VERSION="1.43" \
  LIBRENMS_PATH="/opt/librenms" \
  DATA_PATH="/data" \
  CRONTAB_PATH="/var/spool/cron/crontabs"

RUN mkdir -p /opt \
  && addgroup -g 1000 librenms \
  && adduser -u 1000 -G librenms -h ${LIBRENMS_PATH} -s /bin/sh -D librenms \
  && passwd -l librenms \
  && usermod -a -G librenms nginx \
  && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer \
  && git clone --branch ${LIBRENMS_VERSION} https://github.com/librenms/librenms.git ${LIBRENMS_PATH} \
  && chown -R librenms. ${LIBRENMS_PATH} \
  && su - librenms -c "composer install --no-dev --no-interaction --no-ansi --working-dir=${LIBRENMS_PATH}" \
  && wget -q https://raw.githubusercontent.com/librenms/librenms-agent/master/snmp/distro -O /usr/bin/distro \
  && chmod +x /usr/bin/distro \
  && rm -rf /tmp/*

COPY entrypoint.sh /entrypoint.sh
COPY assets /

RUN mkdir -p /data ${LIBRENMS_PATH}/config.d /var/log/supervisord \
  && chmod a+x /entrypoint.sh /usr/local/bin/* \
  && cp ${LIBRENMS_PATH}/snmpd.conf.example /etc/snmp/snmpd.conf \
  && cp ${LIBRENMS_PATH}/config.php.default ${LIBRENMS_PATH}/config.php \
  && echo "foreach (glob(\"${DATA_PATH}/config/*.php\") as \$filename) include \$filename;" >> ${LIBRENMS_PATH}/config.php \
  && echo "foreach (glob(\"${LIBRENMS_PATH}/config.d/*.php\") as \$filename) include \$filename;" >> ${LIBRENMS_PATH}/config.php \
  && chown -R librenms. ${DATA_PATH} ${LIBRENMS_PATH} \
  && chown -R nginx. /var/lib/nginx /var/log/nginx /var/log/php7 /var/tmp/nginx

EXPOSE 80 514 514/udp
WORKDIR ${LIBRENMS_PATH}
VOLUME [ "${DATA_PATH}" ]

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/usr/bin/supervisord", "-c", "/etc/supervisord.conf" ]
