# pvbackup

I'm a simple container to backup/restore encrypted persistant volume data to an s3 bucket.

## Usage

### Docker
**Backup**
```
docker run -it -e S3_BUCKET="" -e S3_KEY="" -e S3_SECRET="" -e TWOSECRET="" -V volume:/pvs/volume docker.io/haiku/persistsync backup volume
```

**Restore**
```
docker run -it -e S3_BUCKET="" -e S3_KEY="" -e S3_SECRET="" -e TWOSECRET="" -V volume:/pvs/volume docker.io/haiku/persistsync restore volume
```

### Environment Flags

#### Required

* S3_ENDPOINT - s3 endpoint
* S3_BUCKET - s3 bucket name
* S3_KEY - s3 bucket access key
* S3_SECRET - s3 bucket secret key
* TWOSECRET - encryption password for backup

#### Optional

* S3_MAX_AGE - maximum backup age in bucket. ex: 30d,1y,etc
