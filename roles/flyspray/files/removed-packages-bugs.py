#!/usr/bin/python

from re import search
from subprocess import check_output

import sqlalchemy

REGEX = r'\[([A-Za-z0-9_-]+)\]'

packages = check_output(['/usr/bin/pacman', '-Slq']).decode().splitlines()

engine = sqlalchemy.create_engine('mysql://localhost/flyspray', connect_args={'read_default_file': '/root/.my.cnf'})


with engine.connect() as conn:
    result = conn.execute("SELECT task_id,item_summary from flyspray_tasks where is_closed=0 and project_id in (1,5)")
    for row in result:
        m = search(REGEX, row['item_summary'])
        if not m:
            continue

        pkgname = m.group(1)
        if pkgname not in packages:
            task_id = row['task_id']
            print(f'Removed package {pkgname} found - https://bugs.archlinux.org/task/{task_id}')
