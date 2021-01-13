#!/usr/bin/python

import sys
import shutil
import tempfile

import requests

# The rebuilderd instance
API_URL = 'https://reproducible.archlinux.org'


def get_metric_header():
    return '# HELP rebuilderd_results number of packages\n# TYPE rebuilderd_results gauge\n'


def format_metric(suite, status, total):
    status = status.lower()
    return f'rebuilderd_results{{suite="{suite}",status="{status}"}} {total}\n'


def get_rebuilderd_data():
    req = requests.get(f'{API_URL}/api/v0/dashboard')
    if req.status_code != 200:
        print(f'Failed to obtain rebuilderd data, http status code: {req.status_code}', file=sys.stderr)
        sys.exit(1)

    data = req.json()
    return data['suites']


def main(directory):
    dataset = get_rebuilderd_data()

    with tempfile.TemporaryDirectory() as tmpfp:
        filename = f'{tmpfp}/rebuilderd_status.prom'
        print(filename)

        with open(filename, 'w') as fp:
            fp.write(get_metric_header())
            for suite, data in dataset.items():
                for status, total in data.items():
                    fp.write(format_metric(suite, status, total))

        shutil.move(filename, f'{directory}/rebuilderd-status.prom')


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print('Missing textcollector directory argument')

    main(sys.argv[1])
