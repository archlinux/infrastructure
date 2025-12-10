# Grafana

Our Grafana is hosted on https://monitoring.archlinux.org and is accessible only to DevOps Staff.

A public accessible instance is hosted on https://dashboards.archlinux.org with selected metrics using prometheus "remote write" feature.

Dashboards and datasources are automatically provisioned by Grafana with Grafana's built-in [provisioning configuration](https://grafana.com/docs/grafana/latest/administration/provisioning/).

## Adding a new Dashboard

A new dashboard can be configured in our Grafana instance to try it out and if satisfactory checked in to Git as following:

* Export the dashboard to json (top right, Export => Export as code => Download file).
* Save the json file in `roles/grafana/files/dashboards`.
* Git add the file and run `ansible-playbook playbooks/monitoring.archlinux.org.yml -t grafana`.

## Adding new metrics to dashboards.archlinux.org

Metrics can be added to the public grafana instance if they are already collected on `monitoring.archlinux.org`:

* Verify that the metrics are allowed to be made public and check with another DevOps member.
* Create a symlink in `roles/grafana/files/public-dashboards` to the dashboard in `roles/grafana/files/dashboards`.
* Edit `roles/prometheus/defaults/main.yml` and extend the `prometheus_remote_write_relabel_configs` block with the job name matching the prometheus config from `roles/prometheus/templates/prometheus.yml.j2`.
* Run `ansible-playbook playboks/monitoring.archlinux.org.yml -t prometheus` to update the `remote_write` configuration.
* Run `ansible-playbook playboks/dashboards.archlinux.org.yml -t grafana` to deploy the dashboard to `dashboards.archlinux.org`.
