# Server maintenance

[[_TOC_]]

## Semi-automated server upgrades

For updating all servers in a mostly unattented manner, the following playbook
can be used:

```
ansible-playbook playbooks/tasks/upgrade-servers.yml [-l SUBSET]
```

It runs `pacman -Syu` on the targeted hosts in batches and then reboots them.
If any server fails to reboot successfully, the rolling update stops and
further batches are cancelled. To display the packages updated on each host,
you can pass the `--diff` option to ansible-playbook.

Using this update method, `.pacnew` files are left unmerged which is OK for
most configuration files that are managed by Ansible. However, care must be
taken with updates that require manual intervention (e.g. major PostgreSQL
releases).

## Finding servers requiring security updates

Arch-audit can be used to find servers in need of updates for security issues.

```
ansible all -a "arch-audit -u"
```

## Updating Gitlab

Our Gitlab installation uses [Omnibus](https://docs.gitlab.com/omnibus/) to run
Gitlab on Docker. Updating Gitlab is as simple as running the ansible gitlab
playbook:

```
ansible-playbook playbooks/gitlab.archlinux.org.yml --diff -t gitlab
```

To view the current Gitlab version visit [this url](https://gitlab.archlinux.org/help/)

## About the maintenance role

The maintenance role is a generic role that contains a maintenance nginx
configuration and a html file that is used for the 503 return.

It can be plugged into any role that has a web service that uses nginx. Also,
if the role has any alternate domains, they can also be passed to the
maintenance mode and all of them will be redirecting to the main domain in
maintenance mode.

This mode works only while there is a `maintenance` variable defined. To
prevent accidents, the variable must be explicitly defined on the command line
when running a playbook with the -e command flag.

### Putting a service in maintenance mode

Most web services with a nginx configuration, can be put into a maintenance
mode, by running the playbook with a maintenance variable:

```
ansible-playbook -e maintenance=true playbooks/<playbook.yml>
```

This also works with a tag:

```
ansible-playbook -t <tag> -e maintenance=true playbooks/<playbook.yml>
```

As long as you pass the maintenance variable to the playbook run, the web
service will stay in maintenance mode. As soon as you stop passing it on the
command line and run the playbook again, the regular nginx configuration should
resume and the service should accept requests by the end of the run.

Passing `maintenance=false`, will also prevent the regular nginx configuration
from resuming, but will not put the service into maintenance mode.

Keep in mind that passing the maintenance variable to the whole playbook,
without any tag, will make all the web services that have the
maintenance mode in them, to be put in maintenance mode. Use tags to affect
only the services you want.

### Adding the maintenance role to another role

This role plugs into another role in two points. The first being the actual
role configuration using ansible's include_role module. The second point is
where the role receiving the maintenance mode configures nginx. There are a few
examples of roles that can be used, like archweb and archwiki.

The basic configuration looks like this:

```
- name: run maintenance mode
  include_role:
    name: maintenance
  vars:
    service_name: "<service name>"
    service_domain: "{{ service_domain }}"
    service_alternate_domains: []
    service_legacy_domains: []
    service_nginx_conf: "{{ service_nginx_conf }}"
  when: maintenance is defined
```

This is best placed at the top of the tasks main file for the role, to make
sure it is ran first. Replace `<service_name>` with the name of the web service.
The nginx configuration is best to be set as a variable, to make sure the right
file is used.

```
- name: set up nginx
  template: src=nginx.d.conf.j2 dest="{{ service_nginx_conf }}" owner=root group=root mode=644
  notify:
    - Reload nginx
  when: maintenance is not defined
  tags: ['nginx']
```

This causes the regular nginx configuration to only be applied when there is no maintenance variable
on the command line.

### Adding a custom maintenance mode nginx template

The maintenance role can also use a custom nginx template, if the
service_nginx_template variable is set alongside the other vars when including
the maintenance role, it will look up first on the maintenance role template
directory and then on the calling role template directory for the specified
template.

Since this is a completely custom file, it is the job of this file of putting
the service into maintenance mode. The maintenance role will provide the 503
file and create the directories.
