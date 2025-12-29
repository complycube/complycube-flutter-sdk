#!/usr/bin/env bash
set -euo pipefail

PLATFORM="${1:-}"
JSON_FILE="${2:-}"

if [[ -z "$PLATFORM" || -z "$JSON_FILE" ]]; then
  echo "Usage: scripts/ci/job_summary.sh <android|ios> <path/to/result.json>" >&2
  exit 2
fi

python3 scripts/ci/job_summary.py --platform "$PLATFORM" --json "$JSON_FILE"
