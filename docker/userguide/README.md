# Userguide application container

This is a custom container that contains php-apache with pdo and pdo_pgsql
modules installed.

On the actual instance, it is good to use a persistent volume mounted at
/var/userguide.

The volume should contain the following:
 - A checkout of https://github.com/haiku/userguide-translator as /var/userguide/app
 - A filled config.php at /var/userguide/app/userguide/inc/config.php

To update the userguide tool, execute:
    `docker exec -it <CONTAINER_ID> git pull /var/userguide/app`