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

After uploaded packages have been modified > 15 minutes ago, they are picked up by forklift
which moves them to the build-packages packages repository.

> The sysadmin team will need to unbootstrap packages given the complexities of the process.

# Usage

## Onboarding Users

Any users in Gerrit can be added to the loadingdock service.

  * User obtains their Gerrit ID from https://review.haiku-os.org/settings/#Profile and provides this ID to the sysadmin team
  * User confirms their Gerrit account has SSH keys configured

The sysadmins will add the GERRIT_UIDS to the "GERRIT_UIDS" environment variable and
restart the container.

> Eventually the goal is to make this access Gerrit group based

Users will then have access to submit@limerick.ams3.haiku-os.org:1099 to upload packages
