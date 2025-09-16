Modulo 1 (4h) — VM, Linux, Git


1. 
Introduzione DevOps (30’)


	- Che cos’è DevOps, cicli CI/CD, infrastruttura come codice, osservabilità.

	- Mappa dei prerequisiti e percorso del corso. Output atteso del progetto finale.


2. 
VirtualBox e Vagrant (75’)


	- Concetti: VM vs container, snapshot, rete NAT/host-only/bridged.

	- Setup: importare box ubuntu, Vagrantfile minimal.

	- Esercizio: creare VM con 2 NIC (NAT + host-only), porta 8080 forwardata.

	- Troubleshooting tipico: VT-x/SVM disabilitato, conflitti porte, guest additions.


3. 
Nozioni di base Linux e CLI (60’)


	- Navigazione: ls, cd, pwd, find, grep, less, head/tail, redirezioni e pipe.

	- Gestione file: cp, mv, rm, chmod/chown, tar, rsync.

	- Processi e servizi: ps, top/htop, systemctl.

	- Editor vi/vim: modalità, salvataggio, ricerca, multi-line edit.

	- Esercizio: scrivere un piccolo script bash che verifica servizi attivi e logga su /var/log/local/.


4. 
Gestione pacchetti e servizi (20’)


	- apt update/upgrade/install, systemctl enable/start/status/logs con journalctl.

	- Esercizio: installare curl, git, python3-pip.


5. 
Git e GitHub (35’)


	- git init/clone/add/commit/branch/merge/rebase/bisect basics, remote, PR.

	- Esercizio: fork del repo del corso, creare branch “feature/setup”, aprire PR sul mirror didattico.


Modulo 2 (4h) — Networking, Web server, TLS


1. 
Networking Fundamentals (60’)


	- IP, subnet, gateway, DNS, /etc/hosts, ping, traceroute, nslookup/dig, ss/netstat.

	- Porte e protocolli (TCP/UDP), firewall ufw.

	- Esercizio: configurare NIC host-only su 192.168.56.0/24, verificare con ip addr; abilitare porta 8080 con ufw.


2. 
Apache HTTPD e NGINX overview (30’)


	- Scelte d’uso, statico vs reverse proxy.

	- Esercizio rapido: installare nginx, servire una pagina statica su 8080, log access/error.


3. 
Apache Tomcat (30’)


	- Concetti Java servlet/JSP, war, connettori.

	- Demo: avvio Tomcat, deploy war di esempio (hello.war). Nota sui conflitti di porta 8080.


4. 
SSL/TLS Basics (40’)


	- Certificati, catena, chiavi, CSR, self-signed vs CA.

	- Esercizio: generare self-signed con openssl, configurare NGINX per HTTPS su 8443, test con curl -k e browser.


5. 
JSON, YAML, JSONPath (40’)


	- Sintassi, differenze, insidie (indentazione YAML).

	- Strumenti: jq yq.

	- Esercizio: estrarre campi da una risposta JSON con jq; convertire YAML⇄JSON con yq.


6. 
Checkpoint quiz/retro (10’)



Modulo 3 (4h) — Applicazioni e Database

Opzione Python (consigliata per rapidità)


1. 
Python e PIP (45’)


	- venv, pip install, requirements.txt, gestione versioni.

	- Esercizio: creare venv, installare Flask, requests, psycopg2-binary.


2. 
App Flask (60’)


	- App minimal con due endpoint: /health e /users (GET).

	- Config via YAML/JSON (porta, DB URL). Logging su stdout e file.

	- Esercizio: implementare /health che verifica connessione DB, e /users che legge utenti.


3. 
PostgreSQL (60’)


	- Installazione e avvio, utenti/ruoli, database, schema semplice.

	- Esercizio: creare DB devops, tabella users(id, name), seed iniziale. Connessione da Flask.


4. 
MongoDB (opzionale 30’)


	- Installazione, concetto di documenti/collection.

	- Esercizio breve: salvare un documento e leggerlo. Confronto SQL vs NoSQL.


5. 
Java Build & Packaging (opzione alternativa 45’)


	- JDK 17, Maven/Gradle, packaging jar/war, struttura progetto.

	- Esercizio: app Spring Boot “hello” con actuator /health, configurazione YAML.


Modulo 4 (4h) — Integrazione end‑to‑end e progetto finale


1. 
Integrazione con web server (45’)


	- NGINX reverse proxy verso Flask su 5000 (o Spring Boot su 8081).

	- Esercizio: configurare server block, upstream, headers, timeouts, log separati. Verifica con curl.


2. 
Sicurezza di base (30’)


	- Least privilege, ssh hardening, ufw, aggiornamenti, permessi file chiave/tls, variabili d’ambiente per segreti.

	- Esercizio: creare utente app, systemd unit per l’app con EnvironmentFile.


3. 
Service management e logging (30’)


	- systemd unit per l’app: restart on-failure, working directory, ExecStart.

	- Esercizio: file .service, abilitare all’avvio, visualizzare log con journalctl -u.


4. 
DNS pratico e troubleshooting (25’)


	- /etc/hosts per dominio locale (es. app.local), dig, curl con Host header.

	- Esercizio: mappare app.local a IP host-only e testare HTTPS con certificato self-signed.


5. 
Verifica DB e migrazioni leggere (20’)


	- Script SQL idempotenti, check di schema version (manuale).

	- Esercizio: aggiungere colonna email a users, migrare seed, aggiornare app.


6. 
Progetto finale e consegna (90’)


	- Obiettivo: consegnare una VM Vagrant che, con vagrant up, provvede:
		- NGINX reverse proxy su 443 (self-signed) → app Python/Java.

		- App esposta con /health e /users.

		- PostgreSQL con tabella users e seed.

		- Config in YAML/JSON; systemd unit per l’app; ufw configurato.


	- Deliverable:
		- Repository Git con: Vagrantfile, provisioning script (bash o Ansible local), sorgenti app, file di config, unit systemd, README con istruzioni, diagramma architetturale semplice.


	- Criteri di valutazione (vedi sotto).


Criteri di valutazione


- Funziona con vagrant up (automatizzazione provisioning): 30%

- Qualità del repository (struttura, README, commit chiari, .gitignore): 20%

- App: endpoint /health e /users funzionanti, logging, configurazioni esterne: 20%

- Integrazione: NGINX reverse proxy, TLS self-signed, ufw coerente: 15%

- DB: schema creato, seed e query corretta: 10%

- Troubleshooting documentato (FAQ nel README): 5%
