#!/usr/bin/env bash
set -euo pipefail

# Collects toolchain versions and resolved SDK values into JSON (stdout).
# Usage:
#   ./scripts/ci/collect_versions.sh --platform android|ios --row-id <id>

PLATFORM=""
ROW_ID=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --platform) PLATFORM="$2"; shift 2;;
    --row-id) ROW_ID="$2"; shift 2;;
    *) echo "Unknown arg: $1"; exit 2;;
  esac
done

if [[ -z "$PLATFORM" || -z "$ROW_ID" ]]; then
  echo "ERROR: --platform and --row-id are required"
  exit 1
fi

runner_os="$(uname -a | tr -d '\n')"

flutter_version="$(flutter --version 2>/dev/null | head -n1 | tr -d '\r' || true)"
dart_version="$(flutter --version 2>/dev/null | grep -E 'Dart ' | head -n1 | sed -E 's/.*Dart ([0-9]+\.[0-9]+\.[0-9]+).*/\1/' || true)"

java_version="$(java -version 2>&1 | head -n1 | tr -d '\r' || true)"

agp_version=""
kotlin_version=""
gradle_version=""

# Parse AGP and Kotlin from android/settings.gradle if present
if [[ -f android/settings.gradle ]]; then
  agp_version="$(grep -Eo 'id \"com\\.android\\.(application|library)\" version \"[0-9]+\\.[0-9]+\\.[0-9]+\"' android/settings.gradle | head -n1 | grep -Eo '[0-9]+\\.[0-9]+\\.[0-9]+' || true)"
  kotlin_version="$(grep -Eo 'id \"org\\.jetbrains\\.kotlin\\.android\" version \"[0-9]+\\.[0-9]+\\.[0-9]+\"' android/settings.gradle | head -n1 | grep -Eo '[0-9]+\\.[0-9]+\\.[0-9]+' || true)"
fi

# Gradle version from wrapper properties
if [[ -f android/gradle/wrapper/gradle-wrapper.properties ]]; then
  gradle_version="$(grep -Eo 'gradle-[0-9]+\\.[0-9]+(\\.[0-9]+)?' android/gradle/wrapper/gradle-wrapper.properties | head -n1 | sed 's/gradle-//' || true)"
fi

android_triplet=""
if [[ "$PLATFORM" == "android" ]]; then
  # Evaluate Gradle to get resolved SDK triplet using init script.
  if [[ -x android/gradlew ]]; then
    set +e
    out="$(cd android && ./gradlew -q -I ../scripts/ci/print_android_config.init.gradle :app:help 2>/dev/null)"
    set -e
    c="$(echo "$out" | grep -E '^CC_ANDROID_CONFIG::compileSdk=' | tail -n1 | cut -d= -f2 || true)"
    t="$(echo "$out" | grep -E '^CC_ANDROID_CONFIG::targetSdk=' | tail -n1 | cut -d= -f2 || true)"
    m="$(echo "$out" | grep -E '^CC_ANDROID_CONFIG::minSdk=' | tail -n1 | cut -d= -f2 || true)"
    if [[ -n "$c" || -n "$t" || -n "$m" ]]; then
      android_triplet="${c:-} / ${t:-} / ${m:-}"
    fi
  fi
fi

xcode_version=""
swift_version=""
cocoapods_version=""
ruby_version=""

if [[ "$PLATFORM" == "ios" ]]; then
  xcode_version="$(xcodebuild -version 2>/dev/null | tr '\n' ' ' | sed -E 's/  +/ /g' | sed -E 's/ $//' || true)"
  swift_version="$(swift --version 2>/dev/null | head -n1 | tr -d '\r' || true)"
  cocoapods_version="$(pod --version 2>/dev/null | tr -d '\r' || true)"
  ruby_version="$(ruby --version 2>/dev/null | tr -d '\r' || true)"
fi

python3 - <<PY
import json, time
print(json.dumps({
  "row_id": "${ROW_ID}",
  "runner_os": ${runner_os!r},
  "flutter_version": ${flutter_version!r},
  "dart_version": ${dart_version!r},
  "java_version": ${java_version!r},
  "agp_version": ${agp_version!r},
  "kotlin_version": ${kotlin_version!r},
  "gradle_version": ${gradle_version!r},
  "android_sdk_triplet": ${android_triplet!r},
  "xcode_version": ${xcode_version!r},
  "swift_version": ${swift_version!r},
  "cocoapods_version": ${cocoapods_version!r},
  "ruby_version": ${ruby_version!r},
  "collected_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
}, indent=2))
PY
