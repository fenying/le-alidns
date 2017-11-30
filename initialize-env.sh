type python >/dev/null 2>&1 || {
    echo >&2 "Please install Python 2.7 manually, aborting...";
    exit 1;
}

type wget >/dev/null 2>&1 || {
    echo >&2 "Please install wget manually, aborting...";
    exit 1;
}

type pip >/dev/null 2>&1 || {

    type wget >/dev/null 2>&1 || {
        echo >&2 "Please install wget manually, aborting...";
        exit 1;
    }

    echo "Automatically installing pip.";

    wget "https://bootstrap.pypa.io/get-pip.py" -O "pip-install.py";

    sudo python pip-install.py;

    echo "Installed pip.";
}

type aliyuncli >/dev/null 2>&1 || {

    echo "Automatically installing aliyun console toolkits.";

    sudo pip install aliyuncli;
}

ALI_CLI_PACKAGES=$(aliyuncli)

CHECK_ALI_DNS_PY_PACKAGE=$(echo $ALI_CLI_PACKAGES | grep "alidns")

if [[ "$CHECK_ALI_DNS_PY_PACKAGE" == "" ]]
then
    sudo pip install aliyun-python-sdk-alidns
fi
