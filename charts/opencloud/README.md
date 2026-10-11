# OpenCloud Helm Chart

Helm chart for [OpenCloud](https://opencloud.eu/), a file sync and share platform.
This chart targets non-enterprise setups: PosixFS on Kubernetes PVCs, optional external OIDC, and optional hooks for Collabora, Radicale, and live editing via Yjs.

It does **not** deploy MinIO, Keycloak, Collabora, Radicale, OpenSearch, ClamAV, or Apache Tika.

## Installation

```bash
helm install opencloud ./charts/opencloud \
  --set adminPassword='change-me' \
  --set ingress.enabled=true \
  --set ingress.hostname=cloud.example.com
```

Prefer an existing Secret in production:

```yaml
existingSecret: opencloud-admin
existingSecretKey: admin-password
```

## Persistence

OpenCloud stores configuration and data on two PVCs. Back them up as a pair; `opencloud init` creates matching secrets across both volumes.

| Volume | Mount | Default size | Contents |
| ------ | ----- | ------------ | -------- |
| Config | `/etc/opencloud` | `1Gi` | `opencloud.yaml`, generated secrets |
| Data | `/var/lib/opencloud` | `30Gi` | IDM/LDAP, NATS, search index, user files under `storage/users` |

Default storage uses the `posix` driver (PosixFS): files are stored as a normal directory tree on the data PVC. The volume must be a POSIX filesystem with `flock` and extended attributes (ext4/XFS on local-path, Longhorn, or Ceph-RBD).

```yaml
replicaCount: 1
persistence:
  config:
    size: 1Gi
    annotations:
      k8up.io/backup: "true"
  data:
    accessMode: ReadWriteOnce
    size: 100Gi
    storageClass: ""
    annotations:
      k8up.io/backup: "true"
```

`replicaCount > 1` requires `ReadWriteMany` (NFS 4.2+ with `noac`, or CephFS). The chart refuses to render otherwise.

## Image channel

The chart defaults to the **rolling** image `opencloudeu/opencloud-rolling` (currently `8.1.0`). Production tags (`opencloudeu/opencloud`) trail the rolling channel. Real-time Markdown editing and Excalidraw require 8.x.

When upgrading from 7.x to 8.x, reindex once:

```bash
kubectl exec -it deploy/opencloud -- opencloud search index --all-spaces --force-rescan --insecure
```

## External OIDC

```yaml
oidc:
  external:
    enabled: true
    issuer: https://auth.example.com/realms/openCloud
    domain: auth.example.com
```

Clients are public clients with PKCE. Register the WebFinger client IDs (`web`, `OpenCloudDesktop`, `OpenCloudAndroid`, `OpenCloudIOS`) in your IdP. The IdP must return the claims OpenCloud needs even when clients do not request them as scopes.

The browser must be allowed to call the IdP. OpenCloud's built-in Content-Security-Policy does not include it. When external OIDC is enabled, this chart merges the issuer origin (`scheme://host[:port]`, path stripped) into `connect-src`, `frame-src`, and `script-src`.

## Collabora / Office (external only)

This chart only configures the WOPI collaboration service. Deploy Collabora (or OnlyOffice / Euro Office) elsewhere.

```yaml
collaboration:
  enabled: true
  appAddr: https://collabora.example.com
  appProduct: Collabora
```

Requirements on the office host:

- Aliasgroup must allow the public OpenCloud URL
- Collabora must reach OpenCloud at `/wopi` and `/collaboration`
- Browsers connect to Collabora directly (separate hostname)

Rough sizing for a small Collabora CODE instance: about 2 CPU and 2 GB RAM for a few concurrent editors.

The chart adds the `appAddr` origin to `frame-src` and `img-src`, so the editor iframe is allowed by the OpenCloud page policy.

## Content-Security-Policy

OpenCloud ships a built-in policy. This chart does not replace it. It merges extra origins through `PROXY_CSP_CONFIG_FILE_LOCATION` when an external IdP, Collabora, or `csp.extra` is set.

| Source | Directives |
| --- | --- |
| OIDC issuer origin | `connect-src`, `frame-src`, `script-src` |
| `collaboration.appAddr` origin | `frame-src`, `img-src` |
| `csp.extra.*` | the matching directive |

Add further origins without copying the built-in rules:

```yaml
csp:
  extra:
    connectSrc:
      - https://maps.example.com
    frameSrc:
      - https://office.example.com:8443
```

## Radicale (external only)

OpenCloud can proxy CalDAV/CardDAV to Radicale. This chart does not deploy Radicale.

```yaml
radicale:
  enabled: true
  url: http://radicale.radicale.svc:5232
```

If you already run Stalwart for calendars, leave `radicale.enabled=false` and point clients at Stalwart (`/dav/cal`, `/dav/card`). Stalwart does not accept OpenCloud's `X-Remote-User` header.

## Yjs (optional, deployed by this chart)

Live collaboration for Markdown, `.ocnote`, and Excalidraw uses a Yjs/Hocuspocus relay on `wss://<opencloud-host>/yjs`.

```yaml
yjs:
  enabled: true
  image:
    repository: opencloudeu/yjs
    tag: "1.1.0"
```

Without Yjs the editor still works; sessions are simply not shared in real time.

## SMTP notifications

```yaml
smtp:
  enabled: true
  host: smtp.example.com
  port: 587
  sender: "OpenCloud <noreply@example.com>"
  username: opencloud
  existingSecret: opencloud-smtp
  existingSecretKey: smtp-password
  encryption: starttls
  authentication: auto
```

## Ingress example

```yaml
ingress:
  enabled: true
  className: nginx
  hostname: cloud.example.com
  annotations:
    nginx.ingress.kubernetes.io/proxy-body-size: "0"
    cert-manager.io/cluster-issuer: letsencrypt
  tls:
    enabled: true
    secretName: opencloud-tls
```

## Resources

Leave `resources` empty by default. Bleve search (built-in) is much lighter since OpenCloud 8.0 (~120 MB for ~100k files instead of ~1.1 GB), but thumbnails and indexing still benefit from headroom. Example:

```yaml
resources:
  requests:
    cpu: 500m
    memory: 1Gi
  limits:
    memory: 2Gi
```

## Values overview

| Key | Description | Default |
| --- | ----------- | ------- |
| `image.repository` | OpenCloud image | `opencloudeu/opencloud-rolling` |
| `adminPassword` / `existingSecret` | Built-in admin password | required |
| `storage.driver` | `posix` or `decomposed` | `posix` |
| `oidc.external.enabled` | Use external IdP | `false` |
| `collaboration.enabled` | External office WOPI | `false` |
| `csp.extra.connectSrc` | Extra `connect-src` origins | `[]` |
| `csp.extra.frameSrc` | Extra `frame-src` origins | `[]` |
| `radicale.enabled` | External CalDAV/CardDAV | `false` |
| `yjs.enabled` | Deploy Yjs relay | `false` |
| `smtp.enabled` | Mail notifications | `false` |

See [values.yaml](values.yaml) for the full list.
