#!/bin/bash

if [ -z "$CERTBOT_DOMAIN" ] || [ -z "$CERTBOT_VALIDATION" ]
then
    echo "EMPTY DOMAIN OR VALIDATION"
    exit -1
fi

echo "Certbot Domain: ${CERTBOT_DOMAIN}" >> $CFG_LOG_FILE

echo "Certbot Validation: ${CERTBOT_VALIDATION}" >> $CFG_LOG_FILE

API_DomainName=$(echo $CERTBOT_DOMAIN | grep -P "\w+\.\w+$" -o)
DomainRecord=$(echo $CERTBOT_DOMAIN | grep -P ".+(?=\.\w+\.\w+$)" -o)
API_RR=_acme-challenge.$DomainRecord

echo "Domain: ${API_DomainName}" >> $CFG_LOG_FILE

echo "Domain Record: ${DomainRecord}" >> $CFG_LOG_FILE

echo "Target Record: ${API_RR}" >> $CFG_LOG_FILE

API_RESULT=$(aliyuncli alidns AddDomainRecord \
    --DomainName ${API_DomainName} \
    --Type TXT \
    --RR "${API_RR}" \
    --Value "${CERTBOT_VALIDATION}" \
)

echo "API Result: ${API_RESULT}" >> $CFG_LOG_FILE

RecordId=$(echo $API_RESULT | grep -P "\|\s+(\d+)\s+\|" -o | grep -P "\d+" -o)

echo "Record Id: ${RecordId}" >> $CFG_LOG_FILE

echo $RecordId >> $RECORD_ID_LIST_FILE

echo ""
