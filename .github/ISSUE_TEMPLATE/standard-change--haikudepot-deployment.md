---
name: 'Standard Change: HaikuDepot Deployment'
about: Request a deployment for HaikuDepot
title: "[Change Request] Deploy HaikuDepot version 1.0.X"
labels: change-request
assignees: ''

---

### Description
Update HaikuDepot to version (VERSION)

### How has the change been tested
 * Dev-tested by the HaikuDepot dev.
 * Automated tests run by the Github action: _Please link to the build of the image_

### Steps to implement the change
_Note: Please mark changes from the default steps below in *bold*_

1. Verify that the image is available in the [package registry](https://github.com/haiku/haikudepotserver/pkgs/container/haikudepotserver).
2. Start a job to backup the database:
    ```
    $ kubectl create job --from=cronjob/haikudepotserver-pgbackup haikudepotserver-pgbackup-manual-(VERSION)
    ```
3. Monitor the job to make sure it finishes correctly:
    ```
    $ kubectl logs -f jobs/haikudepotserver-pgbackup-manual-(VERSION)
    Backup haikudepotserver...
    gpg: directory '/root/.gnupg' created
    gpg: keybox '/root/.gnupg/pubring.kbx' created
    Added `s3remote` successfully.
    `/tmp/haikudepotserver_2023-08-06.sql.xz.gpg` -> `s3remote/haiku-backups/pg-haikudepotserver/haikudepotserver_2023-08-06.sql.xz.gpg`
    Total: 0 B, Transferred: 245.32 MiB, Speed: 86.05 MiB/s
    Snapshot of haikudepotserver completed successfully! (haiku-backups/pg-haikudepotserver/haikudepotserver_2023-08-06.sql.xz.gpg)
    ```
4. Apply any pre-deployment configuration changes (see section Configuration Changes)
5. Update the version in the infrastructure repository in `deployments/haikudepotserver.yml`.
6. Apply the update to the server:
    ```
    $ kubectl apply -f deployments/haikudepotserver.yml
    ```
7. Apply any post-deployment configuration changes (see section Configuration Changes)
8. Post-deployment checks (is the web service responding, can you refresh the data using the HaikuDepot app)
9. Commit and push the updated deployment configuration to GitHub.
10. Announce the update on the `haiku-sysadmin` and `haiku` mailing list.

### Configuration Changes
_Please list any configuration changes, and note whether they need to be done pre-deploy or post-deploy_

None

### Rollback Plan
If the update is unsuccesful, try rolling back the image with the following commands:
```
$ git restore deployments/haikudepotserver.yml
$ kubectl apply -f deployments/haikudepotserver.yml
```

If the update applied database transformations, or the database go corrupted in any other way, please also restore the database to the backup crated as part of these update steps.
