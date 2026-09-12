# Spliit Helm Chart

Helm chart for [Spliit](https://github.com/spliit-app/spliit), a free and open source Splitwise alternative.

The published image runs Prisma migrations on startup (`prisma migrate deploy`) and serves the Next.js app on port 3000.

## Requirements

Spliit does **not** bundle a database. You need:

1. **PostgreSQL 16+** (17 is used in the upstream compose file) with a dedicated database and user
2. Network access from the Spliit pod to that database
3. Either `postgresql.existingSecret` (keys `username` / `password`) or `postgresql.password`

Optional:

- **S3-compatible storage** to attach images to expenses (`config.enableExpenseDocuments`)
- **OpenAI-compatible API** for receipt scanning and category suggestions
- **Analytics** (`console` or `plausible`)

There is no built-in user login. Groups are shared via secret URLs.

## Installation

```bash
helm install spliit ./charts/spliit \
  --set postgresql.host=spliit-db-rw \
  --set postgresql.password='url-safe-password'
```

## Configuration

### External PostgreSQL (CloudNative-PG example)

```yaml
postgresql:
  host: spliit-db-rw
  port: 5432
  database: spliit
  username: spliit
  existingSecret: spliit-db-credentials
  existingSecretUsernameKey: username
  existingSecretPasswordKey: password
```

The chart builds `POSTGRES_PRISMA_URL` and `POSTGRES_URL_NON_POOLING` from those values. Kubernetes expands `$(POSTGRES_USER)` and `$(POSTGRES_PASSWORD)`, so the password must be URL-safe (no `@`, `:`, `/`, `#`, `?`).

To pass full URLs instead:

```yaml
postgresql:
  host: spliit-db-rw
  existingSecret: spliit-db-credentials
  existingSecretPrismaUrlKey: POSTGRES_PRISMA_URL
  existingSecretNonPoolingUrlKey: POSTGRES_URL_NON_POOLING
```

### Ingress

```yaml
config:
  baseUrl: https://spliit.example.com
  defaultCurrencyCode: EUR

ingress:
  enabled: true
  className: traefik
  hosts:
    - host: spliit.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: wildcard-tls
      hosts:
        - spliit.example.com
```

### Expense documents and AI features

Prefer `existingSecret` over plain values for credentials:

```yaml
config:
  enableExpenseDocuments: true
  enableReceiptExtract: true
  enableCategoryExtract: true
  s3:
    uploadBucket: spliit
    uploadRegion: us-east-1
    uploadEndpoint: https://minio.example.com
existingSecret: spliit-optional-secrets
```

## Testing

```bash
helm lint charts/spliit
helm template spliit charts/spliit \
  --set postgresql.host=spliit-db-rw \
  --set postgresql.password=changeme
```
