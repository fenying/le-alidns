#!/bin/bash

declare WRITE_LOG_TARGET=$CFG_LOG_FILE

write_log() {

    echo $1;
    echo $1 >> $WRITE_LOG_TARGET;
}

if [ -z "$CERTBOT_DOMAIN" ] || [ -z "$CERTBOT_VALIDATION" ]
then
    echo "EMPTY DOMAIN OR VALIDATION"
    exit -1
fi

write_log "Certbot Domain: ${CERTBOT_DOMAIN}";

write_log "Certbot Validation: ${CERTBOT_VALIDATION}";

API_DomainName=$(echo $CERTBOT_DOMAIN | grep -P "\w+\.\w+$" -o)
DomainRecord=$(echo $CERTBOT_DOMAIN | grep -P ".+(?=\.\w+\.\w+$)" -o)
API_RR=_acme-challenge.$DomainRecord

write_log "Domain: ${API_DomainName}";

write_log "Domain Record: ${DomainRecord}";

write_log "Target Record: ${API_RR}";

API_RESULT=$(aliyuncli alidns AddDomainRecord \
    --DomainName ${API_DomainName} \
    --Type TXT \
    --RR "${API_RR}" \
    --Value "${CERTBOT_VALIDATION}" \
    --output table \
)

write_log "API Result: ${API_RESULT}";

RecordId=$(echo $API_RESULT | grep -P "\|\s+(\d+)\s+\|" -o | grep -P "\d+" -o)

write_log "Record Id: ${RecordId}";

echo $RecordId >> $RECORD_ID_LIST_FILE

echo ""
