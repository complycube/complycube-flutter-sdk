#!/usr/bin/env bash
set -euo pipefail

ROW_JSON=""
RESULTS_DIR=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --row-json) ROW_JSON="$2"; shift 2;;
    --results-dir) RESULTS_DIR="$2"; shift 2;;
    *) echo "Unknown arg: $1"; exit 2;;
  esac
done

if [[ -z "$ROW_JSON" || -z "$RESULTS_DIR" ]]; then
  echo "ERROR: --row-json and --results-dir are required"
  exit 1
fi
mkdir -p "$RESULTS_DIR"

row_id="$(python3 - <<PY "$ROW_JSON"
import json,sys
print(json.load(open(sys.argv[1],encoding='utf-8'))['id'])
PY
)"

echo "=== Android build row: $row_id ==="

flutter config --no-analytics >/dev/null 2>&1 || true

started="$(python3 - <<'PY'
import time; print(time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()))
PY
)"

outcome="pass"
notes=""

if ! flutter pub get; then
  outcome="fail"
  notes="flutter pub get failed"
fi

if [[ "$outcome" == "pass" ]]; then
  chmod +x ./scripts/doctor.sh || true
  ./scripts/doctor.sh || true
fi

build_log="$(mktemp)"

if [[ "$outcome" == "pass" ]]; then
  agp="$(python3 - <<PY "$ROW_JSON"
import json,sys
print(json.load(open(sys.argv[1],encoding='utf-8')).get('agp',''))
PY
)"
  gradle="$(python3 - <<PY "$ROW_JSON"
import json,sys
print(json.load(open(sys.argv[1],encoding='utf-8')).get('gradle',''))
PY
)"
  kotlin="$(python3 - <<PY "$ROW_JSON"
import json,sys
print(json.load(open(sys.argv[1],encoding='utf-8')).get('kotlin',''))
PY
)"
  ./scripts/ci/apply_android_toolchain.sh --agp "$agp" --kotlin "$kotlin" --gradle "$gradle"
fi

if [[ "$outcome" == "pass" ]]; then
  set +e
  flutter build apk --debug >"$build_log" 2>&1
  build_status=$?
  set -e
  if [[ $build_status -ne 0 ]]; then
    outcome="fail"
    notes="flutter build apk failed"
  fi
fi

detected_file="$(mktemp)"
./scripts/ci/collect_versions.sh --platform android --row-id "$row_id" > "$detected_file" || true

ended="$(python3 - <<'PY'
import time; print(time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()))
PY
)"

log_tail_file="$(mktemp)"
tail -n 120 "$build_log" > "$log_tail_file" || true

python3 - <<'PY' "$ROW_JSON" "$detected_file" "$log_tail_file" "$row_id" "$outcome" "$notes" "$started" "$ended" "$RESULTS_DIR"
import json, sys, pathlib
row_json, detected_json, log_tail_file, row_id, outcome, notes, started, ended, results_dir = sys.argv[1:10]
requested = json.load(open(row_json, encoding="utf-8"))
try:
    detected = json.load(open(detected_json, encoding="utf-8"))
except Exception:
    detected = {}
log_tail = pathlib.Path(log_tail_file).read_text(encoding="utf-8", errors="replace")
out = {
  "id": requested.get("id",""),
  "platform": "android",
  "requested": requested,
  "detected": detected,
  "outcome": outcome,
  "notes": notes,
  "log_tail": log_tail,
  "started_at": started,
  "ended_at": ended,
}
path = pathlib.Path(results_dir) / f"{row_id}.json"
path.write_text(json.dumps(out, indent=2), encoding="utf-8")
print(f"Wrote result: {path}")
PY
