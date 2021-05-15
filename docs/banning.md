# Banning IP Addresses for abuse

```
firewall-cmd --add-rich-rule="rule family='ipv4' source address='1.1.1.1' reject"
```

```
firewall-cmd --add-rich-rule="rule family='ipv6' source address='1:2:3:4:6::' reject"
```

Note that on Gitlab, you must block the ip address for the docker zone:

```
firewall-cmd --add-rich-rule="rule family='ipv4' source address='1.1.1.1' reject" --zone=docker
```

To see the bans/rules:

```
firewall-cmd --list-all
```

To remove a banned IP Address:

```
firewall-cmd --remove-rich-rule='rule family="ipv6" source address="1:2:3:4:6::" reject'
```
