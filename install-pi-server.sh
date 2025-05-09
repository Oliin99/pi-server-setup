#!/bin/bash

echo "🔧 Starte Server-Setup für Raspberry Pi..."

# Passwort für Code-Server abfragen
read -sp "🔒 Bitte Passwort für Code-Server festlegen: " cs_password
echo
# Domain abfragen
read -p "🌐 Deine DuckDNS-Domain (z.B. meinserver.duckdns.org): " domain

# Code-Server installieren
echo "📦 Installiere Code-Server..."
curl -fsSL https://code-server.dev/install.sh | sh

# Systemd Service für Code-Server erstellen
echo "📝 Erstelle Code-Server Service..."
sudo tee /lib/systemd/system/code-server.service > /dev/null <<EOL
[Unit]
Description=Code Server
After=network.target

[Service]
Type=simple
Environment=PASSWORD=$cs_password
ExecStart=/usr/bin/code-server --bind-addr 0.0.0.0:8080 --disable-telemetry --user-data-dir /home/pi/.local/share/code-server
User=pi
Restart=always

[Install]
WantedBy=multi-user.target
EOL

sudo systemctl daemon-reload
sudo systemctl enable code-server
sudo systemctl restart code-server

# Caddy installieren
echo "📦 Installiere Caddy..."
sudo apt update
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https curl

curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/caddy-stable-archive-keyring.gpg] \
https://dl.cloudsmith.io/public/caddy/stable/deb/debian all main" | sudo tee /etc/apt/sources.list.d/caddy-stable.list

sudo apt update
sudo apt install -y caddy

# Caddyfile erstellen
echo "📝 Erstelle Caddyfile..."
sudo tee /etc/caddy/Caddyfile > /dev/null <<EOL
$domain {
    reverse_proxy 127.0.0.1:8080
}
EOL

sudo systemctl restart caddy

echo "✅ Setup abgeschlossen!"
echo "➡️  Code-Server erreichbar unter: https://$domain"
echo "➡️  Benutzername: coder"
echo "➡️  Passwort: $cs_password"
