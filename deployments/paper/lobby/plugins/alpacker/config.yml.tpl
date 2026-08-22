# Alpacker configuration.
#
# Resources are merged from top to bottom. Later resources have higher priority
# and may overwrite files from earlier resources.

general:
  periodic-pulls:
    enabled: true
    interval: 1m
    build-after-pull: true
  startup-auto-build:
    enabled: true
    delay: 5s

  storage:
    resources-directory: resources
    bundles-directory: bundles
    keep-versions: 10

  api:
    enabled: false
    bind: 127.0.0.1
    port: 8087
    token: "change-me"

  github-webhook:
    enabled: false
    bind: 127.0.0.1
    port: 8088
    path: /github/webhook
    secret: "change-me"

nexo:
  plugin-directory: ../Nexo
  default-directory: nexo_default
  reload-command: "n reload all"
  generated-pack: ../Nexo/pack/pack.zip

upload:
  provider: NONE
  public-base-url: ""

bundles:
  - name: spacechunks-default
    description: Default SpaceChunks pack for production servers.
    auto-build: true
    send-after-build: false
    resources:
      - name: universal-nexo-main
        type: NEXO
        source: github
        repository: ${alpacker_universal_nexo_repo}
        branch: main
      - name: chunk-viewer
        type: RESOURCEPACK
        source: local
        path: "plugins/lobby/pack.zip"
        delete-files:
          prefixes:
            - ".DS_Store"
            - "_template"
      - name: bettermodel
        type: RESOURCEPACK
        source: local
        path: "plugins/BetterModel/build.zip"
        delete-files:
          prefixes:
            - ".DS_Store"
            - "_template"
