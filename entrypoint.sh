#!/bin/bash

REPOSITORY=${GITHUB_REPOSITORY}

USERNAME=${USERNAME:-$GITHUB_ACTOR}
REPONAME=$(echo "${REPOSITORY}" | cut -d'/' -f2)

_error() {
  echo -e "$1"

  if [ "${LOOSE_ERROR}" == "true" ]; then
    exit 0
  else
    exit 1
  fi
}

_error_check() {
  RESULT=$?

  if [ ${RESULT} != 0 ]; then
    _error ${RESULT}
  fi
}

_aws_pre() {
  if [ -z "${AWS_ACCESS_KEY_ID}" ]; then
    _error "AWS_ACCESS_KEY_ID is not set."
  fi

  if [ -z "${AWS_SECRET_ACCESS_KEY}" ]; then
    _error "AWS_SECRET_ACCESS_KEY is not set."
  fi

  if [ -z "${AWS_REGION}" ]; then
    AWS_REGION="us-east-1"
  fi
}

_publish_pre() {
  _aws_pre

  if [ -z "${FROM_PATH}" ]; then
    FROM_PATH="."
  fi

  if [ -z "${DEST_PATH}" ]; then
    # _error "DEST_PATH is not set."
    DEST_PATH="s3://${REPONAME}"
  fi

  if [ -z "${CF_RESET}" ]; then
    CF_RESET="true"
  fi
}

_publish() {
  _publish_pre

  # aws credentials
  aws configure <<-EOF > /dev/null 2>&1
${AWS_ACCESS_KEY_ID}
${AWS_SECRET_ACCESS_KEY}
${AWS_REGION}
text
EOF

  # aws s3 sync
  echo "aws s3 sync ${FROM_PATH} ${DEST_PATH}"
  aws s3 sync ${FROM_PATH} ${DEST_PATH} ${OPTIONS}

  _error_check

  if [ "${CF_RESET}" == "true" ]; then
    # s3://bucket/path
    if [[ "${DEST_PATH:0:5}" == "s3://" ]]; then
      BUCKET="$(echo "${DEST_PATH}" | cut -d'/' -f3)"

      # aws cf reset
      CFID=$(aws cloudfront list-distributions --query "DistributionList.Items[].{Id:Id,Origin:Origins.Items[0].DomainName}[?contains(Origin,'${BUCKET}')] | [0]" | awk '{print $1}')
      if [ "${CFID}" != "" ]; then
          echo "aws cloudfront create-invalidation ${CFID}"
          aws cloudfront create-invalidation --distribution-id ${CFID} --paths "/*"
      fi
    fi
  fi
}

_publish
