#!/bin/bash

OS_NAME="$(uname | awk '{print tolower($0)}')"

################################################################################

# command -v tput > /dev/null && TPUT=true
TPUT=

_echo() {
    if [ "${TPUT}" != "" ] && [ "$2" != "" ]; then
        echo -e "$(tput setaf $2)$1$(tput sgr0)"
    else
        echo -e "$1"
    fi
}

_result() {
    echo
    _echo "# $@" 4
}

_command() {
    echo
    _echo "$ $@" 3
}

_success() {
    echo
    _echo "+ $@" 2
    exit 0
}

_error() {
    echo
    _echo "- $@" 1
    exit 1
}

_replace() {
    if [ "${OS_NAME}" == "darwin" ]; then
        sed -i "" -e "$1" $2
    else
        sed -i -e "$1" $2
    fi
}

################################################################################

if [ ! -f ./VERSION ]; then
  printf "v0.0.x" > ./VERSION
fi

BASENAME=$(basename $PWD)

VERSION=$(cat ./VERSION | xargs)

echo "VERSION=${VERSION}"

VERSION=$(echo ${VERSION} | awk -F. '{$NF = $NF + 1;} 1' | sed 's/ /./g')

echo "VERSION=${VERSION}"

# ./VERSION :: v1.2.3
echo ${VERSION} > ./VERSION

# ./action.yml :: docker://opspresso/action-builder:v0.2.9
_replace "s/${BASENAME}:.*/${BASENAME}:${VERSION}/g" ./action.yml

# ./Dockerfile :: LABEL version=v1.2.3
_replace "s/LABEL version=.*/LABEL version=${VERSION}/g" ./Dockerfile
