Administering Gerrit
==================================
Gerrit is a mess that sometimes causes a lot of problems. Here's some things that we've had to manually do and how to do them:

## Manually set a user's *preferred* email address
This requires directly modifying the SQL database. Use:
```
ssh USERNAME@git.haiku-os.org gerrit gsql
```
to sign in to the interactive SQL console (note that you can only do this if you are an "Administrator" in Gerrit.) **Note** that:
 1. The SQL console is not very robust. (`Ctrl+C` will end your SSH session, up-arrow corrupts the console instead of copying previous command, etc.)
 2. It's also not very well documented (see [here](https://gerrit-review.googlesource.com/Documentation/cmd-gsql.html) for the only-known docs on it.)
 3. The relationship between single and double quotes is not very well known, so if you see a quote of one kind used here ... follow that exactly.

To list all users in the database:
```
SELECT * FROM accounts;
```
(Note that table names are case-sensitive as in most databases.)
To set an email address:
```
UPDATE accounts SET PREFERRED_EMAIL = 'somebody@example.com' WHERE account_id=1000001;
```

After setting an email, you will need to flush the caches.

## Manually set a user's *GitHub OAuth* email address
If you get any of the messages:
```
remote: ERROR:  In commit 0000....
remote: ERROR:  committer email address nobody@example.com
remote: ERROR:  does not match your user account.
```
```
remote: ERROR:  You have not registered any email addresses.
```
...this means that your account on Gerrit does not have an email address associated with the GitHub OAuth system. To remedy this, determine the account's ID (see `SELECT * FROM accounts;` above), and then set it with the following command:
```
UPDATE account_external_ids SET EMAIL_ADDRESS = 'nobody@example.com' WHERE account_id=1000020;
```

After setting this, you will need to flush the caches.

## Force flush of caches
Make sure you are in the administrators group and run:
```
ssh USERNAME@git.haiku-os.org gerrit flush-caches
```
