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

for RecordId in $RECORD_ID_LIST
do
echo "Deleting DNS record of Id ${RecordId}" >> $CFG_LOG_FILE
API_RESULT=$(aliyuncli alidns DeleteDomainRecord \
    --RecordId ${RecordId}
)

echo "API Result: ${API_RESULT}" >> $CFG_LOG_FILE

done

rm -f $RECORD_ID_LIST_FILE
