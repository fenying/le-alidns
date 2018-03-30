#!/bin/bash

if [ ! -f "${RECORD_ID_LIST_FILE}" ]
then
    echo "No record-id-list file found."
    exit
fi

RECORD_ID_LIST=$(cat $RECORD_ID_LIST_FILE)

if [ -z "$RECORD_ID_LIST" ]
then
    echo "No records to be clean."
    exit
fi

if [[ ! -z "$CFG_ALICLI_PROFILE" ]]
then
    ALICLI_PROFILE="--profile $CFG_ALICLI_PROFILE"
fi

for RecordId in $RECORD_ID_LIST
do
echo "Deleting DNS record of Id ${RecordId}" >> $CFG_LOG_FILE
API_RESULT=$(aliyuncli alidns DeleteDomainRecord \
    $ALICLI_PROFILE \
    --RecordId ${RecordId} \
    --output table \
)

echo "API Result: ${API_RESULT}" >> $CFG_LOG_FILE

done

rm -f $RECORD_ID_LIST_FILE
