[[
title: Diode Documentation
author: PLUG
description: Documentation for configuration on Diode
]]

# LXC
## Command Examples
Create new container

    sudo lxc-create -n plug -t fedora -B btrfs
    sudo vi /etc/lxc/dnsmasq.conf # see config examples
    
List existing containers

    sudo lxc-ls -f
    
Attach existing container

    sudo lxc-attach -n plug
    
## Config Examples
**/etc/lxc/lxc.conf** - set path for containers to be stored (default /var/lib/lxc)

    lxc.lxcpath = "/lxc"

**/etc/lxc/default.conf** - config options for all newly created containers to inherit

    lxc.network.type = veth
    lxc.network.link = lxcbr0
    lxc.network.flags = up
    lxc.network.hwaddr = 00:16:3e:xx:xx:xx
    lxc.start.auto = 1

    # address
    #lxc.network.ipv4 = 192.168.1.1xx
    lxc.network.ipv4.gateway = 192.168.1.1

    # memory
    lxc.cgroup.memory.limit_in_bytes = 512M

    # memory + swap
    lxc.cgroup.memory.memsw.limit_in_bytes = 1G

**/etc/default/lxc-net** - it may be necessary to add /etc/lxc/dnsasq.conf to the apparmor profile (/etc/apparmor.d/*dnsmasq*) with read privileges

    USE_LXC_BRIDGE="true"
    LXC_BRIDGE="lxcbr0"
    LXC_ADDR="192.168.1.1"
    LXC_NETMASK="255.255.255.0"
    LXC_NETWORK="192.168.1.0/24"
    LXC_DHCP_RANGE="192.168.1.100,192.168.1.199"
    LXC_DHCP_MAX="100"
    LXC_DHCP_CONFILE="/etc/lxc/dnsmasq.conf"
    LXC_DOMAIN=""

**/etc/lxc/dnsmasq.conf**

    dhcp-host=evan,192.168.1.102
    dhcp-option=6,128.46.154.76,8.8.4.4

**iptables config**

    #!/bin/bash
    ## Evan Widloski - 2016-11-11
    # Diode iptables rules

    # filter table: flush all chains, and delete all user added chains
    iptables -F
    iptables -X
    # nat table: flush all chains, and delete all user added chains
    iptables -t nat -F
    iptables -t nat -X

    # set default policies to DROP packets
    iptables -P INPUT DROP
    iptables -P OUTPUT DROP
    iptables -P FORWARD DROP

    # allow inbound outbound traffic on host 
    iptables -A OUTPUT -o enp6s0f0 -d 0.0.0.0/0 -j ACCEPT 
    iptables -A INPUT -i enp6s0f0 -m state --state ESTABLISHED,RELATED -j ACCEPT

    # set up chain for sshguard
    iptables -N sshguard
    iptables -A INPUT -p tcp --dport 22 -j sshguard

    # allow ssh
    iptables -A INPUT -i enp6s0f0 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
    iptables -A OUTPUT -o enp6s0f0 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT

    # allow mosh
    iptables -A INPUT -i enp6s0f0 -p udp --dport 60000:61000 -j ACCEPT
    iptables -A OUTPUT -o enp6s0f0 -p udp --sport 60000:61000 -j ACCEPT

    # allow connections to varnish service
    #iptables -A INPUT -i enp6s0f0 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
    #iptables -A OUTPUT -o enp6s0f0 -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT

    # allow host to access LXC targets via network
    iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    iptables -A OUTPUT -s 192.168.1.0/24 -j ACCEPT

    # allow outbound traffic for lxc containers
    iptables -A FORWARD -i lxcbr0 -j ACCEPT
    iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -j MASQUERADE

    # after incoming packets have been NAT'ed (see below), allow them to pass through
    # the forward chain to their intended LXC target
    iptables -A FORWARD -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

    ##------------ evan --------------
    ## ssh
    iptables -t nat -A PREROUTING -p tcp --dport 20022 -j DNAT --to-destination 192.168.1.102:22

