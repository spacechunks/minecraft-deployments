resourcePack:
  fetchIntervalSeconds: 5
  thumbnailsLocation: assets/spacechunks/textures/item/explorer/chunk_viewer/thumbnails
  thumbnailMissingKey: spacechunks:explorer/chunk_viewer/thumbnails/missing
  thumbnailKeyPrefix: spacechunks:explorer/chunk_viewer/thumbnails
  s3:
    accessKey: ${s3_access_key}
    secretKey: ${s3_secret_key}
    bucket: ${s3_bucket}
    region: ${s3_region}
    endpoint: ${s3_endpoint}
    packObjectKey: explorer/latest.zip
spawn:
  postgresDSN: ${postgres_dsn}
  world: chunkexplorer:lobby
  location:
    x: 0.5
    y: 65.0
    z: 1.5
  roboLocation:
    x: -9.5
    y: 65.0
    z: -8.5
matchmaking:
  endpoint: mm.explorer.svc.cluster.local:6789
  gatewayAddress: w1.c1.prd.infra.chunks.cloud:30577
  ticketPollIntervalSeconds: 1
controlPlane:
  endpoint: explorer.api.chunks.space:443
  instancePollIntervalSeconds: 1
  auth:
    clientId: ${control_plane_api_client_id}
    clientSecret: ${control_plane_api_client_secret}
    tokenUrl: https://iam.chunks.space/oauth/v2/token
    scopes:
      - openid
      - urn:zitadel:iam:org:project:id:385828015545778272:aud
