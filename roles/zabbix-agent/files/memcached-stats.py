#!/usr/bin/python

'''
Metrics:

- uptime - time memcached is alive
- listen_disabled_num - the number of times: the max number of connections is reachedand:ii
- conn_yields -  Number of times a client connection was throttled.
- hits - get_hits / cmd_get. It indicates how efficient your Memcached server is.
- fill - used bytes / limit_maxbytes - Fill percentage
- evictions - an eviction is when an item that still has time to live is removed from the cache because a brand new item needs to be allocated
- command flush - the flush_all command invalidates all items in the database
- connections_total - total number of connections
'''

import argparse
import json
import os

from memcache import Client


SOCKET_DIR = '/run/memcached'


def stats(socket):
    client = Client([f'unix://{SOCKET_DIR}/{socket}'])
    stats = client.get_stats()
    if not stats:
        print(json.dumps({}))
    else:
        print(json.dumps(stats[0][1]))


def discover():
    sockets = []
    for loc in os.listdir(SOCKET_DIR):
        if not loc.endswith('.sock'):
            continue
        sockets.append({"{#SOCKET}": loc})

    print(json.dumps({"data": sockets}))


def main():
    parser = argparse.ArgumentParser(description='memcached statistics dumptool (in json)')
    parser.add_argument('--discover', action='store_true', help='discover memcached sockets')
    parser.add_argument('--socket', type=str, help='the memcached socket location')
    args = parser.parse_args()
    if args.discover:
        discover()
    if args.socket:
        stats(args.socket)


if __name__ == "__main__":
    main()
