#!/usr/bin/env python
#
# Dynamic inventory script for getting infrastructure information from hcloud

import argparse
import json
import sys

from hcloud import Client

from misc.get_key import load_vault


def parse_args():
    parser = argparse.ArgumentParser(description="Hcloud dynamic inventory script")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--list', action='store_true')
    group.add_argument('--host')
    return parser.parse_args()


def get_host_details(server):
    return {'ansible_host': server.public_net.ipv4.ip,
            'ansible_port': 22,
            'ansible_user': "root"}


def main():
    args = parse_args()
    loaded = load_vault('misc/vaults/vault_hcloud.yml')
    client = Client(token=loaded["hcloud_api_key_readonly"])
    servers = client.servers.get_all()

    hostvars = {server.name: get_host_details(server) for server in servers}
    if args.list:
        hosts = [server.name for server in servers]
        json.dump({'hcloud': hosts, '_meta': {'hostvars': hostvars}}, sys.stdout)
    else:
        json.dump(hostvars[args.host], sys.stdout)


if __name__ == '__main__':
    main()
