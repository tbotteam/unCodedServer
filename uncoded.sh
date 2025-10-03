#!/bin/bash
set -e

# Systemupdate
apt update && apt upgrade -y

# Docker installieren
curl -fsSL https://get.docker.com | sh

# Firewall-Regeln (UFW)
ufw allow 22/tcp
ufw allow 80,443,3000,996,7946,4789,2377/tcp
ufw allow 7946,4789,2377/udp
ufw --force enable

# CapRover starten
docker run -d \
  --name caprover \
  --restart=always \
  -p 80:80 \
  -p 443:443 \
  -p 3000:3000 \
  -e ACCEPTED_TERMS=true \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /captain:/captain \
  caprover/caprover
