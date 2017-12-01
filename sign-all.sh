#!/bin/bash

# Initialize the path to root of LE-AliDNS
export LEALIDNS_ACTION=sign-all
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

# The path to list file of DNS record id
export RECORD_ID_LIST_FILE=./dns-records

rm -f $RECORD_ID_LIST_FILE

declare WRITE_LOG_TARGET=$CFG_LOG_FILE

write_log() {

    echo $1;
    echo $1 >> $WRITE_LOG_TARGET;
}

if [[ "$CFG_ON_START" != "" && -x $CFG_ON_START ]]; then
    write_log "Executing hook[before-cert] ${CFG_ON_START}...";
    $CFG_ON_START
fi

write_log "Sign task started at $(date '+%Y-%m-%d %H:%M:%S')";

mkdir ${LEALIDNS_ROOT}domains -p

# Split domains by ","

strsplitby() {
    local OLD_IFS="$IFS";
    IFS="$1";
    local STR_SPLIT_RESULT=("$2");
    echo $STR_SPLIT_RESULT;
    IFS="$OLD_IFS";
}

CFG_DOMAINS=("$CFG_DOMAINS")

echo "Requesting signing certificates for domains..."
echo ""

for domain in ${CFG_DOMAINS[@]}
do
    DOMAIN_DIR=${LEALIDNS_ROOT}domains/$domain/

    if [ -f ${DOMAIN_DIR}lock ]
    then
        write_log "! Domain '${domain}' is alredy signed, ignored."
        write_log "  Please use renew command to refresh it."
        write_log ""
        continue;
    fi;

    mkdir $DOMAIN_DIR -p

    if [[ $domain =~ "," ]]
    then
        domains=$(strsplitby "," "$domain");
        for item in ${domains[@]}
        do
            ARG_DOMAINS="$ARG_DOMAINS -d $item"
        done

        write_log "Requesting certificate for domains '${domain}'..."
    else

        ARG_DOMAINS="-d $domain"

        write_log "Requesting certificate for domain '${domain}'..."
    fi

    if [[ "$LEALIDNS_DRY_RUN" != "1" ]]
    then
        CERTBOT_RESULT=$($CFG_CERTBOT_ROOT/certbot-auto certonly \
            --manual \
            --manual-public-ip-logging-ok \
            --preferred-challenges dns \
            --agree-tos \
            --email $CFG_EMAIL \
            --rsa-key-size $CFG_RSA_KEY_SIZE \
            $ARG_DOMAINS \
            $CFG_ON_NEW_CERT \
            --manual-auth-hook ${LEALIDNS_ROOT}actions/create-dns-record.sh)
    fi;

    write_log "Details: $CERTBOT_RESULT"

    touch ${DOMAIN_DIR}lock
done

sh ${LEALIDNS_ROOT}actions/clean-dns-record.sh

if [[ "$CFG_ON_END" != "" && -x $CFG_ON_END ]]; then
    write_log "Executing hook[after-cert] ${CFG_ON_END}...";
    $CFG_ON_END
fi;
