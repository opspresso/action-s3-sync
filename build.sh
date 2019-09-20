#!/bin/bash

OS_NAME="$(uname | awk '{print tolower($0)}')"

SHELL_DIR=$(dirname $0)

_replace() {
    if [ "${OS_NAME}" == "darwin" ]; then
        sed -i "" -e "$1" $2
    else
        sed -i -e "$1" $2
    fi
}

VERSION=$(cat ${SHELL_DIR}/VERSION | xargs)

_replace "s/LABEL version=.*/LABEL version=${VERSION}/g" ${SHELL_DIR}/Dockerfile
