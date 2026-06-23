#!/bin/bash

echo "GTX Nodes Auto Installer"

export email="ostwalarinjay1@gmail.com"
export username="Arinjay01"
export firstname="Arinjay"
export lastname="Ostwal"
export password="Arinjay@001"
export FQDN="panel.gtxnodes.xyz"
export timezone="Asia/Kolkata"

bash <(curl -s https://pterodactyl-installer.se)
