#!/bin/bash
# this script is intended to be called by packer to encrypt a single file
decrypted="${ENCRYPTED_FILE%.sops}" # Remove the .sops suffix
sops -e "$decrypted" > "$ENCRYPTED_FILE"
rm $decrypted
