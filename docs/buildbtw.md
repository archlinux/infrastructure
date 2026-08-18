# buildbtw

The [buildbtw build service](https://gitlab.archlinux.org/archlinux/buildbtw) is deployed to three hosts:

- buildbtw.archlinux.review (dynamically created development instances for [GitLab Review Apps](https://docs.gitlab.com/ci/review_apps/))
- buildbtw.archlinux.builders (staging instance which is deployed from images of the `main` branch)
- buildbtw.archlinux.org (production instance from tagged point versions like `v1.2.3`)

A single Ansible playbook deploys all hosts.

## Dynamic Deployments

We use [webhook](https://github.com/adnanh/webhook) in order to receive calls from GitLab CI to deploy/undeploy a branch.
This way, we can (re)deploy instances dynamically via HTTP calls.

For debugging, it might come in handy to call this manually.
For instance, you could redeploy the main branch like this:

```
curl -H "Authorization: Bearer $(misc/get_key.py host_vars/buildbtw.archlinux.builders/vault_buildbtw_staging.yml vault_buildbtw_deploy_token)" "https://buildbtw.archlinux.builders/hooks/deploy-branch?branch=main"
```

To manually deploy a review instance, you could do this:

```
curl -H "Authorization: Bearer $(misc/get_key.py host_vars/buildbtw.archlinux.review/vault_buildbtw_review.yml vault_buildbtw_deploy_token)" "https://buildbtw.archlinux.review/hooks/deploy-branch?branch=my-old-instance"
```

## Static Deployments

Our production instance is managed and deployed manually by devops. It is not deployable from CI.
To bump its version, change `buildbtw_image_tag` in `host_vars/buildbtw.archlinux.org/misc.yml` and then run

```
ansible-playbook playbooks/buildbtw.yml -l buildbtw.archlinux.org -t buildbtw
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

## Service Users

We have one service user per instance:

- `buildbtw-review` (user id: `8450`)
- `buildbtw-staging` (user id: `8451`)
- `buildbtw` (user id: `8449`)

We expect each of these users to have an SSH key added to them so that we can use the SSH key in buildbtw to authenticate against the repositories.
However, since they are service accounts, it's currently not possible to add SSH keys to them in the GitLab UI.
You can use this convenient curl to add public keys to them:
```
curl -X POST -H "Content-Type: application/json" -H "PRIVATE-TOKEN:<a PAT with global SSH creation powers>" --data '{"title":"buildbtw-review", "key":"ssh-ed25519 <SSH public key data>"}' https://gitlab.archlinux.org/api/v4/users/<user id>/keys
```
The SSH private key data is inside encrypted vaults, and is mounted into the buildbtw server containers. Respectively:

- host_vars/buildbtw.archlinux.review/vault_buildbtw_review.yml
- host_vars/buildbtw.archlinux.builders/vault_buildbtw_staging.yml
- host_vars/buildbtw.archlinux.org/vault_buildbtw_production.yml
