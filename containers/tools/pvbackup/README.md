# pvbackup

I'm a simple container to backup/restore encrypted persistant volume data to an s3 bucket.

## Usage

### Volumes

#### Required

* /root/.config/rclone/rclone.conf containing the rclone configuration
* /root/.config/twosecret containing the encryption key for the backups

### Environment Flags

#### Required

* REMOTE_PREFIX - prefix path on remote. Likely bucket name for S3

#### Optional

* REMOTE_NAME - name of remote specified in configuration file (defaults to "backup")
* REMOTE_MAX_AGE - maximum backup age in bucket. example: 30d,1y,etc

