#!/bin/bash

set -e

/usr/bin/vendor_perl/sa-update --channelfile /etc/mail/spamassassin/update-channels --gpgkeyfile /etc/mail/spamassassin/update-gpgkeys || {
	exitcode=$?
	if ((exitcode == 1)); then
		exit 0
	else
		echo "sa-update failed"
		exit 1
	fi
}
/usr/bin/vendor_perl/sa-compile --quiet
systemctl restart spampd
