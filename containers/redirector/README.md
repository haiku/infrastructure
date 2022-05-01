# Redirector

A simple service to send traffic from domains (blah.domain.com) to "wherever"

## Usage

Deploy as a standard deployment.  One ConfigMap mounted to /run/config.

ConfigMap format:

* source domain: target domain;rewrite request uri

Example:
```
	domain.com: https://target.com;true
	search.com: https://google.com;false
```

> Make sure to setup a proper certifificate in gke!

## Redirects

All redirects are HTTP 302 so browsers do not cache them.
