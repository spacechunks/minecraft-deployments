# Minecraft deployments

This repository contains all deployments for our Minecraft server.

The following environment variables need to be set:
```
export BUILD_OCI_REG_USER=Registry user
export BUILD_OCI_REG_PASS=Password for registry user
export BUILD_OCI_REG_SERVER=Registry endpoint e.g. ghcr.io
export AWS_ACCESS_KEY_ID=my_secret_key
export AWS_SECRET_ACCESS_KEY=my_access_key
export AWS_ENDPOINT_URL=https://my_endpoint_url
export AWS_REGION=my_region
```

## Update control-plane oauth client credentials

- Update the credentials in the respective `secrets.sops.json` file.
- If the zitadel project has changed make sure to update the claim to: `urn:zitadel:iam:org:project:id:<new-project-id>:aud`
