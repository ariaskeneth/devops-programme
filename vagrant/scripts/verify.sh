#!/usr/bin/env bash
set -euo pipefail

echo "[verify] Checking services..."
systemctl is-active --quiet dev.service && echo "app: OK" || (echo "app: FAIL"; exit 1)
systemctl is-active --quiet nginx && echo "nginx: OK" || (echo "nginx: FAIL"; exit 1)
pg_isready -h 127.0.0.1 -p 5432 && echo "postgres: OK" || (echo "postgres: FAIL"; exit 1)

echo "[verify] Probing HTTP(S)..."
curl -sS -k https://localhost:8443/health | jq . >/dev/null && echo "/health: OK" || (echo "/health: FAIL"; exit 1)
curl -sS -k https://localhost:8443/users | jq . >/dev/null && echo "/users: OK" || (echo "/users: FAIL"; exit 1)

echo "[verify] All checks passed."