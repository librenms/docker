#!/usr/bin/with-contenv bash
# shellcheck shell=bash
set -e

if [ ${LOGROTATE_ENABLED:-false} = true ]
then
    logrotate_filename="/etc/logrotate.d/librenms"

    echo -e "${LIBRENMS_PATH}/logs/*.log {" > ${logrotate_filename}
    echo -e "\tsu librenms librenms" >> ${logrotate_filename}
    echo -e "\tcreate 664 librenms librenms" >> ${logrotate_filename}
    echo -e "\tweekly" >> ${logrotate_filename}
    echo -e "\trotate 6" >> ${logrotate_filename}
    echo -e "\tcompress" >> ${logrotate_filename}
    echo -e "\tdelaycompress" >> ${logrotate_filename}
    echo -e "\tmissingok" >> ${logrotate_filename}
    echo -e "\tnotifempty" >> ${logrotate_filename}
    echo -e "}" >> ${logrotate_filename}    
fi
