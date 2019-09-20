# AWS S3 Sync for GitHub Action

## Usage

```yaml
name: AWS S3 Sync

on: push

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
    - uses: opspresso/action-s3-sync@master
      with:
        args: --acl public-read
      env:
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        AWS_REGION: "us-east-1"
        FROM_PATH: "./target/publish"
        DEST_PATH: "s3://your_bucket_name/path/"
```

## env

Name | Description | Default | Required
---- | ----------- | ------- | --------
AWS_ACCESS_KEY_ID | Your AWS Access Key. | | Yes
AWS_SECRET_ACCESS_KEY | Your AWS Access Key. | | Yes
AWS_REGION | Your AWS Region. | us-east-1 | No
FROM_PATH | The local path you wish to sync to remote path. | . | No
DEST_PATH | The remote path you wish to sync from local path. | | Yes

## exec

```bash
aws configure <<-EOF > /dev/null 2>&1
${AWS_ACCESS_KEY_ID}
${AWS_SECRET_ACCESS_KEY}
${AWS_REGION}
text
EOF

aws s3 sync ${FROM_PATH} ${DEST_PATH} --no-progress $*"
```
