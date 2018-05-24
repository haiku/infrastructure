Administering Gerrit
==================================
Gerrit is a mess that sometimes causes a lot of problems. Here's some things that we've had to manually do and how to do them:

## Manually add and set a user's email address
This command is [documented](https://gerrit-review.googlesource.com/Documentation/cmd-set-account.html) albeit at a rather obscure location.
```
ssh USERNAME@git.haiku-os.org gerrit set-account --add-email "nobody@example.com" --preferred-email "nobody@example.com" 1000001
```
This supplants the prior method of accessing the SQL database, which is now deprecated as Gerrit has moved to store user data in "NoteDb", which is really just a flat-file Git repository using Gerrit's branching schemes.

You probably need to flush the caches after running this, though Gerrit does not specifically note either way.

## Force flush of caches
Make sure you are in the administrators group and run:
```
ssh USERNAME@git.haiku-os.org gerrit flush-caches
```
