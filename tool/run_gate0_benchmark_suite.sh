#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
GATEWAY_DIR="$REPO_ROOT/04_build/ai_gateway"
ENV_FILE="$GATEWAY_DIR/.env.local"
HOST="${CALIBER_AI_GATEWAY_HOST:-127.0.0.1}"
PORT="${CALIBER_AI_GATEWAY_PORT:-8000}"
BASE_URL="${CALIBER_AI_GATEWAY_BASE_URL:-http://$HOST:$PORT}"
LOG_FILE="${CALIBER_AI_GATEWAY_LOG:-/private/tmp/caliber_ai_gateway_gate0_suite.log}"

gateway_ready() {
  python3 - "$BASE_URL/openapi.json" <<'PY'
import sys
import urllib.request

try:
    with urllib.request.urlopen(sys.argv[1], timeout=1) as response:
        raise SystemExit(0 if response.status == 200 else 1)
except Exception:  # noqa: BLE001
    raise SystemExit(1)
PY
}

wait_for_gateway() {
  python3 - "$BASE_URL/openapi.json" <<'PY'
import sys
import time
import urllib.request

last = None
for _ in range(90):
    try:
        with urllib.request.urlopen(sys.argv[1], timeout=1) as response:
            if response.status == 200:
                raise SystemExit(0)
    except Exception as exc:  # noqa: BLE001
        last = exc
        time.sleep(0.5)
raise SystemExit(f"AI Gateway did not become ready: {last}")
PY
}

if [[ -f "$ENV_FILE" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  set +a
fi

CALIBER_ONLY_RUN=0
for arg in "$@"; do
  if [[ "$arg" == "--caliber-debug-one" || "$arg" == "--caliber-smoke-only" || "$arg" == "--caliber-only" ]]; then
    CALIBER_ONLY_RUN=1
  fi
done

if [[ "$CALIBER_ONLY_RUN" == "1" ]]; then
  exec "$REPO_ROOT/tool/run_gate0_blind_benchmark.sh" "$@"
fi

require_secret() {
  local name="$1"
  local value="${!name:-}"
  if [[ -z "${value// }" ]]; then
    echo "GATE BLOCKED: no provider key" >&2
    echo "Missing $name. Export it or create ignored $ENV_FILE." >&2
    exit 2
  fi
}

require_openrouter_baseline_model() {
  local index="$1"
  local primary="CALIBER_OPENROUTER_BASELINE${index}_MODEL"
  local fallback=""
  if [[ "$index" == "1" ]]; then
    fallback="${CALIBER_OPENROUTER_GPT_MODEL:-${CALIBER_OPENROUTER_MODEL:-}}"
  else
    fallback="${CALIBER_OPENROUTER_ALT_MODEL:-${CALIBER_OPENROUTER_NON_OPENAI_MODEL:-}}"
  fi
  local value="${!primary:-$fallback}"
  if [[ -z "${value// }" ]]; then
    echo "GATE BLOCKED: missing $primary." >&2
    echo "Set $primary in ignored $ENV_FILE; baseline models are not hardcoded." >&2
    exit 2
  fi
}

require_openrouter_baseline_rates() {
  local index="$1"
  local primary="CALIBER_OPENROUTER_BASELINE${index}_MODEL"
  local fallback=""
  if [[ "$index" == "1" ]]; then
    fallback="${CALIBER_OPENROUTER_GPT_MODEL:-${CALIBER_OPENROUTER_MODEL:-}}"
  else
    fallback="${CALIBER_OPENROUTER_ALT_MODEL:-${CALIBER_OPENROUTER_NON_OPENAI_MODEL:-}}"
  fi
  local model="${!primary:-$fallback}"
  if [[ "$model" == *":free" ]]; then
    return 0
  fi

  local input_var="CALIBER_OPENROUTER_BASELINE${index}_INPUT_USD_PER_MILLION"
  local output_var="CALIBER_OPENROUTER_BASELINE${index}_OUTPUT_USD_PER_MILLION"
  local input_value="${!input_var:-${CALIBER_OPENROUTER_INPUT_USD_PER_MILLION:-}}"
  local output_value="${!output_var:-${CALIBER_OPENROUTER_OUTPUT_USD_PER_MILLION:-}}"
  if [[ -z "${input_value// }" || -z "${output_value// }" ]]; then
    echo "GATE BLOCKED: missing OpenRouter cost rates for baseline ${index}." >&2
    echo "Set $input_var and $output_var in ignored $ENV_FILE, or use a :free model." >&2
    exit 2
  fi
}

openrouter_baseline_fallback_provider() {
  local index="$1"
  local primary="CALIBER_OPENROUTER_BASELINE${index}_FALLBACK_PROVIDER"
  local value="${!primary:-${CALIBER_OPENROUTER_FALLBACK_PROVIDER:-chatgpt}}"
  value="$(printf '%s' "$value" | tr '[:upper:]' '[:lower:]')"
  if [[ "$value" == "openai" ]]; then
    value="chatgpt"
  fi
  if [[ "$value" == "anthropic" ]]; then
    value="claude"
  fi
  echo "$value"
}

require_openrouter_baseline_fallback_secret() {
  local index="$1"
  local provider
  provider="$(openrouter_baseline_fallback_provider "$index")"
  case "$provider" in
    chatgpt)
      require_secret OPENAI_API_KEY
      ;;
    claude)
      require_secret ANTHROPIC_API_KEY
      ;;
    *)
      echo "GATE BLOCKED: unsupported OpenRouter fallback provider for baseline ${index}: $provider" >&2
      echo "Use chatgpt/openai or claude/anthropic." >&2
      exit 2
      ;;
  esac
}

export PATH="/private/tmp/caliber_flutter_stable/bin:$PATH"
cd "$REPO_ROOT"

require_secret OPENAI_API_KEY
require_secret OPENROUTER_API_KEY
require_openrouter_baseline_model 1
require_openrouter_baseline_model 2
require_openrouter_baseline_rates 1
require_openrouter_baseline_rates 2
require_openrouter_baseline_fallback_secret 1
require_openrouter_baseline_fallback_secret 2

STARTED_GATEWAY=0
if ! gateway_ready; then
  "$GATEWAY_DIR/tool/run_local_gateway.sh" >"$LOG_FILE" 2>&1 &
  GATEWAY_PID=$!
  STARTED_GATEWAY=1
  cleanup() {
    kill "$GATEWAY_PID" >/dev/null 2>&1 || true
  }
  trap cleanup EXIT
  wait_for_gateway
fi

dart run tool/gate0_benchmark_suite.dart "$@"
