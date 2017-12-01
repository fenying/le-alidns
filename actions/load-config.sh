#!/bin/bash

# Initialize the configuration
rm -f $LEALIDNS_CONFIG_BASH_RC

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

CFG_FIELDS="domains email log-file certbot-root rsa-key-size after-cert before-cert after-new-cert"
CFG_RSA_KEY_SIZE=2048
CFG_LOG_FILE=./le-alidns.log
CFG_CERTBOT_ROOT=/usr/local/certbot

for line in `cat ${CONFIG_FILE} | tr -d '[ \t]'`
do
    if [[ "${line:0:1}" == "#" ]] # ignore comment lines
    then
        continue;
    fi;

    # remove inline comments
    line=$(echo $line | sed s/#.*//g);

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
        CFG_DOMAINS="$FIELD_VALUE ${CFG_DOMAINS}"
    fi;

    if [ "$FIELD_NAME" == "domain" ]
    then
        CFG_DOMAINS="${FIELD_VALUE} ${CFG_DOMAINS}"
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

    if [ "$FIELD_NAME" == "after-new-cert" ]
    then
        CFG_ON_NEW_CERT="--deploy-hook $FIELD_VALUE"
    fi;

    if [ "$FIELD_NAME" == "before-cert" ]
    then
        CFG_ON_START=$FIELD_VALUE
    fi;

    if [ "$FIELD_NAME" == "after-cert" ]
    then
        CFG_ON_END=$FIELD_VALUE
    fi;
done

echo "" > $LEALIDNS_CONFIG_BASH_RC
echo "export CFG_LOG_FILE=${CFG_LOG_FILE}" >> $LEALIDNS_CONFIG_BASH_RC
echo "export CFG_CERTBOT_ROOT=${CFG_CERTBOT_ROOT}" >> $LEALIDNS_CONFIG_BASH_RC
echo "export CFG_EMAIL=${CFG_EMAIL}" >> $LEALIDNS_CONFIG_BASH_RC
echo "export CFG_DOMAINS='${CFG_DOMAINS}'" >> $LEALIDNS_CONFIG_BASH_RC
echo "export CFG_RSA_KEY_SIZE=${CFG_RSA_KEY_SIZE}" >> $LEALIDNS_CONFIG_BASH_RC
echo "export CFG_ON_NEW_CERT=${CFG_ON_NEW_CERT}" >> $LEALIDNS_CONFIG_BASH_RC
echo "export CFG_ON_START=${CFG_ON_START}" >> $LEALIDNS_CONFIG_BASH_RC
echo "export CFG_ON_END=${CFG_ON_END}" >> $LEALIDNS_CONFIG_BASH_RC

echo "- Using certbot at ${CFG_CERTBOT_ROOT}."
echo "- Using E-Mail ${CFG_EMAIL}."
echo "- Saving logs to file ${CFG_LOG_FILE}."
echo ""
