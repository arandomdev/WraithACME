# WraithACME
ACME Client for Wraith. Supports multiple domains.

## Setup
A `config.yaml` file is needed with account and domain information. This file should be mounted to `/home/acme/config.yaml`.
```yaml
account:
  email: email@example.com
  server: letsencrypt

domains:
  - domain: example.com
    alts:
      - "*.example.com"
      - "subdomain.example.com"

    dns: dns_cf # Requires Cloudflare/dns API credentials in env
    keylength: ec-384

    certs-path: /ssl/certs # Root path for output certs
    # File names for cert files
    cert-file: cert.pem
    key-file: key.pem
    ca-file: ca.pem
    fullchain-file: fullchain.pem
```

Volumes and mounts are also needed. Their permissions are automatically set on startup.
* `/home/acme`
    * ACME config and data
* `/ssl/certs`
    * Certificate files. One should be made for each domain for secure separation.
    * Key files will also be readable by PGID.

Example docker compose.
```yaml
services:
  acme:
    build: .
    container_name: acme
    volumes:
      - config.yaml:/home/acme/config.yaml:ro
      - acme-data:/home/acme
      - acme-certs:/ssl/certs
    environment:
      - PUID=1001
      - PGID=1001
      - CF_Token=abc
      - CF_Account_ID=abc
      - CF_Zone_ID=abc

volumes:
  acme-data:
    name: acme-data
  acme-certs:
    name: acme-certs

```