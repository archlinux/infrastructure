[Resolve]

# DNS failures cause resolved to rotate to the next server. If StaleRetentionSec
# is 0 (the default), it then flushes its cache (in `link_set_dns_server`), thus
# causing more queries to hit upstream servers and risking more DNS failures.
#
# Synapse causes a lot of queries. By skipping flushing we actually get resolved
# to cache a meaningful amount of answers and drastically reduce the amount of
# failures Synapse encounters.
StaleRetentionSec=180

# vim:set ft=systemd sw=2 sts=-1 et:
