# ACME Webhook for INWX

This project provides a cert-manager ACME Webhook for [INWX](https://inwx.de/) and a corresponding helm chart.

The helm chart is listed at Artifact Hub in repository [andibraeu](https://artifacthub.io/packages/search?page=1&repo=andibraeu) at <https://artifacthub.io/packages/helm/andibraeu/cert-manager-webhook-inwx>.

## Requirements

- [helm](https://helm.sh/) >= v3.0.0
- [kubernetes](https://kubernetes.io/) >= v1.18.0
- [cert-manager](https://cert-manager.io/) >= 1.0.0

## Configuration

The following table lists the configurable parameters of the cert-manager chart and their default values.

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `groupName` | Group name of the API service. | `cert-manager-webhook-inwx.smueller18.gitlab.com` |
| `credentialsSecretRefs` | Names of secrets where INWX credentials are stored. Used for RBAC to allow reading the secret by the service account name of webhook. | `['inwx-credentials']` |
| `deployment.loglevel` | Number for the log level verbosity of webhook deployment | 2 |
| `certManager.namespace` | Namespace where cert-manager is deployed to. | `cert-manager` |
| `certManager.serviceAccountName` | Service account of cert-manager installation. | `cert-manager` |
| `image.repository` | Image repository | `registry.gitlab.com/smueller18/cert-manager-webhook-inwx` |
| `image.tag` | Image tag | `v0.6.0` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `service.type` | API service type | `ClusterIP` |
| `service.port` | API service port | `443` |
| `resources` | CPU/memory resource requests/limits | `{}` |
| `nodeSelector` | Node labels for pod assignment | `{}` |
| `affinity` | Node affinity for pod assignment | `{}` |
| `tolerations` | Node tolerations for pod assignment | `[]` |

## Installation

### cert-manager

Follow the [instructions](https://cert-manager.io/docs/installation/) using the cert-manager documentation to install it within your cluster.

### Webhook

```bash
helm repo add andibraeu https://andibraeu.github.io/helmcharts/
helm repo update
helm install --namespace cert-manager cert-manager-webhook-inwx abdibraeu/cert-manager-webhook-inwx
```

**Note**: The kubernetes resources used to install the Webhook should be deployed within the same namespace as the cert-manager.

To uninstall the webhook run

```bash
helm uninstall --namespace cert-manager cert-manager-webhook-inwx
```

## Issuer

Create a `ClusterIssuer` or `Issuer` resource as following:

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging
spec:
  acme:
    # The ACME server URL
    server: https://acme-staging-v02.api.letsencrypt.org/directory

    # Email address used for ACME registration
    email: mail@example.com # REPLACE THIS WITH YOUR EMAIL!!!

    # Name of a secret used to store the ACME account private key
    privateKeySecretRef:
      name: letsencrypt-staging

    solvers:
      - dns01:
          webhook:
            groupName: cert-manager-webhook-inwx.smueller18.gitlab.com
            solverName: inwx
            config:
              ttl: 300 # default 300
              sandbox: false # default false

              # prefer using secrets!
              # username: USERNAME
              # password: PASSWORD
              # otpKey: OTPKEY

              usernameSecretKeyRef:
                name: inwx-credentials
                key: username
              passwordSecretKeyRef:
                name: inwx-credentials
                key: password
              otpKeySecretKeyRef:
                name: inwx-credentials
                key: otpKey
```

### Credentials

For accessing INWX DNS provider, you need the username and password of the account. You have two choices for the configuration for the credentials, but you can also mix them. When `username` or `password` are set, these values are preferred, and the secret will not be used.

If you choose another name for the secret than `inwx-credentials`, ensure to add to or modify the value of `credentialsSecretRefs` in `values.yaml`.

The secret for the example above will look like this:

### Without 2FA

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: inwx-credentials
stringData:
  username: USERNAME
  password: PASSWORD
```

### With 2FA enabled

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: inwx-credentials
stringData:
  username: USERNAME
  password: PASSWORD
  otpKey: OTPKEY
```

### Create a certificate

Finally you can create certificates, for example:

```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: example-cert
  namespace: cert-manager
spec:
  commonName: example.com
  dnsNames:
    - example.com
  issuerRef:
    kind: ClusterIssuer
    name: letsencrypt-staging
  secretName: example-cert
```