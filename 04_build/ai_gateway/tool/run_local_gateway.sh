#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GATEWAY_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$GATEWAY_DIR/../.." && pwd)"
ENV_FILE="$GATEWAY_DIR/.env.local"
VENV_DIR="${CALIBER_AI_GATEWAY_VENV:-/private/tmp/caliber_ai_gateway_venv}"
HOST="${CALIBER_AI_GATEWAY_HOST:-127.0.0.1}"
PORT="${CALIBER_AI_GATEWAY_PORT:-8000}"

python_meets_requirements() {
  "$1" -c 'import sys, ensurepip; raise SystemExit(0 if sys.version_info >= (3, 12) else 1)' >/dev/null 2>&1
}

resolve_python() {
  local candidates=()
  if [[ -n "${CALIBER_AI_GATEWAY_PYTHON:-}" ]]; then
    candidates+=("$CALIBER_AI_GATEWAY_PYTHON")
  fi
  candidates+=(
    /opt/anaconda3/bin/python3.13
    /opt/homebrew/bin/python3.12
    /opt/homebrew/bin/python3
    python3
  )

  local candidate candidate_path
  for candidate in "${candidates[@]}"; do
    if [[ "$candidate" == */* ]]; then
      candidate_path="$candidate"
    else
      candidate_path="$(command -v "$candidate" 2>/dev/null || true)"
    fi
    if [[ -n "$candidate_path" && -x "$candidate_path" ]] && python_meets_requirements "$candidate_path"; then
      echo "$candidate_path"
      return 0
    fi
  done

  echo "No usable Python >=3.12 with ensurepip found. Set CALIBER_AI_GATEWAY_PYTHON." >&2
  return 1
}

if [[ -f "$ENV_FILE" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  set +a
fi

if [[ -z "${OPENAI_API_KEY:-}" ]]; then
  if [[ -t 0 ]]; then
    read -rsp "OPENAI_API_KEY: " OPENAI_API_KEY
    echo
    export OPENAI_API_KEY
  else
    echo "OPENAI_API_KEY is missing. Export it or create ignored $ENV_FILE." >&2
    exit 2
  fi
fi

if [[ -z "${OPENAI_API_KEY// }" ]]; then
  echo "OPENAI_API_KEY is empty." >&2
  exit 2
fi

PYTHON_BIN="$(resolve_python)"

if [[ -x "$VENV_DIR/bin/python" && ! -f "$VENV_DIR/bin/activate" ]]; then
  echo "Rebuilding incomplete AI gateway venv at $VENV_DIR"
  rm -rf "$VENV_DIR"
fi

if [[ -x "$VENV_DIR/bin/python" ]] && ! "$VENV_DIR/bin/python" -m pip --version >/dev/null 2>&1; then
  echo "Rebuilding incomplete AI gateway venv at $VENV_DIR"
  rm -rf "$VENV_DIR"
fi

if [[ ! -x "$VENV_DIR/bin/python" ]]; then
  "$PYTHON_BIN" -m venv "$VENV_DIR"
fi

# shellcheck disable=SC1091
source "$VENV_DIR/bin/activate"
if ! python -m pip --version >/dev/null 2>&1; then
  echo "AI gateway venv has no working pip: $VENV_DIR" >&2
  exit 2
fi
python -m pip install -q --upgrade pip
python -m pip install -q -e "$GATEWAY_DIR[dev]" "uvicorn[standard]>=0.30,<1"

echo "Caliber AI Gateway starting on http://$HOST:$PORT"
echo "Python: $(python --version)"
echo "Token ledger: $REPO_ROOT/.cache/ai_gateway/token_usage.jsonl"
echo "Token summary: $REPO_ROOT/.cache/ai_gateway/token_usage_summary.json"
exec python -m uvicorn caliber_ai_gateway.app:app \
  --app-dir "$GATEWAY_DIR/src" \
  --host "$HOST" \
  --port "$PORT"
