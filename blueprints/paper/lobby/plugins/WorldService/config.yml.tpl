backend:
  endpoint: "https://api.world-service.chunks.cloud/"
  token: "${world_service_token}"

mode: RUNTIME
disabledCommands: []
worldListRefreshIntervalSeconds: 30

worldMappings:
  - localName: "devlobby"
    remoteName: "devlobby"

startupWorlds:
  - localName: "devlobby"
    remoteName: "devlobby"
    version: "latest"
    load: true
    pull: true
