from fastapi import FastAPI
import subprocess
import json

app = FastAPI()

def run_script(script):
    result = subprocess.run(
        ["bash", script, "--json"],
        capture_output=True,
        text=True
    )

    if result.returncode != 0:
        return {"status": "error", "error": result.stderr}

    try:
        return json.loads(result.stdout)
    except:
        return {"status": "error", "raw": result.stdout}


@app.get("/")
def root():
    return {"status": "working"}


@app.get("/api/path")
def path():
    return run_script("scripts/path_auditor.sh")
