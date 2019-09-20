#!/bin/bash

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

  if [ -z "${FROM_PATH}" ]; then
    FROM_PATH="."
  fi

  if [ -z "${DEST_PATH}" ]; then
    echo "DEST_PATH is not set."
    exit 1
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

  # aws s3 sync
  echo "aws s3 sync ${FROM_PATH} ${DEST_PATH}"
  aws s3 sync ${FROM_PATH} ${DEST_PATH} ${OPTIONS}

  # s3://bucket/path
  if [ "${DEST_PATH:0:5}" == "s3://" ]; then
    BUCKET="$(echo "${DEST_PATH}" | cut -d'/' -f3)"

    # aws cf reset
    CFID=$(aws cloudfront list-distributions --query "DistributionList.Items[].{Id:Id,Origin:Origins.Items[0].DomainName}[?contains(Origin,'${BUCKET}')] | [0]" | grep 'Id' | cut -d'"' -f4)
    if [ "${CFID}" != "" ]; then
        aws cloudfront create-invalidation --distribution-id ${CFID} --paths "/*"
    fi
  fi
}

_publish
