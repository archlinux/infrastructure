# WireGuard

Many of our servers communicate through wireguard VPN with each others. If you need to collect logs with `loki` and metrics with `prometheus` for dashboards you need to have a wiregauard IP.

## Setting up
1. For a new server add a new unused wireguard IP and set the following in `host_vars/<fqdn>/misc`
    ```
    wireguard_address: <wg-ip>
    wireguard_public_key: <wg-pubkey>
    ```

1. Generate the private key on the server with `wg genkey | systemd-creds encrypt - /etc/credstore.encrypted/network.wireguard.private.wg0` and restart systemd-networkd with `systemctl restart systemd-networkd`

    Tips: 
    - Pick next available IP for Wireguard from `grep -r wireguard_address host_vars/ | cut -f3 -d: | sort -h`

    - Wireguard key generation docs: https://www.wireguard.com/quickstart/#key-generation 
1. Execute `wireguard` and `prometheus` roles on `monitoring.archlinux.org.yml` playbook to get data from the server
