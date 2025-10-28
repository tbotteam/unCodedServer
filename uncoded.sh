#!/bin/bash
set -e

# Systemupdate
apt update && apt upgrade -y

# Docker installieren
curl -fsSL https://get.docker.com | sh

# Firewall-Regeln (UFW)
ufw allow 22/tcp
ufw allow 80,443,3000,996,7946,4789,2377/tcp
ufw allow 4000:4010/tcp
ufw allow 7946,4789,2377/udp
ufw --force enable

# CapRover starten
docker run -d \
  --name caprover \
  --restart=always \
  -p 80:80 \
  -p 443:443 \
  -p 3000:3000 \
  -p 4000:4000 \
  -p 4001:4001 \
  -p 4002:4002 \
  -p 4003:4003 \
  -p 4004:4004 \
  -p 4005:4005 \    
  -p 4006:4006 \    
  -p 4007:4007 \    
  -p 4008:4008 \    
  -p 4009:4009 \    
  -p 4010:4010 \
  -e ACCEPTED_TERMS=true \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /captain:/captain \
  tbotteam/caprover-uncoded:latest
