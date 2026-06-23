#!/bin/bash
set -e

echo "GTX Nodes Full Auto Panel Installer"

bash <(curl -s https://pterodactyl-installer.se) <<EOF
0
ostwalarinjay1@gmail.com
Arinjay01
Arinjay
Ostwal
Arinjay@001
Asia/Kolkata
panel.gtxnodes.xyz
n
y
y
y
EOF

echo "Done. Open: https://panel.gtxnodes.xyz"
