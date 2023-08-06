---
name: 'Standard Change: Discourse Update'
about: Request an update for Discourse
title: "[Change Request] Deploy Discourse version X.X"
labels: change-request
assignees: ''

---

### Description
Update Discourse to version X.X

### How has the change been tested
Dev-tested by the container developer.

### Steps to implement the change
_Note: Please mark changes from the default steps below in *bold*_

1. Verify that the image is available in the [package registry](https://github.com/haiku/haikudepotserver/pkgs/container/discourse).
2. Make the installation read-only using the *Enable read-only* button on the [Admin/Backups](https://discuss.haiku-os.org/admin/backups) page.
3. Start a backup by using the *Backup* button on that page.
4. Update the version in the infrastructure repository in `deployments/discourse.yml`.
5. Apply the update to the server:
    ```
    $ kubectl apply -f deployments/discourse.yml
    ```
6. Post-deployment checks (is the web service responding, is the site read-write again)
7. Commit and push the updated deployment configuration to GitHub.
8. Announce the update on the `haiku-sysadmin` and `haiku` mailing list.

### Configuration Changes
_Please list any configuration changes, and note whether they need to be done pre-deploy or post-deploy_

None

### Rollback Plan
If the update is unsuccesful, try rolling back the image with the following commands:
```
$ git restore deployments/haikudepotserver.yml
$ kubectl apply -f deployments/haikudepotserver.yml
```

If the update applied database transformations, or the database go corrupted in any other way, use Discourse's built in database restore features to return the data to the previously saved version.
