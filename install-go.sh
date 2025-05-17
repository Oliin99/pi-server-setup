#!/bin/bash

# Aktuelle Go-Version
GO_VERSION="1.22.4"

# Download und Install
wget https://go.dev/dl/go${GO_VERSION}.linux-arm64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-arm64.tar.gz

# Go-Pfad setzen
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
export PATH=$PATH:/usr/local/go/bin

# Prüfen
go version
