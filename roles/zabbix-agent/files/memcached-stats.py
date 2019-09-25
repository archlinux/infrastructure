#!/usr/bin/python

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
        data = stats[0][1]

        # Calculate hit rate
        data['hit_rate'] = round(float(data['get_hits']) / float(data['cmd_get']) * 100)
        data['cache_rate'] = round(float(data['bytes']) / float(data['limit_maxbytes']) * 100)

        print(json.dumps(data))


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
