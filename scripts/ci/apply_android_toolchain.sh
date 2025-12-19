#!/usr/bin/env bash
set -euo pipefail

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
LOCAL_PROPS="android/local.properties"

if [[ ! -f "$SETTINGS" ]]; then
  echo "ERROR: $SETTINGS not found. Run from repo root."
  exit 1
fi
if [[ ! -f "$WRAPPER" ]]; then
  echo "ERROR: $WRAPPER not found. Run from repo root."
  exit 1
fi

echo "Applying Android toolchain: AGP=$AGP, Kotlin=$KOTLIN, Gradle=$GRADLE"

# Ensure local.properties exists for Flutter Gradle tooling (CI).
if [[ ! -f "$LOCAL_PROPS" ]]; then
  if [[ -z "${FLUTTER_ROOT:-}" ]]; then
    echo "ERROR: android/local.properties missing and FLUTTER_ROOT is not set."
    exit 1
  fi
  {
    echo "flutter.sdk=${FLUTTER_ROOT}"
    if [[ -n "${ANDROID_SDK_ROOT:-}" ]]; then
      echo "sdk.dir=${ANDROID_SDK_ROOT}"
    elif [[ -n "${ANDROID_HOME:-}" ]]; then
      echo "sdk.dir=${ANDROID_HOME}"
    fi
  } > "$LOCAL_PROPS"
  echo "Created $LOCAL_PROPS"
fi

# 1) Normalize settings.gradle encoding + fix flutterSdkPath() + normalize includeBuild(...) safely.
python3 - <<'PY' "$SETTINGS"
import re, sys, pathlib

p = pathlib.Path(sys.argv[1])
s = p.read_text(encoding="utf-8", errors="replace")

# ---- (2) Normalize common invisible/encoding issues ----
s = s.replace("\ufeff", "")      # UTF-8 BOM
s = s.replace("\u00a0", " ")     # NBSP -> space

# Replace flutterSdkPath closure with env fallback (if present)
pattern = re.compile(r'def\s+flutterSdkPath\s*=\s*\{\s*([\s\S]*?)\s*\}\s*', re.MULTILINE)
m = pattern.search(s)
if m:
    replacement = '''def flutterSdkPath = {
        def properties = new Properties()
        def localProperties = file("local.properties")
        if (localProperties.exists()) {
            localProperties.withInputStream { properties.load(it) }
            def v = properties.getProperty("flutter.sdk")
            if (v != null && v.trim()) {
                return v
            }
        }
        def env = System.getenv("FLUTTER_ROOT") ?: System.getenv("FLUTTER_HOME")
        assert env != null && env.trim(), "flutter.sdk not set in local.properties and FLUTTER_ROOT not set"
        return env
    }'''
    s = s[:m.start()] + replacement + s[m.end():]

# Normalize includeBuild to use flutterSdkPath()
s = re.sub(r'includeBuild\(".*?/packages/flutter_tools/gradle"\)',
           r'includeBuild("${flutterSdkPath()}/packages/flutter_tools/gradle")', s)
s = re.sub(r'includeBuild\("\$\{flutterSdkPath\}/packages/flutter_tools/gradle"\)',
           r'includeBuild("${flutterSdkPath()}/packages/flutter_tools/gradle")', s)
s = re.sub(r'includeBuild\("\$\{flutterSdkPath\(\)\}/packages/flutter_tools/gradle"\)',
           r'includeBuild("${flutterSdkPath()}/packages/flutter_tools/gradle")', s)

p.write_text(s, encoding="utf-8")
PY

# 2) Update Gradle wrapper distributionUrl
python3 - <<'PY' "$WRAPPER" "$GRADLE"
import sys, pathlib
p = pathlib.Path(sys.argv[1])
gradle = sys.argv[2]
lines = p.read_text(encoding="utf-8").splitlines()
out = []
repl = False
for line in lines:
    if line.startswith("distributionUrl="):
        out.append(f"distributionUrl=https\\://services.gradle.org/distributions/gradle-{gradle}-all.zip")
        repl = True
    else:
        out.append(line)
if not repl:
    out.append(f"distributionUrl=https\\://services.gradle.org/distributions/gradle-{gradle}-all.zip")
p.write_text("\n".join(out) + "\n", encoding="utf-8")
PY

# 3) (1) Safely patch ONLY the plugins { ... } block using brace scanning (no regex that can eat other blocks).
python3 - <<'PY' "$SETTINGS" "$AGP" "$KOTLIN"
import sys, pathlib, re

settings = pathlib.Path(sys.argv[1])
agp = sys.argv[2]
kotlin = sys.argv[3]
s = settings.read_text(encoding="utf-8", errors="replace")

# ---- (2) Normalize again (defensive) ----
s = s.replace("\ufeff", "")
s = s.replace("\u00a0", " ")

# Find the "plugins {" block start
m = re.search(r'(?m)^\s*plugins\s*\{', s)
if not m:
    raise SystemExit("ERROR: plugins { } block not found in android/settings.gradle")

# Locate the opening brace '{' position
open_brace = s.find("{", m.start())
if open_brace == -1:
    raise SystemExit("ERROR: plugins block opening brace not found")

# Scan forward to find matching closing brace for this block
depth = 0
close_brace = None
for i in range(open_brace, len(s)):
    ch = s[i]
    if ch == "{":
        depth += 1
    elif ch == "}":
        depth -= 1
        if depth == 0:
            close_brace = i
            break

if close_brace is None:
    raise SystemExit("ERROR: plugins block closing brace not found (brace scan failed)")

block_header = s[m.start():open_brace+1]  # includes '{'
block_inner = s[open_brace+1:close_brace]
block_footer = s[close_brace:close_brace+1]  # '}'

lines = block_inner.splitlines()

def upsert_plugin(lines, plugin_id, version):
    # Replace any existing matching id line, else append a new one.
    pat = re.compile(rf'^\s*id\s+"{re.escape(plugin_id)}"\s+version\s+"[^"]+"\s*(apply\s+false)?\s*$', re.IGNORECASE)
    new_line = f'    id "{plugin_id}" version "{version}" apply false'
    for idx, ln in enumerate(lines):
        if pat.match(ln.strip("\r")):
            lines[idx] = new_line
            return lines
    # Insert near end (preserve spacing)
    # Put it after last existing "id ..." line if possible
    last_id = -1
    for idx, ln in enumerate(lines):
        if re.match(r'^\s*id\s+"', ln):
            last_id = idx
    insert_at = last_id + 1 if last_id != -1 else len(lines)
    lines.insert(insert_at, new_line)
    return lines

lines = upsert_plugin(lines, "com.android.application", agp)
lines = upsert_plugin(lines, "com.android.library", agp)
lines = upsert_plugin(lines, "org.jetbrains.kotlin.android", kotlin)

# Rebuild plugins block with consistent formatting
new_inner = "\n".join([ln.rstrip("\r") for ln in lines]).strip("\n")
new_block = f"{block_header}\n{new_inner}\n{block_footer}\n"

s2 = s[:m.start()] + new_block + s[close_brace+1:]
settings.write_text(s2, encoding="utf-8")
PY

echo "Android toolchain patch complete."
