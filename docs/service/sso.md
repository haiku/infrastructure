# SSO Authentication

"introspection"

Haiku leverages keycloak installed at https://sso.haiku-os.org for authentication.

We prefer OAuth2 because it's awesome

## Attaching new authentication clients

1) Login as the master realm admin (contact sysadmin team if you don't have access)
2) Switch to the haiku realm
3) Choose clients -> create client
4) Client type: OpenID Connect
5) Client ID: <name>-app , Name: "<name>", Description: Brief description, Display in UI: off, Next
6) Client authentication: on.  Default Authentication flow, Next
7) Root URL: https://myapp.haiku-os.org, valid redirect URI: depends on app, web origins: app url, Save
8) Credentials, Client Authenticator: Client Id and Secret.   Copy secret (keep it secure)
9) Add the Client ID, Client Secret, and configure [the endpoint](https://sso.haiku-os.org/realms/haiku/.well-known/openid-configuration)
10) The user roles are available under "roles", email is available under "email"
11) You can simulate what is available to clients via Client scopes -> Evaluate

## Renaming users

> Renaming Keycloak users is not recommended except in extreme cases. We
> have a wide range of legacy systems keying off of the username field which
> don't take username changes well.
>
> DO NOT ENABLE USERS EDITING THEIR OWN USERNAMES in User Profile permissions!

1) Login as a Keycloak admin
2) Switch to the haiku realm
4) Users -> find the user -> rename the user

### Fix Trac

1) Login to Trac.  Admin -> Rename Trac User
2) Rename the trac user, ensuring the new username matches the update

### Fix Gerrit

See [Gerrit Documentation](gerrit.md) for details

1) Login to Gerrit, find your HTTP username / password
2) Find the account ID using the Gerrit APIs
3) Erase the external id "keycloak-oauth:OLDUSERNAME"
4) Erase the username for the user in gerrit "username:OLDUSERNAME"
5) Create a new username for the user in gerrit username:NEWUSERNAME"
6) Add the user's email back to their identity in Gerrit
7) Use ```tools/sso/gerrit_identity_fixer.rb``` to tie the new identity to the user (see the comments in the script on how to use it)

### Validation

Ask the user to login to all systems they use and ensure access.
