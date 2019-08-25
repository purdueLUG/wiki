[[
title: Wifi Tutorial
description: How to Connect to PAL3.0
tags: [wifi, tutorial]
]]

# Connect with Network Manager

## GUI connection editor (nm-connection-editor)

Click on the wireless icon in your tray area. Select "Connect to Hidden Wi-Fi Network" or choose PAL3.0 and enter these settings.

    Network Name: "PAL3.0"

    Wireless Security: WPA & WPA2 Enterprise

    Authentication: Protected EAP (PEAP)

    Key Type (if present): TKIP

    Phase2 Type / Inner Authentication: MSCHAPV2

    Identity / Username: Your Purdue Login

    Password: Your Purdue Password

    Anonymous Identity: (leave blank)

    Client Certificate File (if present): (None)

    CA Certificate File: /etc/ssl/certs/AddTrust_External_Root.pem or /etc/ssl/certs/AddTrust_External_CA_Root.pem

    Private Key File: (None)

    Private Key Password: (leave blank)

    'PEAP' version: choose 'Version 0'.

![image](PAL3example.png)

Click save.

## nmcli + nmtui

nmtui does not currently support configuring WPA2-Enterprise connections. As such, we can configure the connection with nmcli and activate it with nmtui.

```
nmcli --ask connection add type wifi con-name "PAL3.0" ifname yourinterfacehere ssid "PAL3.0" -- wifi-sec.key-mgmt wpa-eap 802-1x.eap ttls 802-1x.phase2-auth mschapv2 802-1x.identity "Your Purdue Login"
```

Now you can open nmtui and activate the connection. You will be prompted for your password after attempting to connect.

# Connect with netctl

These instructions will allow you to connect to PAL3.0 using netctl, the default network manager in Arch Linux

Edit the file /etc/netctl/PAL3 to resemble the following (fill in your own information for interface, identity, and password)

    Description='PAL3.0-profile'

     Interface=wlan0

     Connection=wireless

     Security=wpa-configsection

     IP=dhcp

     WPAConfigSection=(

      'ssid="PAL3.0"'

      'proto=RSN WPA'

      'key_mgmt=WPA-EAP'

      'auth_alg=OPEN'

      'eap=PEAP'

      'identity="username"'

      'password="password"'
     )

After doing this, you should be able to connect to PAL by running netctl switch-to PAL3
