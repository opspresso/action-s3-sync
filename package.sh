#!/bin/sh

set -e

OS_NAME="$(uname | awk '{print tolower($0)}')"

_replace() {
    if [ "${OS_NAME}" == "darwin" ]; then
        sed -i "" -e "$1" $2
    else
        sed -i -e "$1" $2
    fi
}

if [ -f ./VERSION ]; then
    VERSION=$(cat ./VERSION | xargs)

    mkdir -p target
    printf "${VERSION}" > ./target/VERSION

    if [ -f ./Dockerfile ]; then
        _replace "s/LABEL version=.*/LABEL version=${VERSION}/g" ./Dockerfile
    fi
fi
