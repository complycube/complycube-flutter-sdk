#!/usr/bin/env bash
set -euo pipefail

# Builds Android and writes a result JSON.
# Usage:
#   ./scripts/ci/build_android.sh --row-json scripts/ci/matrix_row.json --results-dir artifacts/results
#
# The row json is expected to be one object (not the full matrix.json).

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

started="$(python3 - <<'PY'
import time; print(time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()))
PY
)"

outcome="pass"
notes=""

set +e
flutter pub get
pub_status=$?
set -e
if [[ $pub_status -ne 0 ]]; then
  outcome="fail"
  notes="flutter pub get failed"
fi

if [[ "$outcome" == "pass" ]]; then
  # Run doctor (non-fatal warnings)
  chmod +x ./scripts/doctor.sh || true
  set +e
  ./scripts/doctor.sh
  set -e
fi

# Apply toolchain versions for this row (AGP/Kotlin/Gradle)
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

# Build APK
build_log="$(mktemp)"
if [[ "$outcome" == "pass" ]]; then
  set +e
  flutter build apk --debug 2>&1 | tee "$build_log"
  build_status=$?
  set -e
  if [[ $build_status -ne 0 ]]; then
    outcome="fail"
    notes="flutter build apk failed"
  fi
fi

# Collect versions
detected="$(./scripts/ci/collect_versions.sh --platform android --row-id "$row_id")"

ended="$(python3 - <<'PY'
import time; print(time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()))
PY
)"

# Requested row
requested="$(cat "$ROW_JSON")"

# Keep last 120 lines of logs for debugging
log_tail="$(tail -n 120 "$build_log" 2>/dev/null | python3 -c 'import sys, json; print(json.dumps(sys.stdin.read()))' || echo "\"\"")"

python3 - <<PY > "${RESULTS_DIR}/${row_id}.json"
import json
requested = json.loads('''$requested''')
detected = json.loads('''$detected''')
out = {
  "id": requested.get("id",""),
  "platform": "android",
  "requested": requested,
  "detected": detected,
  "outcome": "$outcome",
  "notes": "$notes",
  "log_tail": json.loads($log_tail),
  "started_at": "$started",
  "ended_at": "$ended",
}
print(json.dumps(out, indent=2))
PY

echo "Wrote result: ${RESULTS_DIR}/${row_id}.json"
