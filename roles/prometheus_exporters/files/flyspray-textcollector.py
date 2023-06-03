#!/usr/bin/python

import sys
import shutil
import tempfile

import sqlalchemy

engine = sqlalchemy.create_engine('mysql://localhost/flyspray', connect_args={'read_default_file': '/root/.my.cnf'})


def get_flyspray_header():
    return '# HELP flyspray_issues number of open issues\n# TYPE flyspray_issues gauge\n'


def format_metric(project, total):
    return f'flyspray_issues{{project="{project}"}} {total}\n'


def get_metric(project_id):
	with engine.connect() as conn:
		result = conn.execute(f"SELECT count(task_id) from flyspray_tasks where project_id = {project_id} and is_closed = 0")
		return next(result)[0]


def main(directory):
    with tempfile.TemporaryDirectory() as tmpfp:
        filename = f'{tmpfp}/flyspray-status.prom'
        print(filename)

        with open(filename, 'w') as fp:
            fp.write(get_flyspray_header())
            fp.write(format_metric("Arch Linux", get_metric(1)))
            fp.write(format_metric("Community", get_metric(5)))

        shutil.move(filename, f'{directory}/flyspray-status.prom')


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print('Missing textcollector directory argument')

    main(sys.argv[1])
