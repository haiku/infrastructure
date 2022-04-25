# rclone-mirror

Mirrors a remote object storage directory locally

> The target path should be mounted at /data

## Required environment vars

* BACKEND (tardigate or s3)
* BUCKET (bucket / share name)

### S3 BACKEND

> Using a read-only s3 key is recommended

* S3_ACCESS_KEY
* S3_SECRET_KEY
* S3_ENDPOINT

### Storj / Tardigate backend

* STORJ_ACCESS_GRANT
* STORJ_PASS
* STORJ_SATELLITE
