#!/bin/bash

echo "================================="
echo "GTX Nodes Installer"
echo "================================="

EMAIL="ostwalarinjay1@gmail.com"
USERNAME="Arinjay01"
FIRSTNAME="Arinjay"
LASTNAME="Ostwal"
FQDN="panel.gtxnodes.xyz"

echo "Installing Pterodactyl Panel..."

bash <(curl -s https://pterodactyl-installer.se)

echo "================================="
echo "Installation Finished"
echo "Domain: $FQDN"
echo "Email: $EMAIL"
echo "Username: $USERNAME"
echo "================================="
