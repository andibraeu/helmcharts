# Stalwart Helm Chart

Helm chart for [Stalwart Mail Server](https://stalw.art/), based on the [official Kubernetes reference](https://stalw.art/docs/cluster/orchestration/kubernetes/).

## Installation

```bash
helm install stalwart ./charts/stalwart
```

## Configuration

### PostgreSQL DataStore with external Secrets

Typical GitOps setup with CloudNativePG and SealedSecrets:

```yaml
image:
  repository: stalwartlabs/stalwart
  tag: ""  # Uses Chart.yaml appVersion when empty

env:
  secretRef: stalwart-env
  dbPasswordSecret:
    name: stalwart-db-credentials
    key: password

config:
  "@type": PostgreSql
  host: stalwart-db-rw
  port: 5432
  database: stalwart
  authUsername: stalwart
  authSecret:
    "@type": EnvironmentVariable
    variableName: STALWART_DB_PASSWORD

persistence:
  enabled: false

ingress:
  enabled: true
  className: traefik
  hosts:
    - host: stalwart.example.com
      paths:
        - path: /
          pathType: Prefix
          portName: mgmt
  tls:
    - secretName: wildcard-tls
      hosts:
        - stalwart.example.com
```

### First install bootstrap

Enable recovery credentials in values for the first install, then disable after creating a permanent admin account:

```yaml
recoveryAdmin:
  enabled: true
  username: admin
  password: "choose-a-strong-password"
```

Alternatively, provide `STALWART_RECOVERY_ADMIN` via `env.secretRef`.

### Persistence

Disable persistence when the DataStore is external (PostgreSQL, MySQL, etc.). Enable it for local RocksDB backends.

```yaml
persistence:
  enabled: true
  accessMode: ReadWriteOnce
  storageClass: local-path
  size: 10Gi
```

## Mail exposure

The Ingress only covers HTTP/HTTPS management traffic. SMTP, IMAP, POP3, and ManageSieve require L4 exposure via `service.type: LoadBalancer` or an external load balancer.

## Testing

```bash
helm lint charts/stalwart
helm template stalwart charts/stalwart -f values.yaml
```
