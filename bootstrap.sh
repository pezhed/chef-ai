#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

for dir in data/ollama data/open-webui data/postgres data/n8n logs projects music travel ideas n8n/workflows scripts; do
  mkdir -p "$dir"
done

if [[ ! -f .env ]]; then
  cp .env.example .env
  echo "Created .env from .env.example"
  echo "Edit .env before starting the stack."
fi

echo "Starting Personal AI Builder stack..."
docker compose up -d

echo
echo "Open WebUI: http://localhost:3000"
echo "n8n:        http://localhost:5678"
echo "Ollama API: http://localhost:11434"
