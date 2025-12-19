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

# Make flutterSdkPath() robust + normalize includeBuild to flutterSdkPath()
python3 - <<'PY' "$SETTINGS"
import re, sys, pathlib
p = pathlib.Path(sys.argv[1])
s = p.read_text(encoding="utf-8")

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

s = re.sub(r'includeBuild\(".*?/packages/flutter_tools/gradle"\)',
           r'includeBuild("${flutterSdkPath()}/packages/flutter_tools/gradle")',
           s)
s = re.sub(r'includeBuild\("\$\{flutterSdkPath\}/packages/flutter_tools/gradle"\)',
           r'includeBuild("${flutterSdkPath()}/packages/flutter_tools/gradle")',
           s)
s = re.sub(r'includeBuild\("\$\{flutterSdkPath\(\)\}/packages/flutter_tools/gradle"\)',
           r'includeBuild("${flutterSdkPath()}/packages/flutter_tools/gradle")',
           s)

p.write_text(s, encoding="utf-8")
PY

# Update Gradle wrapper distributionUrl
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

# Update plugins block versions
python3 - <<'PY' "$SETTINGS" "$AGP" "$KOTLIN"
import sys, pathlib, re
settings = pathlib.Path(sys.argv[1])
agp = sys.argv[2]
kotlin = sys.argv[3]
s = settings.read_text(encoding="utf-8")

m = re.search(r'plugins\s*\{\s*([\s\S]*?)\s*\}\s*', s)
if not m:
    raise SystemExit("ERROR: plugins { } block not found in android/settings.gradle")

inner = m.group(1)

def upsert(inner: str, plugin_id: str, version: str) -> str:
    pat = re.compile(rf'^\s*id\s+\"{re.escape(plugin_id)}\"\s+version\s+\"[^\"]+\"\s*(apply\s+false)?\s*$', re.MULTILINE)
    line = f'    id "{plugin_id}" version "{version}" apply false'
    if pat.search(inner):
        return pat.sub(line, inner)
    return inner.rstrip() + "\n" + line + "\n"

inner2 = inner
inner2 = upsert(inner2, "com.android.application", agp)
inner2 = upsert(inner2, "com.android.library", agp)
inner2 = upsert(inner2, "org.jetbrains.kotlin.android", kotlin)

new_block = "plugins{\n" + inner2.strip("\n") + "\n}\n"
s2 = s[:m.start()] + new_block + s[m.end():]
settings.write_text(s2, encoding="utf-8")
PY

echo "Android toolchain patch complete."
