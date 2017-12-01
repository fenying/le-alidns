#!/bin/bash

# Initialize the path to root of LE-AliDNS
export LEALIDNS_ACTION=renew-all
export LEALIDNS_ROOT=$(dirname "$0")/
export LEALIDNS_CONFIG_BASH_RC=${LEALIDNS_ROOT}.config.bash_rc

# Load configuration
sh ${LEALIDNS_ROOT}actions/load-config.sh

if [[ ! -f $LEALIDNS_CONFIG_BASH_RC ]]
then
    echo "Failed to load configurations."
    exit -1;
fi

source $LEALIDNS_CONFIG_BASH_RC

rm -f $LEALIDNS_CONFIG_BASH_RC

declare WRITE_LOG_TARGET=$CFG_LOG_FILE

write_log() {

    echo $1;
    echo $1 >> $WRITE_LOG_TARGET;
}

if [[ "$CFG_ON_START" != "" && -x $CFG_ON_START ]]; then
    write_log "Executing hook[before-cert] ${CFG_ON_START}...";
    $CFG_ON_START
fi

write_log "Renew task started at $(date '+%Y-%m-%d %H:%M:%S')";

# The path to list file of DNS record id
export RECORD_ID_LIST_FILE=./dns-records

rm -f $RECORD_ID_LIST_FILE

mkdir ${LEALIDNS_ROOT}domains -p

if [ "$LEALIDNS_FORCE" == "1" ]
then

    CERTBOT_RESULT=$($CFG_CERTBOT_ROOT/certbot-auto renew \
        --manual \
        --force-renew \
        --manual-public-ip-logging-ok \
        --preferred-challenges dns \
        --agree-tos \
        --email $CFG_EMAIL \
        --rsa-key-size $CFG_RSA_KEY_SIZE \
        $CFG_ON_NEW_CERT \
        --manual-auth-hook ${LEALIDNS_ROOT}actions/create-dns-record.sh)
else

    CERTBOT_RESULT=$($CFG_CERTBOT_ROOT/certbot-auto renew \
        --manual \
        --manual-public-ip-logging-ok \
        --preferred-challenges dns \
        --agree-tos \
        --email $CFG_EMAIL \
        --rsa-key-size $CFG_RSA_KEY_SIZE \
        $CFG_ON_NEW_CERT \
        --manual-auth-hook ${LEALIDNS_ROOT}actions/create-dns-record.sh)
fi

write_log "Details: $CERTBOT_RESULT";

sh ${LEALIDNS_ROOT}actions/clean-dns-record.sh

if [[ "$CFG_ON_END" != "" && -x $CFG_ON_END ]]; then
    write_log "Executing hook[after-cert] ${CFG_ON_END}...";
    $CFG_ON_END
fi;
