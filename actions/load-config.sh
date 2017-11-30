#!/bin/bash

# Initialize the configuration

if [ -z "$LEALIDNS_CONFIG" ]
then
export CONFIG_FILE=/etc/le-alidns.conf
else
export CONFIG_FILE=$LEALIDNS_CONFIG
fi

echo "- Using configuration file '${CONFIG_FILE}'."

if [ ! -f $CONFIG_FILE ]
then
echo "Configuration file ${CONFIG_FILE} not found."
exit -1
fi

CFG_FIELDS="domains email log-file certbot-root rsa-key-size"
CFG_RSA_KEY_SIZE=2048

for line in `cat ${CONFIG_FILE}`
do
    FIELD_NAME=$(echo $line | grep -P "^[-\w]+\=" -o | cut -d "=" -f 1)

    FIELD_VALUE=$(echo $line | cut -d "=" -f 2)

    if [[ $CFG_FIELDS =~ "$FIELD_NAME" ]]
    then
        if [ "$FIELD_VALUE" == "" ]
        then
            echo "Configuration field ${FIELD_NAME} can not be empty."
            exit -1;
        fi
    else
        echo "Unknown field ${FIELD_NAME}."
    fi;

    if [ "$FIELD_NAME" == "domains" ]
    then
        CFG_DOMAINS=$FIELD_VALUE
    fi;

    if [ "$FIELD_NAME" == "email" ]
    then
        CFG_EMAIL=$FIELD_VALUE
    fi;

    if [ "$FIELD_NAME" == "certbot-root" ]
    then
        CFG_CERTBOT_ROOT=$FIELD_VALUE
    fi;

    if [ "$FIELD_NAME" == "log-file" ]
    then
        CFG_LOG_FILE=$FIELD_VALUE
    fi;

    if [ "$FIELD_NAME" == "rsa-key-size" ]
    then
        CFG_RSA_KEY_SIZE=$FIELD_VALUE
    fi;
done

echo "" > $LEALIDNS_CONFIG_BASH_RC
echo "export CFG_LOG_FILE=${CFG_LOG_FILE}" >> $LEALIDNS_CONFIG_BASH_RC
echo "export CFG_CERTBOT_ROOT=${CFG_CERTBOT_ROOT}" >> $LEALIDNS_CONFIG_BASH_RC
echo "export CFG_EMAIL=${CFG_EMAIL}" >> $LEALIDNS_CONFIG_BASH_RC
echo "export CFG_DOMAINS=${CFG_DOMAINS}" >> $LEALIDNS_CONFIG_BASH_RC
echo "export CFG_RSA_KEY_SIZE=${CFG_RSA_KEY_SIZE}" >> $LEALIDNS_CONFIG_BASH_RC

echo "- Using certbot at ${CFG_CERTBOT_ROOT}."
echo "- Using E-Mail ${CFG_EMAIL}."
echo "- Saving logs to file ${CFG_LOG_FILE}."
echo ""
