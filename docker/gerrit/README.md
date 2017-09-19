# Gerrit

## Startup

  * ```docker-compose up -d```

## Shutdown

  * ```docker-compose down```

## Bootstrap

To bootstrap the gerrit instance with github auth, set the following
environmental vars in the docker-compose.yml:

```yml
      - OAUTH_GITHUB_CLIENT_ID=XXX
      - OAUTH_GITHUB_CLIENT_SECRET=XXX
```

This only needs done once when the site needs initalized.
