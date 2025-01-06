# General Worker

This container is the base for most of the Haiku build system.  It should be kept as lean
as possible adding only minimal generic tooling.

# Building

This container is multi-architecture and should have x86_64 and arm64 variants for build
system flexibility.

# Making Releases

* Make changes to the container, test them locally with ``make``
* Once complete. commit changes, and push them upstream
* Tag the commit prefixed by the container name ``general-worker-20241228``
* ``git push --tags``

A build will fire off, compile amd64 and arm64, and push them to ghcr.io
