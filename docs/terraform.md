# Terraform

We use terraform in two ways:

1. To provision a part of the infrastructure on hcloud (and possibly other
   service providers in the future)
1. To declaratively configure applications

For both of these, we have set up a separate terraform script. The reason for
that is that sadly terraform can't have providers depend on other providers so
we can't declaratively state that we want to configure software on a server
which itself needs to be provisioned first. Therefore, we use a two-stage
process. Generally speaking, infrastructure is configured in `tf-stage1` and
applications and services are configured in `tf-stage2`. Maybe in the future,
we can just have a single terraform script for everything but for the time
being, this is what we're stuck with.

The very first time you run terraform on your system, you'll have to init it:

```
cd tf-stage1  # and also tf-stage2
terraform init -backend-config="conn_str=postgres://terraform:$(../misc/get_key.py ../group_vars/all/vault_terraform.yml vault_terraform_db_password)@state.archlinux.org?sslmode=verify-full"
```

After making changes to the infrastructure in `tf-stage1/archlinux.tf`, run

```
terraform plan
```

This will show you planned changes between the current infrastructure and the
desired infrastructure.
You can then run

```
terraform apply
```

to actually apply your changes.

The same applies to changed application configuration in which case you'd run
it inside of `tf-stage2` instead of `tf-stage1`.

We store terraform state on a special server that is the only hcloud server NOT
managed by terraform so that we do not run into a chicken-egg problem. The
state server is assumed to just exist so in an unlikely case where we have to
entirely redo this infrastructure, the state server would have to be manually
set up.
