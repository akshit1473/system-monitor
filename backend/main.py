from fastapi import FastAPI
import subprocess
import json
import time
from datetime import datetime


app = FastAPI()

def analyze_risk(raw):

    if raw.get("execution", {}).get("status") != "success":
        return {
            "status": "error",
            "message": "Script failed",
            "details": raw
        }

    issues = raw.get("data", {}).get("issues", [])

    score = 0
    insights = []

    for issue in issues:
        # --- Detect severity ---
        if issue.startswith("CRITICAL"):
            severity = "HIGH"
            score += 3
        elif issue.startswith("WARN"):
            severity = "MEDIUM"
            score += 1
        else:
            severity = "LOW"

        # --- Add simple explanation ---
        if "current directory in path" in issue.lower():
            fix = "Remove '.' from PATH"
            impact = "Command hijacking risk"
        elif "does not exist" in issue.lower():
            fix = "Remove invalid PATH entry"
            impact = "Broken configuration"
        elif "owned by" in issue.lower():
            fix = "Restrict directory ownership"
            impact = "Possible privilege escalation"
        else:
            fix = "Check manually"
            impact = "Unknown risk"

        insights.append({
            "issue": issue,
            "severity": severity,
            "impact": impact,
            "fix": fix
        })

    # --- Normalize score ---
    score = min(score, 10)

    if score >= 5:
        overall = "HIGH"
    elif score >= 2:
        overall = "MEDIUM"
    else:
        overall = "LOW"

    return {
        "status": "success",
        "risk_score": score,
        "overall_severity": overall,
        "total_issues": len(insights),
        "insights": insights
    }

def run_script(script):
    start = time.time()

    result = subprocess.run(
        ["bash", script, "--json"],
        capture_output=True,
        text=True
    )

    duration = int((time.time() - start) * 1000)

    if result.returncode != 0:
        return {
            "execution": {
                "status": "error",
                "time_ms": duration
            },
            "meta": {
                "script": script,
                "timestamp": datetime.utcnow().isoformat()
            },
            "error": result.stderr
        }

    try:
        parsed = json.loads(result.stdout)

        return {
            "execution": {
                "status": "success",
                "time_ms": duration
            },
            "meta": {
                "script": script,
                "timestamp": datetime.utcnow().isoformat()
            },
            "data": parsed.get("data", parsed)
        }

    except:
        return {
            "execution": {
                "status": "parse_error",
                "time_ms": duration
            },
            "meta": {
                "script": script,
                "timestamp": datetime.utcnow().isoformat()
            },
            "raw": result.stdout
        }

@app.get("/")
def root():
    return {"status": "working"}


@app.get("/api/audit/path")
def path():
    raw = run_script("scripts/path_auditor.sh")
    processed = analyze_risk(raw)
    return processed


@app.get("/api/analyze/logs")
def analyze_logs(logfile: str = Query(...)):
    return run_script("scripts/log_parser.sh", [logfile])

@app.get("/api/monitor/process")
def path():
    return run_script("scripts/process_monitor.sh")

@app.get("/api/summary")
def summary():
    path_raw = run_script("scripts/path_auditor.sh")
    process_raw = run_script("scripts/process_monitor.sh")

    return {
        "path": analyze_risk(path_raw),
        "process": analyze_risk(process_raw)
    }

    
