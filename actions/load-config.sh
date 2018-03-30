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

export CFG_FIELDS="domains email log-file certbot-root certbot-cmd rsa-key-size"
export CFG_FIELDS="${CFG_FIELDS} after-cert before-cert after-new-cert"
export CFG_FIELDS="${CFG_FIELDS} no-auto-upgrade acme-version alicli-profile"
export CFG_RSA_KEY_SIZE=2048
export CFG_LOG_FILE=./le-alidns.log
export CFG_CERTBOT_ROOT=/usr/local/certbot
export CFG_CERTBOT_CMD=certbot-auto
export CFG_NO_AUTO_UPGRADE=on
export CFG_ACME_VERSION=v1

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
        export CFG_DOMAINS="$FIELD_VALUE ${CFG_DOMAINS}"
    fi;

    if [ "$FIELD_NAME" == "alicli-profile" ]
    then
        export CFG_ALICLI_PROFILE=$FIELD_VALUE
    fi;

    if [ "$FIELD_NAME" == "domain" ]
    then
        export CFG_DOMAINS="${FIELD_VALUE} ${CFG_DOMAINS}"
    fi;

    if [ "$FIELD_NAME" == "email" ]
    then
        export CFG_EMAIL=$FIELD_VALUE
    fi;

    if [ "$FIELD_NAME" == "acme-version" ]
    then
        export CFG_ACME_VERSION=$FIELD_VALUE
    fi;

    if [ "$FIELD_NAME" == "certbot-root" ]
    then
        export CFG_CERTBOT_ROOT=$FIELD_VALUE
    fi;

    if [ "$FIELD_NAME" == "certbot-cmd" ]
    then
        export CFG_CERTBOT_CMD=$FIELD_VALUE
    fi;

    if [ "$FIELD_NAME" == "log-file" ]
    then
        export CFG_LOG_FILE=$FIELD_VALUE
    fi;

    if [ "$FIELD_NAME" == "rsa-key-size" ]
    then
        export CFG_RSA_KEY_SIZE=$FIELD_VALUE
    fi;

    if [ "$FIELD_NAME" == "after-new-cert" ]
    then
        export CFG_ON_NEW_CERT="--deploy-hook $FIELD_VALUE"
    fi;

    if [ "$FIELD_NAME" == "before-cert" ]
    then
        export CFG_ON_START=$FIELD_VALUE
    fi;

    if [ "$FIELD_NAME" == "after-cert" ]
    then
        export CFG_ON_END=$FIELD_VALUE
    fi;

    if [ "$FIELD_NAME" == "no-auto-upgrade" ]
    then
        export CFG_NO_AUTO_UPGRADE=$FIELD_VALUE
    fi;
done
