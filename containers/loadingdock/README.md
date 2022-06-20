# loadingdock

This container accepts sftp connections on port 1099 for contributor submissions of build-packages
build-packages are software packages which are actively used during the build of Haiku.

## Requirements

Environment:
  * GERRIT_SA: Service account in Gerrit to access API (username:password)
  * ACCESS_GROUP_ID: Group to allow access to via ssh public keys.

Volumes:
  * /sftp: A volume to store incoming packages

## Process

On startup, this container scans the members of ACCESS_GROUP_ID for ssh public
keys and sets up an sftp server.

After uploaded packages have been modified > 15 minutes ago, they are picked up by forklift
which moves them to the build-packages packages repository.

> The sysadmin team will need to unbootstrap packages given the complexities of the process.

# Usage

## Onboarding Users

* Add any users who need access to the group matching ACCESS_GROUP_ID. (Generally "Loading Dock")
* Restart this container.

# TODO

* We might want to periodically rescan the memberships of ACCESS_GROUP_ID and reform the user list.
  for now the container needs restarted to pickup changes
* Static SSH host keys
