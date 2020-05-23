#!/usr/bin/env bash
#
# Script that wraps kcadm.sh to securely get our credentials.
#
# Example invocation:
# misc/kcadm_wrapper.sh get realms
#
kcadm "$@" --no-config --server https://accounts.archlinux.org/auth --realm master --user $(misc/get_key.py group_vars/all/vault_keycloak.yml vault_keycloak_admin_user) --password $(misc/get_key.py group_vars/all/vault_keycloak.yml vault_keycloak_admin_password)
