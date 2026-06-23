#!/bin/bash
set -e

EMAIL="ostwalarinjay1@gmail.com"
USERNAME="Arinjay01"
FIRSTNAME="Arinjay"
LASTNAME="Ostwal"
PASSWORD="Arinjay@001"
FQDN="panel.gtxnodes.xyz"
TIMEZONE="Asia/Kolkata"

curl -Lo /tmp/ptero-installer.sh https://raw.githubusercontent.com/pterodactyl-installer/pterodactyl-installer/master/installers/panel.sh

bash /tmp/ptero-installer.sh \
  --email "$EMAIL" \
  --username "$USERNAME" \
  --firstname "$FIRSTNAME" \
  --lastname "$LASTNAME" \
  --password "$PASSWORD" \
  --fqdn "$FQDN" \
  --timezone "$TIMEZONE" \
  --agree-terms \
  --no-interaction
