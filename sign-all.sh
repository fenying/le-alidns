#!/bin/bash

# Initialize the path to root of LE-AliDNS
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

mkdir ${LEALIDNS_ROOT}domains -p

# Initialize PATH with path to root of certbot.
export PATH=$PATH:$CFG_CERTBOT_ROOT

# Split domains by ","
OLD_IFS="$IFS" 
IFS="," 
CFG_DOMAINS=($CFG_DOMAINS) 
IFS="$OLD_IFS"

echo "Requesting signing certificates for domains..."
echo ""

for domain in ${CFG_DOMAINS[@]}
do

    DOMAIN_DIR=${LEALIDNS_ROOT}domains/$domain/

    if [ -f ${DOMAIN_DIR}lock ]
    then
        echo "! Domain '${domain}' is alredy signed certificated, ignored."
        echo "  Please use renew command to refresh it."
        echo ""
        continue;
    fi;

    mkdir $DOMAIN_DIR -p

    echo "Requesting certificate for domain '${domain}'..."

    CERT_RESULT=$(certbot-auto certonly \
        --manual \
        --manual-public-ip-logging-ok \
        --preferred-challenges dns \
        --agree-tos \
        --email $CFG_EMAIL \
        --rsa-key-size $CFG_RSA_KEY_SIZE \
        -d $domain \
        --manual-auth-hook ${LEALIDNS_ROOT}actions/create-dns-record.sh)

    echo "Details: $CERT_RESULT" >> $CFG_LOG_FILE

    touch ${DOMAIN_DIR}lock
done

sh ${LEALIDNS_ROOT}actions/clean-dns-record.sh
