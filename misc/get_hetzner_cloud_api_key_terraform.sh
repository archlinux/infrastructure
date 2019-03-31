#!/bin/bash

echo "{\"hetzner_cloud_api_key\": \"$(ansible-vault view misc/vault_hetzner.yml | grep hetzner_cloud_api_key | cut -f2 -d' ')\"}"
