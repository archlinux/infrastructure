# Banning IP Addresses for abuse

For banning with an expiry `fail2ban` can be used, the expiry time depends on the configured fail2ban jail:

```
fail2ban-client set sshd banip 1.1.1.1
```

To permanently ban an IP address `firewall-cmd` can be used as shown below:

```
firewall-cmd --add-rich-rule="rule family='ipv4' source address='1.1.1.1' reject" --zone=public
```

```
firewall-cmd --add-rich-rule="rule family='ipv6' source address='1:2:3:4:6::' reject" --zone=public
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
firewall-cmd --remove-rich-rule='rule family="ipv6" source address="1:2:3:4:6::" reject' --zone=public
```
