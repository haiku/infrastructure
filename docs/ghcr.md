# GitHub Container Registry

GitHub Container Registry allows for free container hosting of our images. These containers
show up under [packages](https://github.com/orgs/haiku/packages)

## Accessing

### Generating personal access tokens

1. Login as your user, navigate to your [profile](https://github.com/settings/profile)
2. Left side, bottom. "Developer Settings"
3. Left side, bottom. "Personal Access Tokens"
4. Tokens (Classic)
5. Generate new token (classic)
6. Name it
7. Set permissions (Repo, write:packages, read:packages)
8. Expiry. 1 year?
9. Copy token, store in a safe place.

### Using personal access tokens

1. docker login ghcr.io
2. Enter your github username
3. Paste your personal access token

## Building

Images should be built with the ghcr.io registry name and our organization.  Naming should
be clear and consistent.

As container registries can change, any tooling like Makefiles or build scripts should allow
customization of the registry and org. This helps future-proof our infrastructure.

**Example Makefile:**
```
VERSION ?= 1.0.0
REGISTRY ?= ghcr.io/haiku
.
.
docker push ${REGISTRY}/thing:${VERSION}
```
