ARG LIBRENMS_VERSION="21.11.0"

FROM crazymax/yasu:latest AS yasu
FROM crazymax/alpine-s6:3.14-2.2.0.3

COPY --from=yasu / /
RUN apk --update --no-cache add \
    busybox-extras \
    acl \
    bash \
    bind-tools \
    binutils \
    ca-certificates \
    coreutils \
    curl \
    file \
    fping \
    git \
    graphviz \
    imagemagick \
    ipmitool \
    iputils \
    mariadb-client \
    monitoring-plugins \
    mtr \
    net-snmp \
    net-snmp-tools \
    nginx \
    nmap \
    openssl \
    perl \
    php7 \
    php7-cli \
    php7-ctype \
    php7-curl \
    php7-dom \
    php7-fileinfo \
    php7-fpm \
    php7-gd \
    php7-json \
    php7-ldap \
    php7-mbstring \
    php7-mcrypt \
    php7-memcached \
    php7-mysqlnd \
    php7-opcache \
    php7-openssl \
    php7-pdo \
    php7-pdo_mysql \
    php7-pear \
    php7-phar \
    php7-posix \
    php7-session \
    php7-simplexml \
    php7-snmp \
    php7-sockets \
    php7-tokenizer \
    php7-xml \
    php7-zip \
    python3 \
    py3-pip \
    rrdtool \
    runit \
    shadow \
    syslog-ng=3.30.1-r1 \
    ttf-dejavu \
    tzdata \
    util-linux \
    whois \
  && apk --update --no-cache add -t build-dependencies \
    build-base \
    make \
    mariadb-dev \
    musl-dev \
    python3-dev \
  && pip3 install --upgrade pip \
  && pip3 install python-memcached mysqlclient --upgrade \
  && curl -sSL https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer \
  && apk del build-dependencies \
  && rm -rf /var/www/* /tmp/* \
  && echo "/usr/sbin/fping -6 \$@" > /usr/sbin/fping6 \
  && chmod +x /usr/sbin/fping6 \
  && chmod u+s,g+s \
    /bin/ping \
    /bin/ping6 \
    /usr/lib/monitoring-plugins/check_icmp \
  && setcap cap_net_raw+ep /usr/bin/nmap \
  && setcap cap_net_raw+ep /usr/sbin/fping \
  && setcap cap_net_raw+ep /usr/sbin/fping6 \
  && setcap cap_net_raw+ep /usr/lib/monitoring-plugins/check_icmp \
  && setcap cap_net_raw+ep /usr/lib/monitoring-plugins/check_ping

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS="2" \
  LIBRENMS_PATH="/opt/librenms" \
  LIBRENMS_DOCKER="1" \
  TZ="UTC" \
  PUID="1000" \
  PGID="1000"

RUN addgroup -g ${PGID} librenms \
  && adduser -D -h /home/librenms -u ${PUID} -G librenms -s /bin/sh -D librenms \
  && curl -sSLk -q https://raw.githubusercontent.com/librenms/librenms-agent/master/snmp/distro -o /usr/bin/distro \
  && chmod +x /usr/bin/distro

WORKDIR ${LIBRENMS_PATH}
ARG LIBRENMS_VERSION
RUN apk --update --no-cache add -t build-dependencies \
    build-base \
    linux-headers \
    musl-dev \
    python3-dev \
  && git clone --branch ${LIBRENMS_VERSION} https://github.com/librenms/librenms.git . \
  && pip3 install --ignore-installed -r requirements.txt --upgrade \
  && COMPOSER_CACHE_DIR="/tmp" composer install --no-dev --no-interaction --no-ansi \
  && mkdir config.d \
  && cp config.php.default config.php \
  && cp snmpd.conf.example /etc/snmp/snmpd.conf \
  && sed -i '/runningUser/d' lnms \
  && echo "foreach (glob(\"/data/config/*.php\") as \$filename) include \$filename;" >> config.php \
  && echo "foreach (glob(\"${LIBRENMS_PATH}/config.d/*.php\") as \$filename) include \$filename;" >> config.php \
  && git clone https://github.com/librenms-plugins/Weathermap.git ./html/plugins/Weathermap \
  && chown -R nobody.nogroup ${LIBRENMS_PATH} \
  && apk del build-dependencies \
  && rm -rf .git \
    html/plugins/Test \
    html/plugins/Weathermap/.git \
    html/plugins/Weathermap/configs \
    /tmp/*

COPY rootfs /

EXPOSE 8000 514 514/udp 162 162/udp
VOLUME [ "/data" ]

ENTRYPOINT [ "/init" ]
