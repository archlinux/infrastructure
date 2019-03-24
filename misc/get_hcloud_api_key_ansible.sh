#!/bin/bash

ansible-vault view misc/hetzner-password.vault | grep hetzner_cloud_api_key | cut -f2 -d' '
