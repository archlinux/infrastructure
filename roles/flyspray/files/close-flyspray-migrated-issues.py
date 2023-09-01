#!/usr/bin/python
"""

url
https://bugs.archlinux.org/task/35831

post data

action: details.close
task_id: 35831
resolution_reason: 12
closure_comment: https://gitlab.archlinux.org/archlinux/netctl/issues/2
mark100: 1
"""

import argparse
import json

import requests


class Session(object):

    def __init__(self, user, password):
        self.user = user
        self.password = password
        self.login_page = 'https://bugs.archlinux.org/index.php?do=authenticate'
        self.bug_url = 'https://bugs.archlinux.org/task/{}'

        self.opener = requests.Session()
        self.opener.headers.update({'User-agent': 'Mozilla/5.0'})

        # need this twice - once to set cookies, once to log in...
        self.login()
        self.login()

    def is_issue_closed(self, issue_id):
        response = self.opener.get(self.bug_url.format(issue_id))
        return '<div id="taskclosed">' in response.text

    def close_issue(self, issue_id: int, gitlab_url: str):
        response = self.opener.post(self.bug_url.format(issue_id), data={
            "action": "details.close",
            "task_id": issue_id,
            "resolution_reason": 12,
            "closure_comment": gitlab_url,
            "mark100": 1,
        })
        assert response.status_code == 200

    def login(self):
        "handle login, populate the cookie jar"
        login_data = {'user_name': self.user,
                      'password': self.password,
                      'remember_login': 'on'}
        response = self.opener.get(self.login_page, params=login_data, allow_redirects=False)
        return response.text


URL = 'https://bugs.archlinux.org/task/{}'



def parse_args():
    parser = argparse.ArgumentParser(prog='close-flyspray-issues')
    parser.add_argument('filename', help="id-mapping json file")
    parser.add_argument('--username')
    parser.add_argument('--password')

    return parser.parse_args()

def main():
    args = parse_args()
    session = Session(args.username, args.password)
    bugs_mapping = json.load(open(args.filename))
    for flyspray_id, gitlab_url in bugs_mapping.items():
        print(flyspray_id, gitlab_url)
        if session.is_issue_closed(flyspray_id):
            continue

        session.close_issue(flyspray_id, gitlab_url)


if __name__ == "__main__":
    main()



