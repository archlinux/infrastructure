## Rebuilderd

We host a [Rebuilderd](https://github.com/kpcyrd/rebuilderd) instance on reproducible.archlinux.org which rebuilds Arch packages from repositories defined in `rebuilderd-sync.conf`. Workers automatically connect to the configured rebuilderd instance and query it for work and publish results to the rebuilderd instance.

Results are shown on [our website](https://reproducible.archlinux.org) which is a [rebuilderd-website](https://gitlab.archlinux.org/archlinux/rebuilderd-website) instance.

## Configuration

Setting up rebuilderd-workers requires adding the `rebuilderd_worker` role to the playbook and adding `rebuilderd_workers` a list with rebuilderd-worker names for example:

```
rebuilderd_workers:
 - repro11
 - repro12
```

## Monitoring

The rebuilderd workers and queue are monitored by Prometheus.

## Common commands

Checking rebuilderd-workers status on reproducible.archlinux.org:

```
rebuildctl status
```

Checking rebuilderd queue length:

```
rebuildctl queue ls
```
