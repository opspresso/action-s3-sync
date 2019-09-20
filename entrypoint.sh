#!/bin/sh

set -e

_publish_pre() {
  if [ -z "${AWS_ACCESS_KEY_ID}" ]; then
    echo "AWS_ACCESS_KEY_ID is not set."
    exit 1
  fi

  if [ -z "${AWS_SECRET_ACCESS_KEY}" ]; then
    echo "AWS_SECRET_ACCESS_KEY is not set."
    exit 1
  fi

  if [ -z "${AWS_REGION}" ]; then
    AWS_REGION="us-east-1"
  fi

  if [ -z "${DEST_PATH}" ]; then
    echo "DEST_PATH is not set."
    exit 1
  fi

  if [ -z "${FROM_PATH}" ]; then
    FROM_PATH="."
  fi
}

_publish() {
  _publish_pre

  aws configure <<-EOF > /dev/null 2>&1
${AWS_ACCESS_KEY_ID}
${AWS_SECRET_ACCESS_KEY}
${AWS_REGION}
text
EOF

  aws s3 sync ${FROM_PATH} ${DEST_PATH} $*
}

_publish
