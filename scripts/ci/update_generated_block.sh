#!/usr/bin/env bash
set -euo pipefail
COMPAT_FILE="${1:-COMPATIBILITY.md}"
GENERATED_MD_FILE="${2:-/dev/stdin}"
START_MARK="<!-- GENERATED:START -->"
END_MARK="<!-- GENERATED:END -->"

python3 - <<'PY' "$COMPAT_FILE" "$GENERATED_MD_FILE" "$START_MARK" "$END_MARK"
import sys, pathlib
compat_path = pathlib.Path(sys.argv[1])
generated_path = pathlib.Path(sys.argv[2])
start = sys.argv[3]
end = sys.argv[4]
compat = compat_path.read_text(encoding='utf-8')
if start not in compat or end not in compat:
    raise SystemExit(f'ERROR: markers not found in {compat_path}')
before, rest = compat.split(start, 1)
_, after = rest.split(end, 1)
generated = generated_path.read_text(encoding='utf-8').strip()
new_content = before + start + "\n\n" + generated + "\n\n" + end + after
compat_path.write_text(new_content, encoding='utf-8')
print(f"Updated {compat_path}")
PY
