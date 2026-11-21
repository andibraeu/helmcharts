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

## Upgrading from 1.x to 2.0

Chart 2.0 moves from Stalwart v0.16 to Stalwart v1. Stalwart v1 uses a new
database layout and cannot open a v0.16 data store, so an in-place upgrade is
not possible. The data has to be copied into a new, empty data store with
[stalwart-migrate](https://github.com/stalwartlabs/stalwart-migrate). The tool
opens the v0.16 store read-only, so the old deployment remains a fallback.

1. Upgrade to chart `1.0.7` (Stalwart v0.16.27) first; the migration tool
   requires exactly this version.
2. Create a new, empty data store (for example a new PostgreSQL database) and
   a `config.json` for it.
3. Run the migration tool (image `stalwartlabs/stalwart-migrate`) in a pod that
   mounts the current `<release>-config` ConfigMap at `/etc/stalwart`, the new
   configuration at `/etc/stalwart-v1` and a persistent state directory at
   `/var/lib/stalwart-migrate`:
   - `stalwart-migrate prepare` (interactive, use `kubectl exec -it`)
   - `stalwart-migrate run` (incremental, may run while v0.16 is serving)
   - scale the StatefulSet to 0, then `stalwart-migrate run --final`
   - `stalwart-migrate report --severity error`
4. Set `config` to the new data store, upgrade to chart 2.x and start once with:

   ```yaml
   extraEnv:
     STALWART_UPDATE_ROLE_PERMISSIONS: "true"
   ```

   Remove the variable after the first successful start.

Keep the v0.16 data store and the migration state directory until v1 has
proven itself; `stalwart-migrate rollback` needs the state directory.

Visible effects after the switch: OAuth tokens are not migrated (users sign in
again), CalDAV/CardDAV/WebDAV clients re-download their data once, and the
full-text index is rebuilt in the background.

See the [official migration guide](https://stalw.art/docs/migration/upgrade-0-16/)
for all options.

## Mail exposure

The Ingress only covers HTTP/HTTPS management traffic. SMTP, IMAP, POP3, and ManageSieve require L4 exposure via `service.type: LoadBalancer` or an external load balancer.

## Testing

```bash
helm lint charts/stalwart
helm template stalwart charts/stalwart -f values.yaml
```
