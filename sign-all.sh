#!/bin/bash

# Initialize the path to root of LE-AliDNS
export LEALIDNS_ACTION=sign-all
export LEALIDNS_ROOT=$(cd `dirname $0`; pwd)/

# Load configuration
source ${LEALIDNS_ROOT}actions/load-config.sh

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

if [[ "$CFG_NO_AUTO_UPGRADE" == "on" ]]; then
    NO_AUTO_UPGRADE="--no-bootstrap --no-self-upgrade"
    write_log "Turned off certbot aoto-updates.";
fi

write_log "Sign task started at $(date '+%Y-%m-%d %H:%M:%S')";

# Split domains by ","

strsplitby() {
    local OLD_IFS="$IFS";
    IFS="$1";
    local STR_SPLIT_RESULT=("$2");
    echo $STR_SPLIT_RESULT;
    IFS="$OLD_IFS";
}

CFG_DOMAINS=("$CFG_DOMAINS")

echo "Requesting certificates for domains..."
echo ""

CERTS_ROOT=/etc/letsencrypt/live/

for domain in ${CFG_DOMAINS[@]}
do

    if [[ -f "${LEALIDNS_ROOT}domains/${domain}/lock" ]]
    then
        write_log "! Domain '${domain}' is alredy signed, ignored."
        write_log "  Please use renew command to refresh it."
        write_log ""
        continue;
    fi;

    if [[ $domain =~ "," ]]
    then
        domains=$(strsplitby "," "$domain");
        for item in ${domains[@]}
        do
            ARG_DOMAINS="$ARG_DOMAINS -d $item"
        done

        if [[ "$ARG_DOMAINS" == "" ]]; then
            continue;
        fi

        write_log "Requesting certificate for domains '${domain}'..."
    else

        if [ -f ${CERTS_ROOT}${domain}/cert.pem ]
        then
            write_log "! Domain '${domain}' is alredy signed, ignored."
            write_log "  Please use renew command to refresh it."
            write_log ""
            continue;
        fi;

        ARG_DOMAINS="-d $domain"

        write_log "Requesting certificate for domain '${domain}'..."
    fi

    if [[ "$LEALIDNS_DRY_RUN" != "1" ]]
    then
        CERTBOT_RESULT=$($CFG_CERTBOT_ROOT/$CFG_CERTBOT_CMD certonly \
            --manual \
            --manual-public-ip-logging-ok \
            --preferred-challenges dns \
            --agree-tos \
            --email $CFG_EMAIL \
            --rsa-key-size $CFG_RSA_KEY_SIZE \
            $ARG_DOMAINS \
            $CFG_ON_NEW_CERT \
            $NO_AUTO_UPGRADE \
            --manual-auth-hook ${LEALIDNS_ROOT}actions/create-dns-record.sh)
    fi;

    if [[ ! $domain =~ "," ]]; then
        mkdir -p "${LEALIDNS_ROOT}domains/${domain}";
        touch "${LEALIDNS_ROOT}domains/${domain}/lock";
    fi

    write_log "Details: $CERTBOT_RESULT"
done

sh ${LEALIDNS_ROOT}actions/clean-dns-record.sh

if [[ "$CFG_ON_END" != "" && -x $CFG_ON_END ]]; then
    write_log "Executing hook[after-cert] ${CFG_ON_END}...";
    $CFG_ON_END
fi;
