#!/bin/bash
set -e

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
docker run -d \
  --name caprover \
  --restart=always \
  -p 80:80 \
  -p 443:443 \
  -p 3000:3000 \
  -e ACCEPTED_TERMS=true \
  -e CAPROVER_ROOT_PASS="uncoded" \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /captain:/captain \
  caprover/caprover

# === Nginx installieren ===
apt-get install -y nginx

# === Nginx Config: Redirect von CapRover OneClick auf dein Repo ===
cat > /etc/nginx/sites-available/caprover-oneclick <<EOF
server {
    listen 80;
    server_name raw.githubusercontent.com;

    location /caprover/one-click-apps/master/public/v4/apps.json {
        proxy_pass https://tbotteam.github.io/one-click-apps/apps.json;
    }
}
EOF

ln -sf /etc/nginx/sites-available/caprover-oneclick /etc/nginx/sites-enabled/caprover-oneclick
nginx -t && systemctl reload nginx

# === Hosts-Eintrag für raw.githubusercontent.com auf lokalen Nginx umleiten ===
if ! grep -q "raw.githubusercontent.com" /etc/hosts; then
  echo "127.0.0.1 raw.githubusercontent.com" >> /etc/hosts
fi

# === Testausgabe ===
echo "➡️ Test Redirect:"
curl -s http://raw.githubusercontent.com/caprover/one-click-apps/master/public/v4/apps.json | head -n 20

echo "✅ Fertig! CapRover läuft mit Passwort 'uncoded' und lädt nur dein eigenes OneClick-Repo."
