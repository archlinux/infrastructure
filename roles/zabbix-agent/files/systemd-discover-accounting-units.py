#!/usr/bin/python

import dbus
import json
import re

# regex are ancored to beginning and end of string already
unit_whitelist_regexes = [
        r'arch-boxes.service',
        r'borg-backup.service',
        r'createlinks.service',
        r'cronie.service',
        r'dovecot.service',
        r'grafana.service',
        r'mariadb.service',
        r'matrix-appservice-irc.service',
        r'nginx.service',
        r'nginx-zabbix.service',
        r'opendkim.service',
        r'php-fpm@flyspray.service',
        r'php-fpm@kanboard.service',
        r'php-fpm@zabbix-web.service',
        r'planet.service',
        r'postfix.service',
        r'postfwd.service',
        r'postgresql.service',
        r'quassel.service',
        r'security-tracker-update.service',
        r'spampd.service',
        r'sshd.service',
        r'svnserve.service',
        r'synapse.service',
        r'system-rsyncd.slice',
        r'unbound.service',
        r'zabbix-agent.service',
        r'zabbix-server-pgsql.service',
        ]

bus = dbus.SystemBus()
systemd1 = bus.get_object('org.freedesktop.systemd1', '/org/freedesktop/systemd1')
systemd1_manager = dbus.Interface(systemd1, dbus_interface='org.freedesktop.systemd1.Manager')

units = systemd1_manager.ListUnits()

discovered = []

def get_unit_prop_interface(obj, interface, propname):
    try:
        return obj.Get(interface, propname)
    except dbus.exceptions.DBusException as err:
        if err.get_dbus_name() == 'org.freedesktop.DBus.Error.UnknownProperty':
            return None
        else:
            raise

def get_unit_prop(obj, propname):
    interfaces = ['org.freedesktop.systemd1.Service', 'org.freedesktop.systemd1.Slice']
    for interface in interfaces:
        ret = get_unit_prop_interface(obj, interface, propname)
        if ret:
            return ret
    return None

combined = '|'.join(unit_whitelist_regexes)
unit_whitelist_compiled = re.compile('^('+combined+')$')

for u in units:
    unit_properties = dbus.Interface(bus.get_object('org.freedesktop.systemd1', u[6]), dbus_interface='org.freedesktop.DBus.Properties')
    if unit_whitelist_compiled.match(u[0]):
        discovered.append({"{#UNITNAME}": u[0].replace("@", "--AT--")})

print(json.dumps({"data": discovered}));
