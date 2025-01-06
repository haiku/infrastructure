# rclone mount

Mounts any remote filesystem as a local persistent volume.

This container is generally a horrible idea, but may be just crazy
enough to work for some weird usecases.  Writes are slow
(at least with storj), but reads are fast.

Storj and S3 are supported today.  More rclone backends could be
added pretty simply by adjusting entry.sh adding the required
environment vars.

## Design

On every kubernetes node via a daemonset:

```
/home/thing
      ^ fuse
  +--------+
  |rclonefs|
  | storj  |
  +--------+
      v
    storj
```

Containers then can consume /home/thing as a hostPath mount into
the container.

```
  +--------------+
  |thing consumer|
  +--------------+
      v hostPath
/home/thing
      ^ fuse via hostPath
  +--------+
  |rclonefs|
  | storj  |
  +--------+
      v
    storj
```
