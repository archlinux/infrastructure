#!/bin/bash

set -e

/usr/bin/vendor_perl/sa-update --channelfile /etc/mail/spamassassin/update-channels --gpgkeyfile /etc/mail/spamassassin/update-gpgkeys || exit 0
/usr/bin/vendor_perl/sa-compile --quiet
systemctl restart spampd
