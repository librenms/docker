#!/usr/bin/with-contenv bash
# shellcheck shell=bash
set -e

if [ ${LOGROTATE_ENABLED:-false} = true ]
then
    logrotate_filename="/etc/logrotate.d/librenms"

    echo -e "${LIBRENMS_PATH}/logs/*.log {" > ${logrotate_filename}
    echo -e "\tsu librenms librenms" >> ${logrotate_filename}
    echo -e "\tcreate 664 librenms librenms" >> ${logrotate_filename}
    echo -e "\t${LOGROTATE_INTERVAL:-weekly}" >> ${logrotate_filename}
    echo -e "\trotate ${LOGROTATE_RETENTION:-6}" >> ${logrotate_filename}

    if [ ${LOGROTATE_COMPRESSION_ENABLED:-true} = true ]
    then
        echo -e "\tcompress" >> ${logrotate_filename}
    fi

    if [ ${LOGROTATE_DELAYCOMPRESSION_ENABLED:-true} = true ]
    then
        echo -e "\tdelaycompress" >> ${logrotate_filename}
    fi

    if [ ${LOGROTATE_MISSINGOK_ENABLED:-true} = true ]
    then
        echo -e "\tmissingok" >> ${logrotate_filename}
    fi

    if [ ${LOGROTATE_NOTIFEMPTY_ENABLED:-true} = true ]
    then
        echo -e "\tnotifempty" >> ${logrotate_filename}
    fi

    echo -e "}" >> ${logrotate_filename}    
fi