#!/bin/bash

echo "=== DuckDNS Updater (systemd) Installer ==="

read -p "Enter your DuckDNS token: " token
read -p "Enter your DuckDNS subdomain (without .duckdns.org): " subdomain

sudo mkdir -p /opt/duckdns
cd /opt/duckdns || exit

sudo bash -c "cat > duck.sh <<EOF
#!/bin/bash
echo url=\"https://www.duckdns.org/update?domains=${subdomain}&token=${token}&ip=\" | curl -k -o /opt/duckdns/duck.log -K -
EOF"

sudo chmod 700 /opt/duckdns/duck.sh

sudo bash -c "cat > /etc/systemd/system/duckdns.service <<EOF
[Unit]
Description=DuckDNS Dynamic IP Updater

[Service]
Type=oneshot
ExecStart=/opt/duckdns/duck.sh
EOF"

sudo bash -c "cat > /etc/systemd/system/duckdns.timer <<EOF
[Unit]
Description=Run DuckDNS Updater every 5 minutes

[Timer]
OnBootSec=30
OnUnitActiveSec=5m
Unit=duckdns.service

[Install]
WantedBy=timers.target
EOF"

sudo systemctl daemon-reload
sudo systemctl enable --now duckdns.timer

echo "✅ DuckDNS updater systemd service and timer installed!"
echo "📄 Log via: sudo journalctl -u duckdns.service"
echo "📊 Timer check: sudo systemctl list-timers | grep duckdns"
