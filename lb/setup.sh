#!/bin/bash

# ─── Step 2: Install haproxy and nano ────────────────────────────
echo "[INFO] Installing HAProxy and nano..."
sudo apt update -y
sudo apt install -y haproxy nano

# ─── Step 3: Configure haproxy.cfg ───────────────────────────────
HAPROXY_CFG="/etc/haproxy/haproxy.cfg"

echo "[INFO] Checking and configuring HAProxy..."

# Ensure global section exists
if ! grep -q "^\s*global" "$HAPROXY_CFG"; then
  echo -e "\nglobal\n    daemon\n    maxconn 256" | sudo tee -a "$HAPROXY_CFG" > /dev/null
  echo "  ➤ Added [global] section with default values."
else
  echo "  ➤ [global] section already exists."

  # Add daemon if missing
  if ! grep -qE "^\s*daemon" "$HAPROXY_CFG"; then
    sudo sed -i '/^\s*global/a\    daemon' "$HAPROXY_CFG"
    echo "    ➤ Inserted 'daemon' into [global]."
  else
    echo "    ➤ 'daemon' already present in [global]."
  fi

  # Add maxconn if missing
  if ! grep -qE "^\s*maxconn\s+256" "$HAPROXY_CFG"; then
    sudo sed -i '/^\s*global/a\    maxconn 256' "$HAPROXY_CFG"
    echo "    ➤ Inserted 'maxconn 256' into [global]."
  else
    echo "    ➤ 'maxconn 256' already present in [global]."
  fi
fi

# Add frontend section if not present
if ! grep -q "^\s*frontend http-in" "$HAPROXY_CFG"; then
  echo -e "\nfrontend http-in\n    bind *:80\n    default_backend servers" | sudo tee -a "$HAPROXY_CFG" > /dev/null
  echo "  ➤ Added [frontend] section."
else
  echo "  ➤ [frontend] section already exists."
fi

# Add backend section if not present
if ! grep -q "^\s*backend servers" "$HAPROXY_CFG"; then
  echo -e "\nbackend servers\n    balance roundrobin\n    server web01 172.20.0.11:80 check\n    server web02 172.20.0.12:80 check\n    http-response set-header X-Served-By %[srv_name]" | sudo tee -a "$HAPROXY_CFG" > /dev/null
  echo "  ➤ Added [backend] section."
else
  echo "  ➤ [backend] section already exists."
fi

# ─── Final Messages ──────────────────────────────────────────────
echo "[SUCCESS] Startup setup completed on lb-01."
echo "nano Installed ✔️"
echo "haproxy Installed ✔️"
echo "Check /etc/haproxy/haproxy.cfg for HAProxy configuration."
