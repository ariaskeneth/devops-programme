import os
import yaml
import psycopg2
from flask import Flask, jsonify

def load_config():
  path = os.getenv("APP_CONFIG", "/opt/app/config.yaml")
  with open(path, "r") as f:
    return yaml.safe_load(f)

cfg = load_config()
DB_URL = os.getenv("DB_URL", cfg["database"]["url"])

app = Flask(__name__)

@app.get("/health")
def health():
  try:
    with psycopg2.connect(DB_URL) as conn:
      with conn.cursor() as cur:
        cur.execute("SELECT 1")
    return jsonify(status="ok"), 200
  except Exception as e:
    return jsonify(status="error", error=str(e)), 500

@app.get("/users")
def users():
  with psycopg2.connect(DB_URL) as conn:
    with conn.cursor() as cur:
      cur.execute("SELECT id, name FROM users ORDER BY id")
      rows = [{"id": r[0], "name": r[1]} for r in cur.fetchall()]
  return jsonify(rows), 200

if __name__ == "__main__":
  host = cfg["app"]["host"]
  port = int(cfg["app"]["port"])
  app.run(host=host, port=port)