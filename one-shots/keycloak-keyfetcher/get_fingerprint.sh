#!/usr/bin/env bash

curl -s https://accounts.archlinux.org/auth/realms/master/protocol/saml/descriptor  | xmllint --xpath '//*[local-name()="X509Certificate"]/text()' - | base64 -d | sha1sum | cut -d ' ' -f1 | sed -e 's/.\{2\}/&:/g' | sed 's/:$//' | tr '[:lower:]' '[:upper:]'
