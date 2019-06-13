#!/bin/sh
exec gpg --batch --decrypt --quiet "$(dirname $0)/vault-password.gpg"
