# system-monitor

A Linux system monitoring dashboard built from scratch.
Bash scripts handle all data collection -> a FastAPI backend
exposes the results as JSON endpoints.

Built as a practical DevSecOps learning project. Every script
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
