# persistsync

I'm a simple container to backup/restore encrypted persistant volume data to an s3 bucket.

## Usage

### Docker
**Backup**
```
docker run -it -V volume:/pvs/volume docker.io/haiku/persistsync pvsync backup volume s3user s3password encryptionpassword
```

**Restore**
```
docker run -it -V volume:/pvs/volume docker.io/haiku/persistsync pvsync restore volume s3user s3password encryptionpassword
```
