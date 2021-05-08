---
name: 'Standard Change: HaikuDepot Deployment'
about: Request a deployment for HaikuDepot
title: "[Change Request] Deploy HaikuDepot version X.X"
labels: change-request
assignees: ''

---

### Description
Update HaikuDepot to version X.X

### How has the change been tested
Dev-tested by the HaikuDepot dev.

### Steps to implement the change
_Note: Please mark changes from the default steps below in *bold*_

1. Build a new HaikuDepot image from source
2. Push the new image to Docker Hub
3. Update the version in the infrastructure repository in `cdn.yaml`
4. Update infrastructure repository on server
5. Apply any configuration changes (see section Configuration Changes)
6. Update the image using `docker service update --image haiku/haikudepotserver:VERSION--force cdn_haikudepotserver`
7. Post-deployment checks (is the web service responding, can you refresh the data using the HaikuDepot app)

### Configuration Changes
_Please list any configuration changes, and note whether they need to be done pre-deploy or post-deploy_

None

### Rollback Plan
If the update is unsuccesful, try to rollback the image using the following command:
`docker service update --image haiku/haikudepotserver:PREV_VERSION--force cdn_haikudepotserver`
