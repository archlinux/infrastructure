#!/usr/bin/python

import dbus

bus = dbus.SystemBus()
systemd1 = bus.get_object('org.freedesktop.systemd1', '/org/freedesktop/systemd1')
systemd1_manager = dbus.Interface(systemd1, dbus_interface='org.freedesktop.systemd1.Manager')

units = systemd1_manager.ListUnits()
for unit in filter(lambda u: u[3] == 'failed', units):
    print(unit[0])
