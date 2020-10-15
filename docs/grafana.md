# Grafana

Our Grafana is hosted on https://monitoring.archlinux.org and is accessible for
all Arch Linux Staff, editing rights are restricted to users with the Devops
Role.

Dashboards and datasources are automatically provisioned by Grafana with Grafana's build in [provisioning configuration](https://grafana.com/docs/grafana/latest/administration/provisioning/).

## Adding a new Dashboard

A new dashboard can be configured in our Grafana instance to try it out and if satisfactory checked in to Git as following:

* Export the dashboard to json (top left, share dashboard => exporter => save to file).
* Save the json file in `roles/grafana/files/dashboards'
* Git add the file and run the grafana playbook
