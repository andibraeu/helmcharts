[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/andibraeu)](https://artifacthub.io/packages/search?repo=andibraeu) [![Latest Release](https://img.shields.io/github/v/release/andibraeu/helmcharts)]()  

# openhabcloud-helmchart

## How to use:

1. Install with `helm install andibraeu https://andibraeu.github.io/helmcharts/`
2. Use the `ohcloud` chart

## Configuration

Update these values, use secrets for values not everyone should see:

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
    - name: "MONGODB_USER"
      value: ""
    - name: "MONGODB_PASS"
      value: ""
    - name: "REDIS_HOST"
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