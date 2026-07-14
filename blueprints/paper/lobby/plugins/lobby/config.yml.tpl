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
  world: blueprint
  location:
    x: 0.5
    y: -60.25
    z: 0.5
  roboLocation:
    x: 0.5
    y: -60.0
    z: 5.5
matchmaking:
  endpoint: mm.explorer.svc.cluster.local:6789
  gatewayAddress: w1.c1.prd.infra.chunks.cloud:30577
  ticketPollIntervalSeconds: 1
controlPlane:
  endpoint: api.explorer.chunks.space:443
  apiToken: ${control_plane_api_token}
  instancePollIntervalSeconds: 1
