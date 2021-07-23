#!/bin/sh

# 遇到不存在的变量就会报错，并停止执行
# set -u
# 用来在运行结果之前，先输出执行的那一行命令
# set -x
# 脚本只要发生错误，就终止执行
set -e
# 只要一个子命令失败，整个管道命令就失败，脚本就会终止执行。
set -o pipefail

AWS_S3_BUCKET=demo

META_DIR="proxy-conf/surge/* proxy-conf/clash"
META_EXTRA="--content-type 'text/plain; charset=utf-8'"

if [[ -z "$META_DIR" && -z "$META_EXTRA" ]]; then
    echo 'none'
fi

if [[ -n "$META_DIR" && -n "$META_EXTRA" ]]; then

    echo "META_DIR=${META_DIR}"
    # META_DIR_ARR=(${META_DIR})
    IFS=', ' read -r -a META_DIR_ARR <<<"$META_DIR"

    echo "META_DIR_ARR=[${META_DIR_ARR[@]}]"

    for dir in "${META_DIR_ARR[@]}"; do
        echo "aws s3 cp s3://${AWS_S3_BUCKET}/${dir} s3://${AWS_S3_BUCKET}/${dir} \
              --profile s3-sync-action \
              --no-progress \
              --recursive ${META_EXTRA}
              ${ENDPOINT_APPEND} $*"

    done
fi
