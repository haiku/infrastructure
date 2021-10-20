# loadingdock

This container accepts sftp connections on port 1099 for contributor submissions of build-packages
build-packages are software packages which are actively used during the build of Haiku.

## Requirements

Environment:
  * GERRIT_UIDS: List of Gerrit user ID's (number, seen on profile) who can access this service.

Volumes:
  * /sftp: A volume to store incoming packages
  * /gerrit: A read-only mount of gerrit for access of "All-Users.git"

## Process

On startup, this container examines the provided GERRIT_UIDS and pulls the public keys for the
users from Gerrit.

These public keys are allowed access to the service.  Users can submit haiku package files
for their desired architecture.

## TODO

Packages are picked up by forklift which will:
  * Pull the latest HaikuPorts repository file
  * Append the new packages if needed
  * Upgrade any packages it can
  * generate a new hardlink repository
  * Produce a new HaikuPorts repository file
  * Commit the new HaikuPorts reposirory file
