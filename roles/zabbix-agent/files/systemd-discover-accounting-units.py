#!/usr/bin/python

import dbus
import json

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

for u in units:
    unit_properties = dbus.Interface(bus.get_object('org.freedesktop.systemd1', u[6]), dbus_interface='org.freedesktop.DBus.Properties')
    if get_unit_prop(unit_properties, "CPUAccounting") or get_unit_prop(unit_properties, "MemoryAccounting"):
        discovered.append({"{#UNITNAME}": u[0].replace("@", "--AT--")})

print(json.dumps({"data": discovered}));
