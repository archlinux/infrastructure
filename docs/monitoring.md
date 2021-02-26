# Monitoring

All of our servers are monitored using Prometheus, exporters on the to be monitored machines have a firewall rule configured to allow connections from monitoring.archlinux.org for the specific exporter port.
To access our monitoring system, go to https://monitoring.archlinux and log in via your Arch Linux SSO credentials.

## Adding a new host to monitoring

* Add $host to node_exporters in `hosts`
* Rollout exporter on host: `ansible-playbook playbooks/host.yml -t prometheus_exporters`
* Rollout changes on monitoring host: `ansible-playbook playbooks/monitoring.archlinux.org.yml -t prometheus`

### System

For general system performance monitoring [prometheus-node-exporter](https://github.com/prometheus/node_exporter) is used in combination with a textfile collector for Arch Linux specific and btrfs metrics. A systemd service/timer 'prometheus-arch-textcollector' writes the amount of out of date packages and security updates. For btrfs monitoring, `btrfs device stats` is executed on all btrfs devices on the system and all errors stats are record. When running the prometheus_exporters role the node-exporter, arch textcollector and btrfs textcollector is automatically added.

### memcached

[prometheus-memcached-exporter](https://github.com/prometheus/memcached_exporter) is used for monitoring. Adding memcached monitoring to a host is as simple as:

* Add the host to the `memcached` group
* Add `memcached_socket` to the `host_vars` of the machine with the location of the memcached socket
* Rollout exporter on host: `ansible-playbook playbooks/host.yml -t prometheus_exporters`

### Borg

For monitoring our borg backups prometheus-node-exporter's textfile collector feature is used, the textfile is written by a systemd service called prometheus-borg-textcollector. Borg's last backup time is recorded for our Hetzner and rsync.net backups. Adding monitoring to a system is as simple as:

* Add the host to the `borg_clients` group
* Rollout exporter on host: `ansible-playbook playbooks/host.yml -t prometheus_exporters`

### rebuilderd

The rebuilderd instance Arch Linux hosts is monitored using prometheus-node-exporter's textfile collector feature which periodically collects data using a prometheus-rebuilderd-textcollector.timer. The 'rebuilderd-textcollector.sh' script collects the queue length and amount of working rebuilders to monitor if the rebuilderd queue keeps growing forever or rebuilderd workers stopped working. The 'rebuilderd-status-textcollector.py' script collects the rebuilderd status good, bad and unknown packages per repository for keeping tracking of the reproducible builds progress. Adding monitoring for rebuilderd:

* Add the rebuilderd instance to the `rebuilderd` group
* Rollout exporter on host: `ansible-playbook playbooks/host.yml -t prometheus_exporters`

### MySQL

For monitoring MySQL [prometheus-mysqld-exporter](https://github.com/prometheus/mysqld_exporter) configured to use a separate user for obtaining MySQL statistics.

* Add the host to the `mysql_servers` group
* Rollout exporter on host: `ansible-playbook playbooks/host.yml -t prometheus_exporters`

### Keycloak

For monitoring Keycloak [keycloak-metrics-spi](https://github.com/aerogear/keycloak-metrics-spi) is used, which exports basic Keycloak user events such as logins, errors and registration errors. The exporter is automatically configured when running the keycloak role and it's hardcoded in our prometheus configuration. The prometheus endpoint is protected with basic auth configured in the role and the endpoint is hardcoded in our prometheus configuration.

### Gitlab

Gitlab has a built-in prometheus endpoint available which requires a token to access it which can be found [here](https://gitlab.archlinux.org/admin/health_check). The Gitlab endpoint is hardcoded in our prometheus configuration.

### Gitlab runners

Gitlab runners export a [prometheus endpoint](https://docs.gitlab.com/runner/monitoring/), adding them to monitoring:

* Add the host to the `gitlab_runners` group
* Rollout exporter on host: `ansible-playbook playbooks/host.yml -t prometheus_exporters`

### Network monitoring

For http(s)/icmp monitoring [prometheus-black-exporter](https://github.com/prometheus/blackbox_exporter) is used, which currently has alerts configured for https and SSL certificate expiry monitoring. The web endpoints to monitor are configured in `roles/prometheus/defaults/main.yml`.


### Archive monitoring

The [Archive](https://archive.archlinux.org) and its mirrors defined in `archive_mirrors` are monitored using a textcollector which monitors the archive size in bytes.

### Log monitoring

The Nginx access logs/systemd logs are indexed by loki. For non webserver hosts the `promtail` job, for hosts with nginx an extra access_log line needs to be added to log json output which can be scraped by promtail.

### AUR monitoring

Some fun statistics are scraped from aur.archlinux.org using `curl` and `hq` as there is no proper AUR prometheus endpoint as of yet. The statistics are the AUR packages and users and is retrieved every 5 minutes.

### Smart

TODO:
