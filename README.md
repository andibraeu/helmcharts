# openhabcloud-helmchart

## How to use:

1. Install with `helm install andibraeu https://andibraeu.github.io/helmcharts/`
2. Use the `ohcloud` chart

## Configuration

Update these values:

```
  env:
    - name: "DOMAIN_NAME"
      value: ""
    - name: "EXPRESS_KEY"
      value: ""
    - name: "APN_PASSPHRASE"
      value: ""
    - name: "GCM_PASSWORD"
      value: ""
    - name: "MONGODB_URI"
      value: ""
    - name: "MONGODB_DB"
      value: ""
    - name: "REDIS_PASSWORD"
      value: ""
    - name: "MAIL_USER"
      value: ""
    - name: "MAIL_PASSWORD"
      value: ""
    - name: "MAIL_FROM"
      value: ""
```