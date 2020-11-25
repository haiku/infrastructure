# persistsync

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
