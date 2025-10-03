#!/bin/bash
set -e

# === Variablen ===
MY_ONECLICK_REPO="https://tbotteam.github.io/one-click-apps"
API_ENDPOINT="http://localhost:3000/api/v2/user/apps/appDefinitions"

# === Systemupdate ===
apt update && apt upgrade -y

# === Docker installieren ===
curl -fsSL https://get.docker.com | sh

# === Firewall-Regeln (UFW) ===
ufw allow 22/tcp
ufw allow 80,443,3000,996,7946,4789,2377/tcp
ufw allow 7946,4789,2377/udp
ufw --force enable


# === CapRover starten ===
echo "➡️ Starte CapRover..."
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

# === Warte bis CapRover API verfügbar ist ===
echo "⏳ Warte bis CapRover API hochgefahren ist..."
while true; do
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$API_ENDPOINT" || true)
  if [ "$STATUS" != "000" ]; then
    echo "→ API erreichbar (HTTP $STATUS)"
    break
  fi
  sleep 5
done

# === OneClick-App Repo setzen ===
echo "➡️ Überschreibe OneClick-App Repo mit deinem Repo..."
curl -s -X POST "$API_ENDPOINT" \
  -H "x-namespace: captain" \
  -H "x-captain-auth: captain42" \
  -H "Content-Type: application/json" \
  -d "{\"repos\":[\"$MY_ONECLICK_REPO\"]}"

echo "✅ Setup abgeschlossen!"

