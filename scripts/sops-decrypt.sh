#!/bin/bash
# this script is intended to be called by packer to decrypt a single file
set -e
decrypted="${ENCRYPTED_FILE%.sops}" # Remove the .sops suffix
echo "decrypting $ENCRYPTED_FILE -> $decrypted"
sops -d "$ENCRYPTED_FILE" > "$decrypted"

# remove encrypted file so we don't leave encrypted file in the container
rm "$ENCRYPTED_FILE"
