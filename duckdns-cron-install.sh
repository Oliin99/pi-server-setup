#!/bin/bash

echo "=== DuckDNS Updater (cron) Installer ==="

read -p "Enter your DuckDNS token: " token
read -p "Enter your DuckDNS subdomain (without .duckdns.org): " subdomain

mkdir -p ~/duckdns
cd ~/duckdns || exit

cat > duck.sh <<EOF
echo url="https://www.duckdns.org/update?domains=${subdomain}&token=${token}&ip=" | curl -k -o ~/duckdns/duck.log -K -
EOF

chmod 700 duck.sh

(crontab -l 2>/dev/null; echo "*/5 * * * * ~/duckdns/duck.sh >/dev/null 2>&1") | crontab -

echo "✅ DuckDNS updater installed with cron!"
echo "📄 Log file: ~/duckdns/duck.log"
