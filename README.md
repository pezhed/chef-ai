# Personal AI Builder System

This stack turns your Pop!_OS Dell XPS 8500 into a local idea-to-prototype machine for side projects.

## What this stack includes

- **Ollama** for running local models
- **Open WebUI** for a browser chat interface
- **n8n** for automations and workflows
- **PostgreSQL** as n8n's database backend

## Best uses for your setup

1. **Idea Engine**
   - Drop ideas into `/ideas`
   - Use Open WebUI to expand them into MVP plans, feature lists, landing-page copy, and monetization notes

2. **Playlist + Creative Engine**
   - Store prompts, artwork notes, track ideas, and release writeups in `/music`
   - Use the local model to generate playlist descriptions, themes, and curation notes

3. **Travel + Family Ops Assistant**
   - Keep itinerary notes, budgets, and trip ideas in `/travel`
   - Build simple n8n workflows that summarize notes or turn raw text into itineraries

4. **App Builder Workspace**
   - Use `/projects` for app concepts like grocery comparison, dashboards, or little utilities
   - Pair n8n with local prompts to generate API outlines, database schemas, and task breakdowns

## Recommended first models

Because the XPS 8500 is older hardware, start small:

- `phi4-mini`
- `qwen2.5:3b`
- `llama3.2:3b`
- `mistral:7b` only if performance is acceptable

Pull a model after startup:

```bash
ollama pull qwen2.5:3b
```

## Folder layout

```text
personal-ai-builder-system/
├── docker-compose.yml
├── .env.example
├── bootstrap.sh
├── data/
├── ideas/
├── logs/
├── music/
├── n8n/
│   └── workflows/
├── projects/
├── scripts/
└── travel/
```

## Install steps

### 1) Install Docker

Run:

```bash
./scripts/install-docker-ubuntu.sh
```

Then sign out and back in.

### 2) Configure environment variables

```bash
cp .env.example .env
nano .env
```

At minimum, change these values:

- `WEBUI_SECRET_KEY`
- `POSTGRES_PASSWORD`
- `N8N_ENCRYPTION_KEY`

Generate random values with:

```bash
openssl rand -hex 32
```

### 3) Start the stack

```bash
./bootstrap.sh
```

### 4) Open the apps

- Open WebUI: `http://localhost:3000`
- n8n: `http://localhost:5678`
- Ollama API: `http://localhost:11434`

## First-run checklist

### Open WebUI

1. Open `http://localhost:3000`
2. Create the admin account
3. Confirm the Ollama connection is present
4. Pick a small model as default


### Ollama

From a terminal on the host:

```bash
ollama pull qwen2.5:3b
ollama run qwen2.5:3b
```

### n8n

1. Open `http://localhost:5678`
2. Create the owner account
3. Build your first workflow using the HTTP Request node against `http://ollama:11434/api/generate`

## Three starter workflows to build

### 1) Idea Expander

**Input:** a text file dropped into `/ideas`

**Flow:**
- Trigger on manual run or webhook
- Read the idea text
- Send it to Ollama with a prompt like:
  - "Turn this into a one-page MVP brief with target user, features, revenue model, and first-week build plan."
- Save the result into `/ideas/output`

### 2) Playlist Packager

**Input:** theme + artist references

**Flow:**
- Webhook or form input
- Prompt the model to create:
  - playlist name options
  - 20-song direction notes
  - short cover-art prompt
  - 100-word playlist description
- Save results to `/music`

### 3) Trip Planner

**Input:** destination, dates, pace, budget notes

**Flow:**
- Manual trigger
- Summarize the raw notes
- Produce day-by-day itinerary ideas
- Save to `/travel`

## Simple prompt templates

### MVP builder

```text
You are my practical product builder.
Turn this rough idea into a concise MVP brief.
Include:
1. The problem
2. Ideal user
3. Core features for v1
4. Nice-to-have features later
5. Monetization ideas
6. One-week build plan

Idea:
{{idea_text}}
```

### Playlist builder

```text
You are my music curator and creative director.
Create:
1. 5 playlist title options
2. A one-paragraph theme
3. 15-20 artist/song direction ideas
4. A short cover-art prompt
5. A 100-word description

Theme:
{{theme}}
References:
{{references}}
```

### Travel planner

```text
You are my family trip planner.
Build a practical trip outline.
Include:
1. Best daily rhythm
2. Morning / afternoon / evening plan ideas
3. Food stop ideas
4. Backup indoor option
5. One budget-saving tip per day

Trip notes:
{{trip_notes}}
```

## Good default operating rules for this machine

- Keep it local-only at first; don't expose ports to the internet
- Use small models first; your CPU and memory are the bottleneck
- Back up `data/` if you care about your n8n and Open WebUI state
- Put side-project content into folders instead of pasting everything into chat windows

## Useful commands

### Check running containers

```bash
docker compose ps
```

### View logs

```bash
docker compose logs -f
```

### Restart one service

```bash
docker compose restart n8n
```

### Pull updated images and redeploy

```bash
docker compose pull
docker compose up -d
```

### Stop everything

```bash
docker compose down
```

## Upgrade path later

If the XPS feels too slow, the cleanest future upgrade is:

- keep the same Docker layout
- move the stack to a mini PC or newer desktop
- copy the `data/` folder across

That lets you keep the same system while swapping hardware.
