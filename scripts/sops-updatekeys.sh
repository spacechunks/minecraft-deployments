#!/bin/bash
# calls sops updatekeys on all files encrypted with sops.
# those files are suffixed with .sops.yaml
# sops updatekeys will enable keys to decrypt files
# within their respective keygroup.
find . \( \( -name '*.sops.yaml' -or -name '*.sops.yml' -or -name '*.sops.json' -or -name '*.sops' \) -and -not \( -name '.sops.yaml' \) \) -print0 | xargs -0L1 sops updatekeys --yes --enable-local-keyservice
