from fastapi import FastAPI
from fastapi import Query
import subprocess
import json
import time
from datetime import datetime


app = FastAPI()

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
    return run_script("scripts/path_auditor.sh")



@app.get("/api/analyze/logs")
def analyze_logs(logfile: str = Query(...)):
    return run_script("scripts/log_parser.sh", [logfile])

@app.get("/api/monitor/process")
def path():
    return run_script("scripts/process_monitor.sh")

@app.get("/api/summary")
def summary():
    path = run_script("scripts/path_auditor.sh")
    process = run_script("scripts/process_monitor.sh")

    return {
        "path": path,
        "process": process
    }
