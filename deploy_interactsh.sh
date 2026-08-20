#!/bin/bash
# deploy_interactsh.sh — Auto-setup Interactsh di Codespaces (port 53 DNS listener)
# Dipanggil dari devcontainer postStartCommand -> VPS auto jalan saat start
set -e
echo "[*] Install Go + Interactsh..."
sudo apt-get update -qq
sudo apt-get install -y -qq golang-go git curl 2>/dev/null || apt-get install -y -qq golang git curl
export PATH=$PATH:/usr/local/go/bin:/home/codespace/go/bin
export GOPATH=/home/codespace/go
# Clone + build
rm -rf /home/codespace/interactsh
git clone https://github.com/projectdiscovery/interactsh.git /home/codespace/interactsh 2>&1 | tail -1
cd /home/codespace/interactsh
go build ./cmd/interactsh-server/ 2>&1 | tail -2 || echo "build warn"
# Run server (self-host, DNS di 53)
nohup ./interactsh-server -domain $(curl -s https://api.ipify.org).nip.io -listen-ip 0.0.0.0 > /home/codespace/interactsh.log 2>&1 &
echo "[+] Interactsh starting on port 53 (DNS)..."
sleep 5
ss -tlnp | grep -E ":53|:80" && echo "INTERACTSH UP" || echo "check log"
