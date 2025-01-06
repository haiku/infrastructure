#!/bin/bash
# This can go away once we move to swarm and can use secrts in env. vars
. /keys/secrets
/usr/local/concourse/bin/concourse $@
