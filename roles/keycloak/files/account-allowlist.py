#!/usr/bin/env -S python -u
import os
import time

import requests
from authlib.integrations.requests_client import OAuth2Session


def keycloak_api(method, path, data=None, json=None):
    response = client.request(
        method,
        f"https://accounts.archlinux.org/{path}",
        data=data,
        json=json,
    )
    response.raise_for_status()
    if response.status_code == 204:
        return {}
    return response.json()


def sync_allowlist():
    response = requests.get(
        "https://gitlab.archlinux.org/archlinux/account-allowlist/-/raw/state/allowlist.json"
    )
    response.raise_for_status()
    allowlist = response.json()

    for account in allowlist["accounts"]:
        users = keycloak_api(
            "GET",
            "admin/realms/archlinux/users",
            {
                "exact": True,
                "username": account["username"],
                "max": 1,
            },
        )
        if not users:
            print(f"{account['username']} not found.")
            continue

        user = users[0]
        if "attributes" not in user:
            user["attributes"] = {}

        if "allowlistedAt" in user["attributes"]:
            print(f"{account['username']} is already allowlisted.")
            continue

        user["attributes"]["allowlistedAt"] = str(int(time.time()))
        try:
            keycloak_api(
                "PUT",
                f"admin/realms/archlinux/users/{user['id']}",
                json=user,
            )
            print(f"{account['username']} is now allowlisted.")
        except requests.exceptions.HTTPError as err:
            if not err.response.status_code == 400:
                raise
            print(f"Error allowlisting {account['username']}.")


username = os.getenv("KEYCLOAK_USERNAME")
password = os.getenv("KEYCLOAK_PASSWORD")

if username is None or password is None:
    raise Exception("KEYCLOAK_USERNAME and KEYCLOAK_PASSWORD must be set!")

client = OAuth2Session(
    "admin-cli",
    token_endpoint="https://accounts.archlinux.org/realms/master/protocol/openid-connect/token",
)
client.fetch_token(
    username=username, password=password, scope=["offline_access"], leeway=10
)

while True:
    sync_allowlist()
    time.sleep(60)
