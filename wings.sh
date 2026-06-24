#!/bin/bash
set -e

echo "================================="
echo "GTX Nodes Wings Auto Installer"
echo "HTTPS Request: false"
echo "Firewall: false"
echo "================================="

apt update && apt upgrade -y
apt install -y curl tar unzip ca-certificates gnupg lsb-release

curl -sSL https://get.docker.com | sh
systemctl enable --now docker

mkdir -p /etc/pterodactyl

curl -L -o /usr/local/bin/wings https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_amd64
chmod +x /usr/local/bin/wings

cat > /etc/systemd/system/wings.service <<EOF
[Unit]
Description=Pterodactyl Wings Daemon
After=docker.service
Requires=docker.service

[Service]
User=root
WorkingDirectory=/etc/pterodactyl
LimitNOFILE=4096
PIDFile=/var/run/wings/daemon.pid
ExecStart=/usr/local/bin/wings
Restart=on-failure
StartLimitInterval=180
StartLimitBurst=30
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable wings

echo "================================="
echo "Wings Installed Successfully"
echo "Now go to Panel Admin → Nodes → your node → Configuration"
echo "Copy the config.yml and paste it here:"
echo "/etc/pterodactyl/config.yml"
echo ""
echo "Command to paste config:"
echo "nano /etc/pterodactyl/config.yml"
echo ""
echo "After saving config, start wings:"
echo "systemctl restart wings"
echo "systemctl status wings --no-pager -l"
echo "================================="
