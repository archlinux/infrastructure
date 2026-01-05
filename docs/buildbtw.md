# buildbtw

The [buildbtw build service](https://gitlab.archlinux.org/archlinux/buildbtw) is deployed to three hosts:

- buildbtw.dev.archlinux.org (dynamically created development instances for [GitLab Review Apps](https://docs.gitlab.com/ci/review_apps/))
- buildbtw.staging.archlinux.org (staging instance which is deployed from images of the `main` branch)
- buildbtw.archlinux.org (production instance from tagged point versions like `v1.2.3`)

A single Ansible playbook deploys all hosts.

## Dynamic Deployments

We use [webhook](https://github.com/adnanh/webhook) in order to receive calls from GitLab CI to deploy/undeploy a branch.
This way, we can (re)deploy instances dynamically via HTTP calls.

For debugging, it might come in handy to call this manually.
For instance, you could redeploy the main branch like this:

```
curl -H "Authorization: Bearer $(misc/get_key.py group_vars/all/vault_buildbtw.yml vault_buildbtw_staging_deploy_token)" "https://buildbtw.staging.archlinux.org/hooks/deploy-branch?branch=main"
```

To manually undeploy a dev instance, you could do this:

```
curl -H "Authorization: Bearer $(misc/get_key.py group_vars/all/vault_buildbtw.yml vault_buildbtw_dev_deploy_token)" "https://buildbtw.dev.archlinux.org/hooks/deploy-branch?branch=my-old-instance"
```

## Static Deployments

Our production instance is managed and deployed manually by devops. It is not deployable from CI.
To bump its version, change `buildbtw_image_tag` in `host_vars/buildbtw.archlinux.org/misc.yml` and then run

```
ansible-playbook playbooks/buildbtw.yml -l buildbtw.dev.archlinux.org -t buildbtw
```

## Systemd Management

We use [systemd container units](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html) in rootful mode.
We use the container units for better integration with systemd.

User-mode was considered for security reasons.
However, it would have meant that we would have had to use systemd in user-mode since `User=` is [not supported by systemd for containers](https://github.com/containers/podman/discussions/20573#discussion-5806869).
Using user-mode for system services results in undesireable ergonomics (or lack thereof).
For example: `systemctl --user -M buildbtw@ status buildbtw` (and even then the logs are missing) and `journalctl _UID=$(id -u buildbtw) -a`.
As such, we use rootful mode.
Since this is a single purpose machine and podman uses namespace isolation, it should still be reasonably safe to do so.
