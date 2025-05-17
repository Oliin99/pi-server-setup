#!/bin/bash

# Domain und Token per Parameter oder Eingabe
DOMAIN=$1
TOKEN=$2

if [ -z "$DOMAIN" ]; then
  read -p "Gib deine DuckDNS-Domain ein (ohne .duckdns.org): " DOMAIN
fi

if [ -z "$TOKEN" ]; then
  read -p "Gib deinen DuckDNS-Token ein: " TOKEN
fi

echo "Starte Server-Setup für Domain: $DOMAIN"

# Code-Server installieren (falls nicht vorhanden)
if ! command -v code-server &> /dev/null
then
    echo "Code-Server wird installiert..."
    curl -fsSL https://code-server.dev/install.sh | sh
else
    echo "Code-Server ist bereits installiert."
fi

# Caddy installieren (falls nicht vorhanden)
if ! command -v caddy &> /dev/null
then
    echo "Caddy wird installiert..."
    sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-archive-keyring.gpg
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
    sudo apt update
    sudo apt install -y caddy
else
    echo "Caddy ist bereits installiert."
fi

# Caddyfile anlegen
echo "Erstelle Caddyfile..."
sudo bash -c "cat > /etc/caddy/Caddyfile" <<EOF
$DOMAIN.duckdns.org:8443 {
    reverse_proxy 127.0.0.1:8080
    tls {
      dns duckdns
    }
}
EOF

# Caddy neu starten
echo "Starte Caddy neu..."
sudo systemctl restart caddy

# DuckDNS-Update-Script anlegen
echo "Erstelle DuckDNS-Update-Script..."
mkdir -p ~/duckdns
cat > ~/duckdns/duck.sh <<EOF
echo url="https://www.duckdns.org/update?domains=$DOMAIN&token=$TOKEN&ip=" | curl -k -o ~/duckdns/duck.log -K -
EOF
chmod 700 ~/duckdns/duck.sh

# Cronjob für DuckDNS
(crontab -l 2>/dev/null; echo "*/5 * * * * ~/duckdns/duck.sh >/dev/null 2>&1") | crontab -

echo "Installation abgeschlossen!"
echo "➡ Code-Server: http://DEINE-IP:8080"
echo "➡ oder via https://$DOMAIN.duckdns.org:8443"
