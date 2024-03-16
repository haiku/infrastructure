---
name: 'Standard Request: HaikuDepot Database Dump'
about: Request a database dump for HaikuDepot
title: "[Request] HaikuDepot Database Dump"
labels: request
assignees: ''

---

### Description
Request for a database dump for debugging and testing purposes.

### Steps to execute the request
1. Check whether there is an existing clone and drop it if necessary.
    ```bash
    # Open a connection to the database.
    $ kubectl exec -it deployment/postgres -- psql -U postgres -c 'DROP DATABASE IF EXISTS haikudepotserver_masked'
    # Example output:
    # NOTICE:  database "haikudepotserver_masked" does not exist, skipping
    # DROP DATABASE
    ```
2. Create the an empty database
    ```bash
    $ kubectl exec -it deployment/postgres -- createdb -U postgres haikudepotserver_masked
    ```
3. Clone the data into the new database
    ```bash
    kubectl exec -it deployment/postgres -- bash -c "pg_dump -U postgres haikudepotserver | psql -U postgres -d haikudepotserver_masked"
    ```
4. Apply the latest version of the masking script to the database
    ```bash
    kubectl exec -it deployment/postgres -- psql -U postgres -d haikudepotserver_masked < datamasking.sql
    ```
5. Dump, compress and encrypt the masked database. _Note: if this is the first time for this requester, make sure to import their public gpg key._
    ```bash
    kubectl exec -it deployment/postgres -- pg_dump -U postgres haikudepotserver_masked | xz -z | gpg -r <email@recipient.com> --encrypt -o haikudepotserver.sql.xz.gpg
    ```
6. Upload the database to a location, and inform the recipient.
