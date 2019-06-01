#!/usr/bin/python

import dbus


ignore = set(["syncrepo.service", "syncrepo_arch32.service"])

bus = dbus.SystemBus()
systemd1 = bus.get_object("org.freedesktop.systemd1", "/org/freedesktop/systemd1")
systemd1_manager = dbus.Interface(
    systemd1, dbus_interface="org.freedesktop.systemd1.Manager"
)

units = systemd1_manager.ListUnits()
for unit in filter(
    lambda u: u[3] == "failed"
    and u[0] not in ignore
    and not u[0].startswith("user@")
    and not u[0].startswith("user-runtime-dir@")
    and not u[0] == "archive-uploader.service",
    units,
):
    print(unit[0])
