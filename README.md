# action-s3-sync

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
        AWS_S3_BUCKET: ${{ secrets.AWS_S3_BUCKET }}
        AWS_REGION: "us-east-1"
        DEST_PATH: "/"
        FROM_PATH: "./target/publish"
```

## env

Key | Value | Default | Required
--- | ----- | ------- | --------
AWS_ACCESS_KEY_ID | Your AWS Access Key. | | Yes
AWS_SECRET_ACCESS_KEY | Your AWS Access Key. | | Yes
AWS_S3_BUCKET | Your AWS S3 Bucket. | | Yes
AWS_REGION | Your AWS Region. | us-east-1 | No
DEST_PATH | The remote path you wish to sync to local path. | / | No
FROM_PATH | The local path you wish to sync to remote path. | . | No

## exec

```bash
aws configure <<-EOF > /dev/null 2>&1
${AWS_ACCESS_KEY_ID}
${AWS_SECRET_ACCESS_KEY}
${AWS_REGION}
text
EOF

aws s3 sync ${FROM_PATH} s3://${AWS_S3_BUCKET}${DEST_PATH} --no-progress $*"
```
