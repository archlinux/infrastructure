#!/usr/bin/env python
import argparse
import os
import sys
import time
import webbrowser
from datetime import datetime

import requests
import yaml

IMPORT_GROUPS = {
    "dev": "Developers",
    "devops": "DevOps",
    "tu": "Trusted Users",
}


CLIENT_ID = "admin-cli"
KEYCLOAK_ADMIN_USERNAME = os.environ["KEYCLOAK_ADMIN_USERNAME"]
KEYCLOAK_ADMIN_PASSWORD = os.environ["KEYCLOAK_ADMIN_PASSWORD"]
KEYCLOAK_URL = "https://accounts.archlinux.org/auth"
KEYCLOAK_REALM = "master"

REALM_URL = f"{KEYCLOAK_URL}/realms/{KEYCLOAK_REALM}"
FETCH_TOKEN_URL = f"{REALM_URL}/protocol/openid-connect/token"
API_BASE_URL = f"{KEYCLOAK_URL}/admin/realms/{KEYCLOAK_REALM}"

_token_expire = 0
_token_cache = ""


def get_token():
    global _token_cache
    global _token_expire

    if _token_expire < datetime.now().timestamp():
        r = requests.post(
            FETCH_TOKEN_URL,
            data={
                "username": KEYCLOAK_ADMIN_USERNAME,
                "password": KEYCLOAK_ADMIN_PASSWORD,
                "grant_type": "password",
                "client_id": CLIENT_ID,
            },
        )
        data = r.json()

        if "error" in data:
            sys.stderr.write(
                f"Error requesting token: {data.get('error_description', data['error'])}\n"
            )
            sys.exit(1)

        _token_expire = datetime.now().timestamp() + data["expires_in"]
        _token_cache = data["access_token"]

    return _token_cache


def get_auth_headers():
    token = get_token()
    return {"Authorization": f"Bearer {token}"}


def is_valid_file(parser, arg):
    if not os.path.exists(arg):
        parser.error(f"File {arg!r} does not exist")
    return open(arg, "r")


def add_user_to_group(user_id: str, group_id: str):
    r = requests.put(
        f"{API_BASE_URL}/users/{user_id}/groups/{group_id}",
        data={"realm": KEYCLOAK_REALM, "userId": user_id, "groupId": group_id},
        headers=get_auth_headers(),
    )

    if r.status_code in (200, 204):
        # Success, empty response
        return
    else:
        data = r.json()
        if "error" in data:
            sys.stderr.write(
                f"Error adding user to group: {data.get('error_description', data['error'])}\n"
            )
            sys.exit(1)


def get_all_users():
    all_users = requests.get(
        f"{API_BASE_URL}/users",
        {"briefRepresentation": "true", "first": "0", "max": "200"},
        headers=get_auth_headers(),
    ).json()
    return {u["username"]: u["id"] for u in all_users}


def get_all_groups():
    all_groups = requests.get(
        f"{API_BASE_URL}/groups",
        {"first": "0", "max": "200"},
        headers=get_auth_headers(),
    ).json()
    return {g["name"]: g["id"] for g in all_groups}


def main():
    if not KEYCLOAK_ADMIN_USERNAME or not KEYCLOAK_ADMIN_PASSWORD:
        sys.stderr.write(
            "Environment variables KEYCLOAK_ADMIN_USERNAME and KEYCLOAK_ADMIN_PASSWORD must be set\n"
        )
        exit(1)
    p = argparse.ArgumentParser()
    p.add_argument("file", type=lambda x: is_valid_file(p, x))
    args = p.parse_args(sys.argv[1:])

    users_yml = yaml.load(args.file, Loader=yaml.SafeLoader)
    users = users_yml["arch_users"]

    user_ids = get_all_users()
    group_ids = get_all_groups()

    print(user_ids)

    for username, user in users.items():
        if username not in user_ids:
            # Check if the user has a significant role
            for group in user["groups"]:
                if group in IMPORT_GROUPS:
                    break
            else:
                # Otherwise, skip creating it
                continue
            print(f"Creating {username!r}")
            name = user.get("name", "")
            first_name, last_name = "", ""
            if name:
                _names = name.split()
                if _names:
                    first_name = _names[0]
                    if len(_names) > 1:
                        last_name = " ".join(_names[1:])
            response = requests.post(
                f"{API_BASE_URL}/users",
                json={
                    "username": username,
                    "email": user.get("email", ""),
                    "firstName": first_name,
                    "lastName": last_name,
                    "enabled": True,
                },
                headers=get_auth_headers(),
            )

    user_ids = get_all_users()
    for username, user in users.items():
        for group in user["groups"]:
            if group in IMPORT_GROUPS:
                import_group = IMPORT_GROUPS[group]
                print(f"Adding {username!r} to {import_group!r}")
                add_user_to_group(user_ids[username], group_ids[import_group])


if __name__ == "__main__":
    main()
