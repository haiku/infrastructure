# repo-mirror

Exposes haiku package repositories via read-only rsync for mirrors.

## Environment variables

  * VOLUMES - List of attached persistant volumes containing shares to expose

## Files

### Within volumes

  * .subpath - Only expose shares within a subpath

### Within shares

  * .sharename - Instead of naming the share as the directory, name it as the contents of this file

### Permissions

  * ./data/

## Access

> This is nice for tracking who has access publically, but local files don't scale well.

  * All share access is restricted until remote hosts are granted access via a list
    * ../../data/repo-mirror/<sharename>/rsync-whitelist
