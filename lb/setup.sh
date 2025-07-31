#!/bin/bash

echo "[INFO] Starting startup setup on lb-01..."

# updating the system and installing haproxy
sudo apt update && sudo apt install -y haproxy

#installing nano for later use

sudo apt install -y nano
echo "[END] Startup setup completed on lb-01."
echo "nano Installed ✔️ "
echo "haproxy installed ✔️"
echo "Go to /etc/haproxy/haproxy.cfg and configure according "


