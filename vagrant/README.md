# Fondamenta DevOps — Template Lab (Vagrant + Ubuntu + NGINX + Flask + PostgreSQL)

Questo repository è il template del laboratorio di 16 ore per introdurre le fondamenta DevOps:
- VM con Vagrant/VirtualBox
- Linux basics, servizi, systemd
- Networking, NGINX reverse proxy, TLS self-signed
- App Flask (Python) con PostgreSQL
- Git/GitHub, YAML/JSON e jq/yq
- Consegna: `vagrant up` porta ad un ambiente funzionante

## Requisiti
- VirtualBox LTS + Extension Pack
- Vagrant 2.3+
- Git
- RAM libera: >= 2 GB per la VM
- Porte host libere: 8080 (HTTP), 8443 (HTTPS)
- Facoltativo: curl, jq, OpenSSL, Python 3

## Avvio rapido
```bash
git clone <questo-repo> devops-intro
cd devops-intro/vagrant
vagrant up
```

Accedi alla VM:
```bash
vagrant ssh
```

Apri l’app:
- HTTP: http://localhost:8080/ (redirect a HTTPS)
- HTTPS: https://localhost:8443/ (certificato self-signed)
- Healthcheck: https://localhost:8443/health (ignora warning TLS nel browser)

Endpoint:
- `/health` verifica la connessione al DB
- `/users` ritorna utenti demo in JSON

## Mappa porte e rete
- Host → Guest: 8080 → 80 (NGINX)
- Host → Guest: 8443 → 443 (NGINX TLS)
- Rete privata VM: 192.168.56.10 (se usi host-only)
- PostgreSQL in guest: 127.0.0.1:5432

## Comandi utili
```bash
# nella VM
sudo systemctl status dev.service
sudo journalctl -u dev.service -f
sudo nginx -t && sudo systemctl reload nginx
psql -U appuser -d devops -h 127.0.0.1 -c "SELECT * FROM users;"
curl -k https://localhost:8443/health
```

## Struttura
- `Vagrantfile`: definizione VM e port forwarding
- `provision.sh`: provisioning idempotente (NGINX, Python, PostgreSQL, TLS, app)
- `app/`: codice Flask, config, unit systemd
- `nginx/app.conf`: server block reverse proxy + TLS
- `db/init.sql`: schema e seed iniziali
- `scripts/verify.sh`: checks post-provision

## Troubleshooting
- VM non parte: abilita virtualizzazione in BIOS/UEFI; riduci RAM/CPU nel Vagrantfile
- Porte occupate: modifica host ports 8080/8443 nel Vagrantfile
- Certificato self-signed: usa `https://localhost:8443` con eccezione di sicurezza o `curl -k`
- PostgreSQL auth: connessione via TCP `-h