#!/bin/bash

# ==== Einstellungen ====
PASSWORD="dein-sicheres-passwort"
DOMAIN="deine-subdomain.duckdns.org"

# ==== Code-Server installieren ====
echo "==> Code-Server wird installiert..."
curl -fsSL https://code-server.dev/install.sh | sh

echo "==> Code-Server systemd-Service einrichten..."
sudo tee /lib/systemd/system/code-server.service > /dev/null <<EOL
[Unit]
Description=Code Server
After=network.target

[Service]
Type=simple
Environment=PASSWORD=$PASSWORD
ExecStart=/usr/bin/code-server --bind-addr 0.0.0.0:8080 --disable-telemetry --user-data-dir /home/pi/.local/share/code-server
User=pi
Restart=always

[Install]
WantedBy=multi-user.target
EOL

sudo systemctl daemon-reload
sudo systemctl enable code-server
sudo systemctl restart code-server

# ==== Caddy installieren ====
echo "==> Caddy wird installiert..."
sudo apt update
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https curl

curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/caddy-stable-archive-keyring.gpg] \
https://dl.cloudsmith.io/public/caddy/stable/deb/debian all main" | sudo tee /etc/apt/sources.list.d/caddy-stable.list

sudo apt update
sudo apt install -y caddy

# ==== Caddyfile erstellen ====
echo "==> Caddyfile wird eingerichtet..."
sudo tee /etc/caddy/Caddyfile > /dev/null <<EOL
$DOMAIN {
    reverse_proxy 127.0.0.1:8080
}
EOL

sudo systemctl daemon-reload
sudo systemctl enable caddy
sudo systemctl restart caddy

# ==== Fertig ====
echo ""
echo "===================================="
echo "🚀 Installation abgeschlossen!"
echo ""
echo "👉 Code-Server erreichbar unter: https://$DOMAIN"
echo "Benutzername: coder"
echo "Passwort: $PASSWORD"
echo "===================================="
