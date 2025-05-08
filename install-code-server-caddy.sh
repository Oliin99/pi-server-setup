#!/bin/bash

echo "=== Installing Code-Server and Caddy ==="

# Install Code-Server
curl -fsSL https://code-server.dev/install.sh | sh

# Install Caddy
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update
sudo apt install -y caddy

# Enable Code-Server service
sudo systemctl enable --now code-server@$USER

# Create Caddyfile
sudo bash -c "cat > /etc/caddy/Caddyfile <<EOF
yourdomain.com {
    reverse_proxy 127.0.0.1:8080
}
EOF"

# Restart Caddy
sudo systemctl restart caddy

echo "✅ Code-Server and Caddy installed!"
echo "📝 Update /etc/caddy/Caddyfile with your domain and restart Caddy: sudo systemctl restart caddy"
