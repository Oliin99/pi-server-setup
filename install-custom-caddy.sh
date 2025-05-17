#!/bin/bash

# Installiere Go falls nicht vorhanden
if ! command -v go &> /dev/null
then
    echo "Go wird installiert..."
    sudo apt update
    sudo apt install -y golang
fi

# Verzeichnisse anlegen
mkdir -p ~/caddy-build
cd ~/caddy-build

# Caddy-Quellpaket mit xcaddy holen
echo "xcaddy wird installiert..."
go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest
export PATH=$PATH:$(go env GOPATH)/bin

# Custom Caddy mit DuckDNS bauen
echo "Caddy wird mit DuckDNS Plugin gebaut..."
xcaddy build --with github.com/caddy-dns/duckdns

# Backup der alten Caddy-Binary
if [ -f /usr/bin/caddy ]; then
    echo "Backup der alten Caddy-Binary..."
    sudo mv /usr/bin/caddy /usr/bin/caddy.bak
fi

# Neue Caddy-Binary verschieben
sudo mv caddy /usr/bin/caddy
sudo chmod +x /usr/bin/caddy

# Dienst neustarten
echo "Caddy-Dienst wird neugestartet..."
sudo systemctl restart caddy

# Version check
caddy version
caddy list-modules | grep duckdns

echo "✅ Custom-Caddy mit DuckDNS installiert."
