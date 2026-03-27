# Chef AI – Local AI Meal Planning Stack

A fully local, portable AI-powered meal planning system built with:

- **n8n** → workflow orchestration
- **Ollama** → local LLM inference
- **Open WebUI** → chat interface for models
- **PostgreSQL** → n8n database

Designed to run consistently across **Windows (WSL), Linux, and macOS** using Docker.

## What This Project Does

This stack enables you to:

- Generate structured meal plans using local AI models
- Automate recipe workflows via n8n
- Build AI-powered pipelines such as validation, formatting, and shopping list generation
- Run everything locally with no external API dependency required for the core workflow

## Architecture

```text
User (curl / app)
        ↓
     n8n (webhook)
        ↓
   Ollama (LLM)
        ↓
  n8n processing (format / validate)
        ↓
     Output (JSON / text)
```

All services run inside Docker and communicate over the internal Docker network. For container-to-container communication, use:

```text
http://ollama:11434
```

## Stack Components

| Service | Port | Purpose |
|---|---:|---|
| n8n | 5678 | Workflow automation and webhook handling |
| Ollama | 11434 | Local AI model runtime |
| Open WebUI | 3000 | Browser UI for interacting with local models |
| PostgreSQL | 5432 | n8n database backend |

## Prerequisites

- Docker Desktop on Windows/macOS or Docker Engine on Linux
- WSL2 for Windows users
- Git
- A machine with enough RAM and CPU to run the selected Ollama model

## Setup Instructions

### 1. Clone the repo

```bash
git clone <your-repo-url>
cd chef-ai
```

### 2. Create the `.env` file

Create a `.env` file in the project root with values similar to the following:

```env
WEBUI_SECRET_KEY=change-this
POSTGRES_USER=n8n
POSTGRES_PASSWORD=n8npassword
POSTGRES_DB=n8n

N8N_HOST=localhost
WEBHOOK_URL=http://localhost:5678/
N8N_EDITOR_BASE_URL=http://localhost:5678/
GENERIC_TIMEZONE=America/Denver
TZ=America/Denver
N8N_ENCRYPTION_KEY=change-this-to-a-long-random-string
```

### 3. Fix permissions for persisted data (important on Linux / WSL)

If n8n fails with a permissions error such as `EACCES: permission denied, open '/home/node/.n8n/config'`, fix ownership on the mounted data directory:

```bash
sudo chown -R 1000:1000 ./data
```

If you are doing a quick test and still hit permissions problems, this wider permission change can help confirm the issue:

```bash
sudo chmod -R 777 ./data
```

### 4. Start the stack

```bash
docker compose up -d
```

### 5. Verify the services

```bash
docker compose ps
```

You should see these services up:

- `n8n`
- `ollama`
- `open-webui`
- `postgres`

## AI Model Setup

Pull the model your workflow expects into the Ollama container. Example:

```bash
docker exec -it ollama ollama pull qwen2.5:3b
```

Verify installed models:

```bash
docker exec -it ollama ollama list
```

## Access URLs

- n8n: `http://localhost:5678`
- Open WebUI: `http://localhost:3000`
- Ollama API: `http://localhost:11434`

## Workflow Import

### Option 1: Import from the n8n UI

1. Open n8n in the browser.
2. Choose **Import from file**.
3. Select the exported workflow JSON file.

### Option 2: Import from the CLI

If your workflow export is stored at `./n8n/workflows/workflows.json`, use:

```bash
docker cp ./n8n/workflows/workflows.json n8n:/home/node/workflows.json
docker exec -it n8n n8n import:workflow --input=/home/node/workflows.json
```

If you exported multiple workflow files in a directory, use the separate import mode:

```bash
docker cp ./n8n/workflows n8n:/home/node/workflows
docker exec -it n8n n8n import:workflow --separate --input=/home/node/workflows
```

## Testing the System

### Test webhook

For a webhook in test mode:

```bash
curl -X POST http://localhost:5678/webhook-test/meal-plan   -H "Content-Type: application/json"   -d '{
    "meat_1": "Chicken",
    "meat_2": "Beef",
    "non_meat_1": "Lentils",
    "servings": "5"
  }'
```

For an activated production workflow, replace `webhook-test` with `webhook`.

### Test Ollama directly

```bash
curl -X POST http://localhost:11434/api/generate   -H "Content-Type: application/json"   -d '{
    "model": "qwen2.5:3b",
    "prompt": "Create a simple meal plan.",
    "stream": false
  }'
```

## Key Configuration Rules

### Internal service communication

When one container talks to another container on the same Compose network, use the service name:

```text
http://ollama:11434
```

For n8n HTTP nodes talking to Ollama, this is the correct internal URL.

Do not use these values for container-to-container traffic:

- `localhost`
- `host.docker.internal`
- a machine-specific LAN IP

### Webhook URLs

From the machine where n8n is running, use:

- Test mode: `http://localhost:5678/webhook-test/...`
- Active workflow: `http://localhost:5678/webhook/...`

## Common Issues and Fixes

### 1. `ENOTFOUND ollama`

Cause: `n8n` and `ollama` are not running on the same Docker Compose network, or the stack was not started through Compose.

Fix:

```bash
docker compose up -d
```

Also verify all services are running through the same compose project.

### 2. `405 method not allowed`

Cause: wrong HTTP method or wrong Ollama endpoint.

Use:

- `POST /api/generate`
- or `POST /api/chat`

Examples:

```text
http://ollama:11434/api/generate
http://ollama:11434/api/chat
```

### 3. `model 'qwen2.5:3b' not found`

Cause: the model was not pulled inside the Ollama container.

Fix:

```bash
docker exec -it ollama ollama pull qwen2.5:3b
```

### 4. `EACCES: permission denied, open '/home/node/.n8n/config'`

Cause: the mounted n8n data directory is not writable by the container user.

Fix:

```bash
sudo chown -R 1000:1000 ./data
```

### 5. Imported workflows do not appear

Cause: wrong file extension, wrong file path, or the bundled export was imported the wrong way.

Recommended CLI import:

```bash
docker cp ./n8n/workflows/workflows.json n8n:/home/node/workflows.json
docker exec -it n8n n8n import:workflow --input=/home/node/workflows.json
```

## Recommended Project Structure

```text
chef-ai/
│
├── docker-compose.yml
├── .env
├── .env.example
├── data/
│   ├── n8n/
│   └── ollama/
│
├── n8n/
│   ├── workflows/
│   │   └── workflows.json
│   └── credentials/
│
└── scripts/
    └── test-meal-plan.sh
```

## Multi-Machine Workflow

On any machine that will run the local stack:

```bash
git pull
docker compose up -d
```

Then:

1. import workflows if needed
2. pull the required Ollama model
3. test the webhook and end-to-end flow

## Suggested Git Hygiene

Commit:

- `docker-compose.yml`
- `.env.example`
- exported workflow JSON files
- setup scripts
- README documentation

Do not commit:

- `.env`
- secrets
- local database files
- large local data directories unless intentionally versioned

## Next Steps

Once the stack is stable, good next improvements are:

- add structured JSON validation
- add recipe ingredient extraction and formatting
- build a shopping list generator
- create reusable test scripts
- automate workflow import and bootstrap
- add a simple frontend or mobile client later

## Philosophy

- local-first AI
- reproducible environments
- modular workflows
- portable across machines
- minimal external dependency surface
