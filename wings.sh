#!/bin/bash
set -e

echo "GTX Nodes Wings Installer"

read -p "Enter Panel URL (example: http://panel.example.com): " PANEL_URL
read -p "Enter Node FQDN/IP: " NODE_FQDN

curl -sSL https://get.docker.com | sh

mkdir -p /etc/pterodactyl

curl -L https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_amd64 
-o /usr/local/bin/wings

chmod +x /usr/local/bin/wings

echo "================================="
echo "Wings Installed"
echo "Panel URL: $PANEL_URL"
echo "Node: $NODE_FQDN"
echo "HTTPS Request: false"
echo "Firewall Config: false"
echo "================================="
echo ""
echo "Now create a node in the panel and paste the generated config.yml into:"
echo "/etc/pterodactyl/config.yml"
echo ""
echo "Then run:"
echo "systemctl enable --now wings"
