Administering Gerrit
==================================
Gerrit is a mess that sometimes causes a lot of problems. Here's some things that we've had to manually do and how to do them:

## List users (in noteDB)

As of Gerrit 2.15, users are "in" "noteDB"

> WARNING: We don't fully understand how this stuff works (and documentation is sparse). Don't *push* changes.

* Reference: https://blog.nanpuyue.com/2018/044.html

00 is the last two digits of the account_id.  1000000 is the account_id

```
git clone USERNAME@review.haiku-os.org:/All-Users.git && cd All-Users
git fetch origin refs/users/00/1000000:refs/users/00/1000000
git checkout refs/users/00/1000000
```

Look through the user configuration files in current directory.

The account_id (and most of what you'd find in the notedb, anyway) is accessible
and modifiable using the REST API: https://review.haiku-os.org/accounts/nobody@example.com/detail

## List external account linkages (in noteDB)

```
git fetch origin refs/meta/external-ids:refs/meta/external-ids
git checkout refs/meta/external-ids
```

These are more conveniently accessible theough the REST API:

https://review.haiku-os.org/accounts/noboody@example.com/external.ids

## Manually add and set a user's email address (noteDB or H2)

This command is [documented](https://gerrit-review.googlesource.com/Documentation/cmd-set-account.html) albeit at a rather obscure location.
```
ssh USERNAME@review.haiku-os.org gerrit set-account --add-email "nobody@example.com" --preferred-email "nobody@example.com" 1000001
```
This supplants the prior method of accessing the SQL database, which is now deprecated as Gerrit has moved to store user data in "NoteDb", which is really just a flat-file Git repository using Gerrit's branching schemes.

You can refer to the user by its user ID or by an existing email or its login.

## Force flush of caches
Make sure you are in the administrators group and run:
```
ssh USERNAME@review.haiku-os.org gerrit flush-caches
```

