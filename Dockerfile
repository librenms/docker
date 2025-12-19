# syntax=docker/dockerfile:1

# renovate: datasource=github-releases packageName=librenms/librenms versioning=semver
ARG LIBRENMS_VERSION="25.12.0"
ARG ALPINE_VERSION="3.22"
ARG SYSLOGNG_VERSION="4.8.3-r1"

FROM crazymax/yasu:latest AS yasu
FROM crazymax/alpine-s6:${ALPINE_VERSION}-2.2.0.3
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
    libcap-utils \
    mariadb-client \
    monitoring-plugins \
    mtr \
    net-snmp \
    net-snmp-tools \
    nginx \
    nmap \
    openssl \
    openssh-client \
    perl \
    php83 \
    php83-cli \
    php83-ctype \
    php83-curl \
    php83-dom \
    php83-fileinfo \
    php83-fpm \
    php83-gd \
    php83-gmp \
    php83-iconv \
    php83-json \
    php83-ldap \
    php83-mbstring \
    php83-mysqlnd \
    php83-opcache \
    php83-openssl \
    php83-pdo \
    php83-pdo_mysql \
    php83-pecl-memcached \
    php83-pear \
    php83-phar \
    php83-posix \
    php83-session \
    php83-simplexml \
    php83-snmp \
    php83-sockets \
    php83-tokenizer \
    php83-xml \
    php83-xmlwriter \
    php83-zip \
    python3 \
    py3-pip \
    rrdtool \
    runit \
    sed \
    shadow \
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
  && pip3 install --upgrade --break-system-packages pip \
  && pip3 install python-memcached mysqlclient --upgrade --break-system-packages \
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

ARG SYSLOGNG_VERSION
RUN apk --update --no-cache add syslog-ng=${SYSLOGNG_VERSION}

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
ARG WEATHERMAP_PLUGIN_COMMIT
RUN apk --update --no-cache add -t build-dependencies \
    build-base \
    linux-headers \
    musl-dev \
    python3-dev \
  && echo "Installing LibreNMS https://github.com/librenms/librenms.git#${LIBRENMS_VERSION}..." \
  && git clone --depth=1 --branch ${LIBRENMS_VERSION} https://github.com/librenms/librenms.git . \
  && pip3 install --ignore-installed -r requirements.txt --upgrade --break-system-packages \
  && mkdir config.d \
  && cp config.php.default config.php \
  && cp snmpd.conf.example /etc/snmp/snmpd.conf \
  && sed -i '/runningUser/d' lnms \
  && echo "foreach (glob(\"/data/config/*.php\") as \$filename) include \$filename;" >> config.php \
  && echo "foreach (glob(\"${LIBRENMS_PATH}/config.d/*.php\") as \$filename) include \$filename;" >> config.php \
  && chown -R librenms:librenms ${LIBRENMS_PATH} \
  && su librenms -s /bin/sh -c "COMPOSER_CACHE_DIR=/tmp composer install --no-dev --no-interaction --no-ansi" \
  && apk del build-dependencies \
  && rm -rf .git \
    html/plugins/Test \
    doc/ \
    tests/ \
    /tmp/*

COPY rootfs /

EXPOSE 8000 514 514/udp 162 162/udp
VOLUME [ "/data" ]

ENTRYPOINT [ "/init" ]
