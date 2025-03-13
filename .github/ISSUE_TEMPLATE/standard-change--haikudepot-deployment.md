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

1. Verify that the images are available in the package repositories;
   - [haikudepotserver](https://github.com/haiku/haikudepotserver/pkgs/container/haikudepotserver).
   - [haikudepotserver](https://github.com/haiku/haikudepotserver/pkgs/container/haikudepotserver-server-graphics).
2. Scale down `haikudepotserver` Deployment and start a job to back up the database:
    ```
    $ kubectl scale deploy haikudepotserver --replicas=0
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
5. Update the version in the infrastructure repository in `deployments/haikudepotserver.yml` for;
   - `Deployment` with name `haikudepotserver`
   - `Deployment` with name `haikudepotserver-server-graphics`
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
If the update is unsuccessful, the rollback can be executed as follows.

If there has been a (failed) database migration as part of the change, the backup created in step 2 must be restored. If the database has not been affected, then skip to the image rollback steps below.

1. Stop all instances of haikudepotserver
    ```
    $ kubectl scale deploy haikudepotserver --replicas=0
    ```
2. Prepare the restore job in  `deployments/other/restore-pg.yml` by making sure the container args point to the haikudepotserver container
    ```
            args: ["restore", "haikudepotserver"]
    ```
3. Restore the database by executing the following commands.
    ```
    $ kubectl exec -it deployment/postgres -- dropdb -U postgres haikudepotserver
    $ kubectl exec -it deployment/postgres -- createdb -U postgres -O haikudepotserver haikudepotserver
    $ kubectl apply -f deployments/other/restore-pg.yml
    # follow and validate the output of the following command. If the command completes, the restore is done.
    $ kubectl logs --follow jobs/restore
    # cleanup
    $ kubectl delete job/restore
    $ git checkout deployments/other/restore-pg.yml
    ```
4. Roll back the image with the following commands:
    ```
    $ git restore deployments/haikudepotserver.yml
    $ kubectl apply -f deployments/haikudepotserver.yml
    ```
5. Do sense checks in the logs and by some exploratory production testing to validate that the restore has been successful.
