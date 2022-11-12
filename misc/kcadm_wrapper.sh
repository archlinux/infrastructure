#!/usr/bin/env bash
#
# Script that wraps kcadm.sh to securely get our credentials.
# It always operates on the realm `archlinux` for convenience.
#
# Example invocation:
# misc/kcadm_wrapper.sh get realms
# misc/kcadm_wrapper.sh get authentication/flows
# Refer to the API docs for which resources exist:
# https://www.keycloak.org/docs-api/10.0/rest-api/index.html
# See for general kcadm usage:
# https://github.com/keycloak/keycloak-documentation/blob/master/server_admin/topics/admin-cli.adoc

kcadm "$@" \
    -r archlinux \
    --no-config \
    --server https://accounts.archlinux.org \
    --realm master \
    --user $(misc/get_key.py group_vars/all/vault_keycloak.yml vault_keycloak_admin_user) \
    --password $(misc/get_key.py group_vars/all/vault_keycloak.yml vault_keycloak_admin_password)
