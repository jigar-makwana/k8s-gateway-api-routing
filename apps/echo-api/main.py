import os
import time
import uuid
import json
from flask import Flask, request, jsonify

app = Flask(__name__)

APP_NAME = os.getenv("APP_NAME", "echo-api")
APP_VERSION = os.getenv("APP_VERSION", "0.1.0")
POD_NAME = os.getenv("POD_NAME", "unknown")
NODE_NAME = os.getenv("NODE_NAME", "unknown")
NAMESPACE = os.getenv("POD_NAMESPACE", "unknown")

@app.get("/healthz")
def healthz():
    return {"status": "ok"}, 200

@app.get("/readyz")
def readyz():
    return {"status": "ready"}, 200

@app.get("/")
def root():
    start = time.time()
    req_id = request.headers.get("x-request-id") or str(uuid.uuid4())

    payload = {
        "app": APP_NAME,
        "version": APP_VERSION,
        "pod": POD_NAME,
        "node": NODE_NAME,
        "namespace": NAMESPACE,
        "method": request.method,
        "path": request.path,
        "host": request.host,
        "remote_addr": request.remote_addr,
        "headers": {
            "user-agent": request.headers.get("user-agent"),
            "x-forwarded-for": request.headers.get("x-forwarded-for"),
            "x-request-id": request.headers.get("x-request-id"),
        },
        "request_id": req_id,
    }

    # Simple structured log to stdout
    log = {
        "ts": int(time.time()),
        "level": "INFO",
        "msg": "request",
        "request_id": req_id,
        "method": request.method,
        "path": request.path,
        "status": 200,
        "latency_ms": int((time.time() - start) * 1000),
        "pod": POD_NAME,
        "namespace": NAMESPACE,
    }
    print(json.dumps(log), flush=True)

    resp = jsonify(payload)
    resp.headers["x-request-id"] = req_id
    return resp, 200

if __name__ == "__main__":
    # local dev only
    app.run(host="0.0.0.0", port=8080)
