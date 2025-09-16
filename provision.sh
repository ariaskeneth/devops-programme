#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

log() { echo "[provision] $*"; }

log "Aggiornamento pacchetti"
apt-get update
apt-get install -y \
  nginx python3 python3-venv python3-pip \
  postgresql jq ufw git curl openssl \
  build-essential libpq-dev

log "Configurazione PostgreSQL (utente, db, schema, seed)"
sudo -u postgres psql -tc "SELECT 1 FROM pg_roles WHERE rolname='appuser'" | grep -q 1 \
  || sudo -u postgres psql -c "CREATE USER appuser WITH PASSWORD 'appPass!';"
sudo -u postgres psql -tc "SELECT 1 FROM pg_database WHERE datname='devops'" | grep -q 1 \
  || sudo -u postgres createdb -O appuser devops
sudo -u postgres psql -d devops -f /vagrant/db/init.sql || true

log "Utente applicativo e directory"
id -u appuser >/dev/null 2>&1 || useradd -m -s /bin/bash appuser
install -d -o appuser -g appuser /opt/app

log "Virtualenv Python e dipendenze"
python3 -m venv /opt/app/venv
/opt/app/venv/bin/pip install --upgrade pip
/opt/app/venv/bin/pip install -r /vagrant/app/requirements.txt

log "Deploy app e config"
install -m 0644 -o appuser -g appuser /vagrant/app/config.yaml /opt/app/config.yaml
install -m 0644 -o appuser -g appuser /vagrant/app/app.py /opt/app/app.py

log "Systemd unit"
install -m 0644 /vagrant/app/dev.service /etc/systemd/system/dev.service
systemctl daemon-reload
systemctl enable dev.service
systemctl restart dev.service

log "TLS self-signed per NGINX"
mkdir -p /etc/nginx/tls
if [ ! -f /etc/nginx/tls/self.key ]; then
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/tls/self.key -out /etc/nginx/tls/self.crt \
    -subj "/CN=localhost"
fi

log "Configurazione NGINX reverse proxy"
install -m 0644 /vagrant/nginx/app.conf /etc/nginx/sites-available/app.conf
ln -sf /etc/nginx/sites-available/app.conf /etc/nginx/sites-enabled/app.conf
rm -f /etc/nginx/sites-enabled/default
nginx -t
systemctl restart nginx

log "Firewall UFW"
ufw --force reset
ufw allow 22
ufw allow 80
ufw allow 443
ufw --force enable

log "Verifiche post-provision"
bash /vagrant/scripts/verify.sh || true

log "Provisioning completato"