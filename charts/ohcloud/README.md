[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/andibraeu)](https://artifacthub.io/packages/search?repo=andibraeu) [![Latest Release](https://img.shields.io/github/v/release/andibraeu/helmcharts)]()  

# openhabcloud-helmchart

## How to use:

1. Install with `helm install andibraeu https://andibraeu.github.io/helmcharts/`
2. Use the `ohcloud` chart

## Configuration

Configure those values for your instance:

```
  features:
    subdomainCookies: false
    domainName: ""
    enableHealthEndpoint: false
    enableGcm: false
    mongodbUri: ""
    mongodbDb: ""
    mailHost: ""
    redisHost: ""
    registrationEnabled: false
```

Create a secret for those values and install it before deployment:

```
  env:
    - name: "EXPRESS_KEY"
      value: ""
    - name: "APN_PASSPHRASE"
      value: ""  
    - name: "GCM_SENDER_ID"
      value: ""
    - name: "GCM_SERVICE_FILE"
      value: ""
    - name: "MONGODB_USER"
      value: ""
    - name: "MONGODB_PASS"
      value: ""
    - name: "REDIS_PASSWORD"
      value: ""
    - name: "MAIL_USER"
      value: ""
    - name: "MAIL_PASSWORD"
      value: ""
```