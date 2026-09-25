# mirror for Haiku

This container automatically mirrors haikuports sources

Source packages are archived to an S3 bucket in a `<recipeName>/<filename>`
layout. The following environment variables are required:

* `S3_BUCKET` - the bucket to use
* `S3_ENDPOINT` - S3 endpoint URL (e.g. `https://s3.us-east-1.wasabisys.com`)
* `S3_REGION` - the S3 region (e.g. `fin-hel-1`)
* `S3_ACCESS_KEY` - S3 access key
* `S3_SECRET_KEY` - S3 secret key

Optional:

* `PARALLEL_DOWNLOADS` - number of recipes to fetch and archive concurrently
  (default `4`)

The script records the recipe's sha256 checksum on each archived object and
verifies it via the S3 API (`head_object`). Objects whose recorded checksum
does not match the recipe -- or that were archived before the checksum was
recorded -- are re-downloaded and re-archived.
