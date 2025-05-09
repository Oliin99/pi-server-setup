#!/bin/bash

# Caddy installieren
sudo apt update
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https curl

curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/caddy-stable-archive-keyring.gpg] \
https://dl.cloudsmith.io/public/caddy/stable/deb/debian all main" | sudo tee /etc/apt/sources.list.d/caddy-stable.list

sudo apt update
sudo apt install -y caddy

# Caddyfile erstellen
sudo tee /etc/caddy/Caddyfile > /dev/null <<EOL
deine-subdomain.duckdns.org {
    reverse_proxy 127.0.0.1:8080
}
EOL

# Caddy-Dienst neu laden und starten
sudo systemctl daemon-reload
sudo systemctl enable caddy
sudo systemctl restart caddy

echo "Caddy installiert und läuft mit deiner DuckDNS-Domain!"
echo "Aufrufbar über: https://deine-subdomain.duckdns.org"
