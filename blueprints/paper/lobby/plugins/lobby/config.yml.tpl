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
  world: blueprint-lobby
  location:
    x: -434.5
    y: -77.0
    z: 48.5
chunkViewer:
  instancePollIntervalSeconds: 1
  gatewayAddress: 94.130.228.127:30577
  matchmaking:
    endpoint: mm.explorer.svc.cluster.local:6789
  controlPlane:
    endpoint: api.explorer.stag.chunks.cloud:443
    apiToken: ${control_plane_api_token}
