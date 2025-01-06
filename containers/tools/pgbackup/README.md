# pgbackup

I'm a simple container to backup/restore encrypted postgres data to an s3 bucket.

## Usage

### Environment Flags

#### Required

* S3_ENDPOINT - s3 endpoint
* S3_BUCKET - s3 bucket name
* S3_KEY - s3 bucket access key
* S3_SECRET - s3 bucket secret key

* PG_HOSTNAME - postgresql server hostname
* PG_USERNAME - postgresql username
* PG_PASSWORD - postgresql password

* TWOSECRET - encryption password for backup

#### Optional

* PG_PORT - assumed 5432
* S3_MAX_AGE - maximum backup age in bucket. ex: 30d,1y,etc
