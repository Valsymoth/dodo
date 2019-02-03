#!/bin/bash

NAME=$1
TAG=$2

cat << EOF
{
  "name": "$NAME",
  "region": "fra1",
  "size": "s-2vcpu-4gb",
  "image": "debian-9-x64",
  "ssh_keys":["$(cat ./secrets/fingerprint)"],
  "backups": false,
  "ipv6": true,
  "user_data": null,
  "private_networking": null,
  "volumes": null,
  "tags": [
    "$TAG"
  ]
}
EOF

