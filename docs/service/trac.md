# Trac + SSO!

* Trac has usernames + emails
* Keycloak has usernames + emails
* These don't always align (especially for old accounts)


## Alignment

> Please strongly validate anyone's identity before aligning accounts.

Perform these checks, in this order...

### Email Misalignment?
Align the User's email to what is in keycloak via Admin -> TracOIDC -> Fix Email Address

### Username Misalignment?
Align the User's Username to what is in keycloak via Admin -> TracOIDC -> Rename Track User

### Ask user to login.
Unlink the identity from keycloak if needed via Admin -> TracOIDC -> Unlink SSO Identity

Once a user is  "linked", the email in trac will always reflect what Keycloak has.
