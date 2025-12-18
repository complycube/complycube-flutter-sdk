#!/usr/bin/env bash
set -euo pipefail

# Applies Android toolchain versions for a matrix row (CI use).
# - Normalizes android/settings.gradle includeBuild to use FLUTTER_SDK_PATH (avoids absolute paths)
# - Ensures AGP plugin versions are declared for BOTH com.android.application and com.android.library
# - Sets Kotlin plugin version
# - Sets Gradle wrapper version (distributionUrl)
#
# Usage:
#   ./scripts/ci/apply_android_toolchain.sh --agp 8.2.2 --kotlin 1.9.24 --gradle 8.9

AGP=""
KOTLIN=""
GRADLE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --agp) AGP="$2"; shift 2;;
    --kotlin) KOTLIN="$2"; shift 2;;
    --gradle) GRADLE="$2"; shift 2;;
    *) echo "Unknown arg: $1"; exit 2;;
  esac
done

if [[ -z "$AGP" || -z "$KOTLIN" || -z "$GRADLE" ]]; then
  echo "ERROR: --agp, --kotlin and --gradle are required"
  exit 1
fi

SETTINGS="android/settings.gradle"
WRAPPER="android/gradle/wrapper/gradle-wrapper.properties"

if [[ ! -f "$SETTINGS" ]]; then
  echo "ERROR: $SETTINGS not found. Run from repo root."
  exit 1
fi
if [[ ! -f "$WRAPPER" ]]; then
  echo "ERROR: $WRAPPER not found. Run from repo root."
  exit 1
fi

echo "Applying Android toolchain: AGP=$AGP, Kotlin=$KOTLIN, Gradle=$GRADLE"

# 1) Normalize includeBuild(...) to use flutterSdkPath (removes absolute path issues in CI)
# We look for includeBuild(".../packages/flutter_tools/gradle") and replace with:
# includeBuild("${flutterSdkPath}/packages/flutter_tools/gradle")
python3 - <<'PY' "$SETTINGS"
import re, sys, pathlib
p = pathlib.Path(sys.argv[1])
s = p.read_text(encoding="utf-8")
# Replace any absolute includeBuild(".../packages/flutter_tools/gradle") with ${flutterSdkPath}/packages/flutter_tools/gradle
s2 = re.sub(r'includeBuild\(".*?/packages/flutter_tools/gradle"\)',
            r'includeBuild("${flutterSdkPath}/packages/flutter_tools/gradle")',
            s)
p.write_text(s2, encoding="utf-8")
PY

# 2) Update Gradle wrapper distributionUrl
# Example: distributionUrl=https\://services.gradle.org/distributions/gradle-8.9-all.zip
python3 - <<'PY' "$WRAPPER" "$GRADLE"
import sys, pathlib, re
p = pathlib.Path(sys.argv[1])
gradle = sys.argv[2]
txt = p.read_text(encoding="utf-8").splitlines()
out = []
repl = False
for line in txt:
    if line.startswith("distributionUrl="):
        out.append(f"distributionUrl=https\\://services.gradle.org/distributions/gradle-{gradle}-all.zip")
        repl = True
    else:
        out.append(line)
if not repl:
    out.append(f"distributionUrl=https\\://services.gradle.org/distributions/gradle-{gradle}-all.zip")
p.write_text("\n".join(out) + "\n", encoding="utf-8")
print(f"Updated {p}")
PY

# 3) Ensure plugins block has both com.android.application and com.android.library with AGP version,
#    and org.jetbrains.kotlin.android with Kotlin version.
python3 - <<'PY' "$SETTINGS" "$AGP" "$KOTLIN"
import sys, pathlib, re
settings = pathlib.Path(sys.argv[1])
agp = sys.argv[2]
kotlin = sys.argv[3]
s = settings.read_text(encoding="utf-8")

# Find plugins { ... } block (very common in Flutter's settings.gradle)
m = re.search(r'plugins\s*\{\s*([\s\S]*?)\s*\}\s*', s)
if not m:
    raise SystemExit("ERROR: plugins { } block not found in android/settings.gradle")

block = m.group(0)
inner = m.group(1)

def upsert_plugin(inner: str, plugin_id: str, version: str, apply_false: bool=True) -> str:
    # Replace existing line if present, otherwise add.
    pattern = re.compile(rf'^\s*id\s+"{re.escape(plugin_id)}"\s+version\s+"[^"]+"\s*(apply\s+false)?\s*$', re.MULTILINE)
    repl = f'    id "{plugin_id}" version "{version}"' + (' apply false' if apply_false else '')
    if pattern.search(inner):
        return pattern.sub(repl, inner)
    # Append before end
    return inner.rstrip() + "\n" + repl + "\n"

inner2 = inner
inner2 = upsert_plugin(inner2, "com.android.application", agp, True)
inner2 = upsert_plugin(inner2, "com.android.library", agp, True)
inner2 = upsert_plugin(inner2, "org.jetbrains.kotlin.android", kotlin, True)

new_block = "plugins{\n" + inner2.strip("\n") + "\n}\n"
s2 = s[:m.start()] + new_block + s[m.end():]
settings.write_text(s2, encoding="utf-8")
print("Updated plugins block in android/settings.gradle")
PY

echo "Android toolchain patch complete."
