# IPMI

One of our servers has IPMI access, to use it install ipmitool and active an
IPMI remote shell with:

impitool -C3 -I lanplus -H $ip -U $username -P $password sol active
