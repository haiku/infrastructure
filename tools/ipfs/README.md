# IPFS Tools

These tools allow you to automatically update and publish our assets from
local sources to IPFS.

Today, data flows like this:

![diagram](diagram.png)


* We rsync haikuports packages from our infrastructure to IPFS
* We fuse mount S3 buckets to access our haiku repos for IPFS
