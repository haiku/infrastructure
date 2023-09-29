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
