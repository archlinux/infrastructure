# Installing new servers

All systems are set up the same way. For the first time setup in the Hetzner
rescue system, run the provisioning script:

```
ansible-playbook playbooks/tasks/install_arch.yml -l $host
```

The provisioning script configures a sane basic `systemd` with `sshd`. By
design, it is NOT idempotent. After the provisioning script has run, it is safe
to reboot.

Once in the new system, run the regular playbook:

```
ansible-playbook playbooks/$hostname.yml`
```

This playbook is the one regularity used for administrating the server and
should be entirely idempotent.

When adding a new machine you should also deploy our SSH `known_hosts` file and
update the SSH hostkeys file in this git repo. For this you can simply run the
`playbooks/tasks/sync-ssh-hostkeys.yml` playbook and commit the changes it
makes to this git repository. It will also deploy any new SSH host keys to all
our machines.

## Note about packer

We use packer to build snapshots on hcloud to use as server base images.
In order to use this, you need to install packer and then run

```
packer build -var $(misc/get_key.py misc/vaults/vault_hetzner.yml hetzner_cloud_api_key --format env) packer/archlinux.pkr.hcl
```

This will take some time after which a new snapshot will have been created on
the primary hcloud archlinux project.

For the sandbox project please run

```
packer build -var $(misc/get_key.py misc/vaults/vault_hetzner.yml hetzner_cloud_sandbox_infrastructure_api_key --format env | sed 's/_sandbox_infrastructure//') -var install_ec2_public_keys_service=true packer/archlinux.pkr.hcl
```
