backend:
  endpoint: "https://api.world-service.chunks.cloud/"
  token: "${world_service_token}"

mode: RUNTIME
disabledCommands: []
worldListRefreshIntervalSeconds: 30

worldMappings:
  - localName: "blueprint-lobby"
    remoteName: "blueprint-lobby"

startupWorlds:
  - localName: "blueprint-lobby"
    remoteName: "blueprint-lobby"
    version: "latest"
    load: true
    pull: true
