# echo-api

Tiny HTTP service used for routing/logging demos.

## Endpoints
- `/` returns request + pod metadata and echoes an `x-request-id`
- `/healthz` liveness
- `/readyz` readiness

## Local run (no Docker)

```bash
python -m venv .venv
# Windows: .venv\\Scripts\\activate
# macOS/Linux: source .venv/bin/activate
pip install -r requirements.txt
python main.py
