#!/bin/bash
set -e

export email="ostwalarinjay1@gmail.com"
export user_email="ostwalarinjay1@gmail.com"
export user_username="Arinjay01"
export user_firstname="Arinjay"
export user_lastname="Ostwal"
export user_password="Arinjay@001"

export FQDN="panel.gtxnodes.xyz"
export timezone="Asia/Kolkata"
export CONFIGURE_LETSENCRYPT="true"
export CONFIGURE_FIREWALL="true"

curl -sSL https://raw.githubusercontent.com/pterodactyl-installer/pterodactyl-installer/master/install.sh | bash -s -- 0
