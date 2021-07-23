#!/bin/sh

set -e

sh --version

if [ -z "$AWS_S3_BUCKET" ]; then
  echo "AWS_S3_BUCKET is not set. Quitting."
  exit 1
fi

if [ -z "$AWS_ACCESS_KEY_ID" ]; then
  echo "AWS_ACCESS_KEY_ID is not set. Quitting."
  exit 1
fi

if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  echo "AWS_SECRET_ACCESS_KEY is not set. Quitting."
  exit 1
fi

# Default to us-east-1 if AWS_REGION not set.
if [ -z "$AWS_REGION" ]; then
  AWS_REGION="us-east-1"
fi

# Override default AWS endpoint if user sets AWS_S3_ENDPOINT.
if [ -n "$AWS_S3_ENDPOINT" ]; then
  ENDPOINT_APPEND="--endpoint-url $AWS_S3_ENDPOINT"
fi

aws --version

# Create a dedicated profile for this action to avoid conflicts
# with past/future actions.
# https://github.com/jakejarvis/s3-sync-action/issues/1
aws configure --profile s3-sync-action <<-EOF >/dev/null 2>&1
${AWS_ACCESS_KEY_ID}
${AWS_SECRET_ACCESS_KEY}
${AWS_REGION}
text
EOF

# Sync using our dedicated profile and suppress verbose messages.
# All other flags are optional via the `args:` directive.
sh -c "aws s3 sync ${SOURCE_DIR:-.} s3://${AWS_S3_BUCKET}/${DEST_DIR} \
  --profile s3-sync-action \
  --no-progress \
  ${ENDPOINT_APPEND} \
  $*"

# 对于 META_DIR（可多个，空格分隔），则使用 cp 命令附加额外的参数 META_EXTRA
if [[ -n "$META_DIR" && -n "$META_EXTRA" ]]; then
  echo ""
  echo "META_DIR=${META_DIR}"

  # META_DIR_ARR=($META_DIR)
  # IFS=', ' read -r -a META_DIR_ARR <<<"$META_DIR"
  META_DIR_ARR=($(echo ${META_DIR} | tr ' ' ' '))

  echo "META_DIR_ARR=[${META_DIR_ARR[@]}]"

  for dir in "${META_DIR_ARR[@]}"; do
    echo "edit metadata: s3://${AWS_S3_BUCKET}/${dir}"
    echo "aws s3 cp s3://${AWS_S3_BUCKET}/${dir} s3://${AWS_S3_BUCKET}/${dir} \
      --profile s3-sync-action \
      --no-progress \
      --recursive ${META_EXTRA} \
      --metadata-directive REPLACE \
      $*"
    sh -c "aws s3 cp s3://${AWS_S3_BUCKET}/${dir} s3://${AWS_S3_BUCKET}/${dir} \
      --profile s3-sync-action \
      --no-progress \
      --recursive ${META_EXTRA} \
      --metadata-directive REPLACE \
      $*"
  done
fi

# Clear out credentials after we're done.
# We need to re-run `aws configure` with bogus input instead of
# deleting ~/.aws in case there are other credentials living there.
# https://forums.aws.amazon.com/thread.jspa?threadID=148833
aws configure --profile s3-sync-action <<-EOF >/dev/null 2>&1
null
null
null
text
EOF
