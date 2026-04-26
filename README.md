# system-monitor

A Linux system monitoring dashboard built from scratch.
Bash scripts handle all data collection -> a FastAPI backend
exposes the results as JSON endpoints.

Built as a practical DevOps/security learning project. Every script
was written with a security lens -> not just what the system
is doing, but what an attacker could do with that information.

---

## What it does

| Script | Function |
|---|---|
| `path_auditor.sh` | Audits PATH directories for security risks — detects current directory exposure, non-root owned directories, and missing paths |
| `process_monitor.sh` | Monitors running processes — top CPU and memory consumers, process states, zombie detection |
| `log_parser.sh` | Parses log files — filters by severity, counts occurrences, extracts IP addresses, identifies failed login attempts |

Each script supports a `--json` flag for structured output,
consumed by the FastAPI backend.

---

## Architecture

bash scripts (data collection)
-> --json flag
FastAPI backend (HTTP API layer)
-> GET endpoints
/audit    /monitor    /docs

The bash scripts do the actual work. FastAPI just exposes
their output over HTTP. This keeps the system modular ->
scripts can be run standalone or via the API.

---

## Project structure

    system-monitor/
    ├── backend/
    │   └── main.py          ← FastAPI app, subprocess integration
    ├── scripts/
    │   ├── path_auditor.sh  ← PATH security audit, JSON output
    │   ├── process_monitor.sh ← process monitoring, zombie detection
    │   └── log_parser.sh    ← log analysis and IP extraction
    ├── .gitignore
    ├── requirements.txt
    └── README.md
---

## Setup

**Requirements:**
- Linux (Ubuntu 20 . 04+)
- Python 3.8+
- bash

**Install dependencies:**
```bash
pip install -r requirements.txt
```

**Run the API:**
```bash
uvicorn backend.main:app --reload --host 0.0.0.0 --port 8000
```

**Test endpoints:**
```bash
curl http://localhost:8000/audit
curl http://localhost:8000/monitor
```

**Interactive API docs** — open in browser after starting the server:
http://localhost:8000/docs

---

## Run scripts standalone

```bash
# CLI output
bash scripts/path_auditor.sh
bash scripts/process_monitor.sh

# JSON output (consumed by FastAPI)
bash scripts/path_auditor.sh --json
bash scripts/process_monitor.sh --json

# Log parser
bash scripts/log_parser.sh /path/to/logfile.log
```

---

## Security notes

`path_auditor.sh` flags these conditions as risks:
- Current directory `.` present in PATH
- Empty PATH entries (implicit current directory)
- Directories not owned by root

`process_monitor.sh` detects zombie processes — processes
that have completed execution but haven't been reaped by
their parent, which can exhaust the system's PID table.

Both scripts set a hardened internal PATH before execution
to prevent PATH hijacking attacks against the scripts themselves.

---

## Status

| Component | Status |
|---|---|
| `path_auditor.sh` | Complete — CLI + JSON output |
| `process_monitor.sh` | Complete — CLI + JSON output, zombie detection |
| `log_parser.sh` | In progress |
| FastAPI backend | In progress |
| Live deployment | Upcoming |

---


