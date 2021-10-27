# GitHub Action to Sync S3 Bucket 🔄

This simple action uses the [vanilla AWS CLI](https://docs.aws.amazon.com/cli/index.html) to sync a directory (either from your repository or generated during your workflow) with a remote S3 bucket.

基于 [jakejarvis/s3-sync-action](https://github.com/jakejarvis/s3-sync-action) 修改，在其原有基础上做了如下调整：

- [X] 使用 `aws cli v2`
- [X] 增加一个用于编译 `aws cli v2` 的 docker 文件 `Dockerfile-awscli-v2`
- [X] 入口文件增加属性 `META_DIR`、 `META_EXTRA` 用于使用 `aws cli cp` 做额外的元数据调整，例如在部分文件夹下的文件上添加 `content-type`

## Usage

具体用法参见 [jakejarvis/s3-sync-action](https://github.com/jakejarvis/s3-sync-action)

Example:

```yaml
name: Upload public to s3

on:
    push:
        branches:
            - master

jobs:
    deploy:
        runs-on: ubuntu-latest
        steps:
            - uses: actions/checkout@master

            - name: build conf to public
              run: ./some-func.sh

            - uses: someok/s3-sync-action@master
              with:
                  args: --acl public-read --follow-symlinks --delete
              env:
                  AWS_S3_BUCKET: ${{ secrets.AWS_S3_BUCKET }}
                  AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
                  AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
                  AWS_REGION: 'ap-southeast-1' # optional: defaults to us-east-1
                  SOURCE_DIR: 'src_dir' # optional: defaults to entire repository
                  DEST_DIR: 'dist_dir'
                  # 修改下列目录里的文件的 content-type
                  META_DIR: 'dist_dir/xxx1 dist_dir/xxx2'
                  META_EXTRA: '--content-type text/plain;charset=utf-8'

            # Invalidate Cloudfront (this action)
            - name: invalidate cloudfront
              uses: chetan/invalidate-cloudfront-action@master
              env:
                  DISTRIBUTION: ${{ secrets.CLOUDFRONT_DISTRIBUTION }}
                  PATHS: '/some-path/*'
                  AWS_REGION: 'ap-southeast-1'
                  AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
                  AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```
