# mirror for Haiku

This container automatically mirrors haikuports sources

By default, source packages are archived to a local directory under
`/ports-mirror/srv-www/<recipeName>/<filename>`.

Alternatively, packages can be archived to an S3 bucket in the same
`<recipeName>/<filename>` layout by setting the following environment
variables:

* `S3_BUCKET` - enable S3 mirroring and set the bucket to use
* `S3_ENDPOINT` - S3 endpoint URL (e.g. `https://s3.us-east-1.wasabisys.com`)
* `S3_ACCESS_KEY` - S3 access key
* `S3_SECRET_KEY` - S3 secret key

When `S3_BUCKET` is set, the script records the recipe's sha256 checksum on
each archived object and verifies it via the S3 API (`head_object`). Objects
whose recorded checksum does not match the recipe -- or that were archived
before the checksum was recorded -- are re-downloaded and re-archived.
