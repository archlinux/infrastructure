# About the maintenance role

The maintenance role is a generic role that contains a maintenance nginx configuration
and a html file that is used for the 503 return.

It can be plugged into any role that has a web service that uses nginx. Also, if the role
has any alternate domains, they can also be passed to the maintenance mode and all of them
will be redirecting to the main domain in maintenance mode.

This mode works only while there is a `maintenance` variable defined. To prevent accidents,
the variable must be explicitly defined on the command line when running a playbook with the
-e command flag.

# Adding the maintenance role to another role

This role plugs into another role in two points. The first being the actual role configuration
using ansible's include_role module. The second point is where the role receiving the maintenance
mode configures nginx. There are a few examples of roles that can be used, like archweb and archwiki.

The basic configuration looks like this:

```
- name: run maintenance mode
  include_role:
    name: maintenance
  vars:
    service_name: "<service name>"
    service_domain: "{{ service_domain }}"
    service_alternate_domains: []
    service_nginx_conf: "{{ service_nginx_conf }}"
  when: maintenance is defined
```

This is best placed at the top of the tasks main file for the role, to make sure it is ran first.
Replace <service_name> with the name of the web service. The nginx configuration is best to be set
as a variable, to make sure the right file is used.

```
- name: set up nginx
  template: src=nginx.d.conf.j2 dest="{{ service_nginx_conf }}" owner=root group=root mode=644
  notify:
    - reload nginx
  when: maintenance is not defined
  tags: ['nginx']
```

This causes the regular nginx configuration to only be applied when there is no maintenance variable
on the command line.
