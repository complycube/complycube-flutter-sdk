#!/usr/bin/env bash
set -euo pipefail

# Builds iOS (no-codesign) and writes a result JSON.
# Always writes JSON and always exits 0 (CI should not fail based on this script).

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

echo "=== iOS build row: $row_id ==="

started="$(python3 - <<'PY'
import time; print(time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()))
PY
)"

outcome="pass"
notes=""

build_log="$(mktemp)"
detected_file="$(mktemp)"

run_step () {
  local label="$1"
  shift
  echo "" | tee -a "$build_log" >/dev/null
  echo "===== $label =====" | tee -a "$build_log"
  set +e
  "$@" 2>&1 | tee -a "$build_log"
  local st=${PIPESTATUS[0]}
  set -e
  return $st
}

# flutter pub get
if ! run_step "flutter pub get" flutter pub get; then
  outcome="fail"
  notes="flutter pub get failed"
fi

# doctor (non-fatal)
if [[ "$outcome" == "pass" ]]; then
  chmod +x ./scripts/doctor.sh || true
  set +e
  ./scripts/doctor.sh 2>&1 | tee -a "$build_log"
  set -e
fi

# pods (prefer no repo update for speed)
if [[ "$outcome" == "pass" ]]; then
  set +e
  (cd ios && pod install --no-repo-update) 2>&1 | tee -a "$build_log"
  pod_status=${PIPESTATUS[0]}
  set -e

  if [[ $pod_status -ne 0 ]]; then
    # fallback (slower, but may be required in some cases)
    set +e
    (cd ios && pod install) 2>&1 | tee -a "$build_log"
    pod_status2=${PIPESTATUS[0]}
    set -e

    if [[ $pod_status2 -ne 0 ]]; then
      outcome="fail"
      notes="pod install failed"
    fi
  fi
fi

# build ios
if [[ "$outcome" == "pass" ]]; then
  if ! run_step "flutter build ios --no-codesign" flutter build ios --no-codesign; then
    outcome="fail"
    notes="flutter build ios --no-codesign failed"
  fi
fi

# collect versions (non-fatal)
set +e
./scripts/ci/collect_versions.sh --platform ios --row-id "$row_id" > "$detected_file"
cv_status=$?
set -e
if [[ $cv_status -ne 0 ]]; then
  echo "{}" > "$detected_file"
  if [[ -z "$notes" ]]; then
    notes="collect_versions.sh failed"
  else
    notes="$notes; collect_versions.sh failed"
  fi
  outcome="fail"
fi

ended="$(python3 - <<'PY'
import time; print(time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()))
PY
)"

# write result JSON (always)
python3 - <<'PY' "$ROW_JSON" "$detected_file" "$build_log" "$RESULTS_DIR" "$row_id" "$outcome" "$notes" "$started" "$ended"
import json, sys, pathlib
row_json, detected_json, build_log, results_dir, row_id, outcome, notes, started, ended = sys.argv[1:10]

requested = json.load(open(row_json, encoding="utf-8"))
try:
    detected = json.load(open(detected_json, encoding="utf-8"))
except Exception:
    detected = {}

log_tail = pathlib.Path(build_log).read_text(encoding="utf-8", errors="replace").splitlines()[-120:]
log_tail = "\n".join(log_tail)

out = {
  "id": requested.get("id",""),
  "platform": "ios",
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

# Never fail CI from this script
exit 0
