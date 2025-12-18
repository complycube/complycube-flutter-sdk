#!/usr/bin/env bash

# Simple environment doctor script for the ComplyCube Flutter sample.
#
# This script performs a series of checks to help you diagnose common
# environment issues when working with the Flutter sample app. It is
# designed for macOS and Linux. Windows users may run it under WSL or
# adapt the logic in a PowerShell script.

set -euo pipefail

# ANSI colour codes for nicer terminal output
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
BOLD="\033[1m"
RESET="\033[0m"

# Print a section header
function header() {
  printf "\n${BOLD}%s${RESET}\n" "$1"
}

# Print a key/value pair
function kv() {
  printf "  %-25s : %s\n" "$1" "$2"
}

# Print an OK message
function ok() {
  printf "${GREEN}✔ %s${RESET}\n" "$1"
}

# Print a warning message
function warn() {
  printf "${YELLOW}⚠ %s${RESET}\n" "$1"
}

# Print an error message
function err() {
  printf "${RED}✖ %s${RESET}\n" "$1"
}

# Print a suggested fix (one-liners)
function fix() {
  # Usage: fix "Title" "cmd1" "cmd2" ...
  local title="$1"; shift || true
  printf "  ${YELLOW}Fix:${RESET} %s\n" "$title"
  for cmd in "$@"; do
    printf "       %s\n" "$cmd"
  done
}

# Check if a command exists
function check_command() {
  if command -v "$1" >/dev/null 2>&1; then
    ok "$1 is installed"
  else
    err "$1 is not installed or not on PATH"
    return 1
  fi
}

# Extract the version number from a Java version string
function parse_java_version() {
  local version_line="$1"
  # Examples:
  # java version "17.0.9" 2024-10-15 LTS
  # openjdk version "21.0.1" 2023-10-17
  if [[ $version_line =~ ([0-9]+)\.([0-9]+)\.([0-9]+) ]]; then
    echo "${BASH_REMATCH[1]}"
  fi
}

# Compare dotted versions (e.g. 8.6.0) without relying on sort -V.
# Returns 0 if a >= b
function version_ge() {
  local a="$1" b="$2"
  local IFS='.'
  local a1 a2 a3 b1 b2 b3
  read -r a1 a2 a3 <<<"$a"
  read -r b1 b2 b3 <<<"$b"
  a2=${a2:-0}; a3=${a3:-0}
  b2=${b2:-0}; b3=${b3:-0}
  if (( a1 > b1 )); then return 0; fi
  if (( a1 < b1 )); then return 1; fi
  if (( a2 > b2 )); then return 0; fi
  if (( a2 < b2 )); then return 1; fi
  if (( a3 >= b3 )); then return 0; else return 1; fi
}

function recommended_agp_for_compile_sdk() {
  # Best-effort mapping based on Android's published minimums.
  # compileSdk is an integer API level.
  local sdk="$1"
  case "$sdk" in
    33) echo "7.2.0";;
    34) echo "8.1.1";;
    35) echo "8.6.0";;
    36) echo "8.9.1";;
    *) echo "";;
  esac
}

# Main execution starts here

header "Flutter Doctor Check"
if command -v flutter >/dev/null 2>&1; then
  # Show a truncated flutter doctor output
  flutter doctor -v
  ok "flutter command is available"
else
  err "flutter is not installed or not on PATH"
  fix "Install Flutter and ensure it's on PATH" \
      "Follow: https://docs.flutter.dev/get-started/install" \
      "Then run: flutter --version" \
      "Then run: flutter doctor -v"
fi

header "Java / JDK"
if command -v java >/dev/null 2>&1; then
  java_version_output=$(java -version 2>&1 | head -n1)
  java_major=$(parse_java_version "$java_version_output" || true)
  kv "Java version" "$java_version_output"
  if [[ -n "$java_major" ]]; then
    if (( java_major >= 17 && java_major <= 21 )); then
      ok "Supported JDK version detected (>=17 <=21)"
    else
      warn "JDK $java_major detected. For modern Android toolchains we recommend JDK 17 (or 21 for experimental features)."
      fix "Install and use JDK 17" \
          "macOS (Homebrew): brew install openjdk@17" \
          "Ubuntu/Debian: sudo apt-get update && sudo apt-get install -y openjdk-17-jdk" \
          "Verify: java -version"
    fi
  fi
else
  err "Java is not installed or not on PATH"
  fix "Install JDK 17 and ensure java is on PATH" \
      "macOS (Homebrew): brew install openjdk@17" \
      "Ubuntu/Debian: sudo apt-get update && sudo apt-get install -y openjdk-17-jdk" \
      "Verify: java -version"
fi

if [[ -n "${JAVA_HOME:-}" ]]; then
  kv "JAVA_HOME" "$JAVA_HOME"
else
  warn "JAVA_HOME is not set; Flutter will fall back to Android Studio's embedded JDK if available"
  fix "Set JAVA_HOME (recommended)" \
      "macOS: export JAVA_HOME=\"\$(/usr/libexec/java_home -v 17)\"" \
      "Linux: export JAVA_HOME=\"\$(dirname \$(dirname \$(readlink -f \$(which java))))\"" \
      "Re-run: java -version"
fi

header "Gradle Wrapper"
WRAPPER_FILE="android/gradle/wrapper/gradle-wrapper.properties"
if [[ -f "$WRAPPER_FILE" ]]; then
  kv "Found" "$WRAPPER_FILE"
  dist_line=$(grep -E '^distributionUrl' "$WRAPPER_FILE" || true)
  if [[ -n "$dist_line" ]]; then
    # Extract version (e.g. gradle-8.4-all.zip -> 8.4)
    if [[ $dist_line =~ gradle-([0-9]+\.[0-9]+\.?[0-9]*) ]]; then
      gradle_ver="${BASH_REMATCH[1]}"
      kv "Gradle version (wrapper)" "$gradle_ver"
      # Provide a simple recommendation if using Gradle <8.0
      ver_major=${gradle_ver%%.*}
      if (( ver_major < 8 )); then
        warn "Gradle $gradle_ver detected. Consider upgrading to Gradle 8.x for modern AGP compatibility."
        fix "Upgrade Gradle Wrapper (choose a version compatible with your AGP)" \
            "cd android" \
            "./gradlew wrapper --gradle-version 8.13 --distribution-type all" \
            "cd .."
      else
        ok "Gradle wrapper version looks OK"
      fi
    else
      warn "Could not parse Gradle version from distributionUrl"
    fi
  fi
else
  warn "Gradle wrapper file not found at $WRAPPER_FILE"
  fix "Ensure you are in the sample app repository root" \
      "Confirm this file exists: android/gradle/wrapper/gradle-wrapper.properties" \
      "If android/ is missing entirely, re-clone the repo. (As a last resort you can regenerate platform folders with: flutter create .)"
fi

header "Android Gradle Plugin (AGP)"
AGP_VERSION=""
SETTINGS_GRADLE="android/settings.gradle"
if [[ -f "$SETTINGS_GRADLE" ]]; then
  # Try to extract the plugin version from the plugins block
  agp_line=$(grep -Eo 'com\.android\.application"[[:space:]]+version[[:space:]]+"[0-9]+\.[0-9]+\.[0-9]+"' "$SETTINGS_GRADLE" || true)
  if [[ -n "$agp_line" ]]; then
    AGP_VERSION=$(echo "$agp_line" | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+')
  else
    # Fallback to build.gradle (Groovy) search
    ROOT_BUILD="android/build.gradle"
    if [[ -f "$ROOT_BUILD" ]]; then
      agp_line=$(grep -E "com.android.tools.build:gradle" "$ROOT_BUILD" | head -n1 || true)
      AGP_VERSION=$(echo "$agp_line" | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+')
    fi
  fi
  if [[ -n "$AGP_VERSION" ]]; then
    kv "AGP version" "$AGP_VERSION"
    # Best-effort check: warn if AGP is below the minimum suggested for compileSdk.
    if [[ -f "android/app/build.gradle" ]]; then
      local_compile_sdk=$(grep -Eo 'compileSdkVersion[[:space:]]+[0-9]+' "android/app/build.gradle" | grep -Eo '[0-9]+' | head -n1 || true)
      if [[ -n "$local_compile_sdk" ]]; then
        rec_agp=$(recommended_agp_for_compile_sdk "$local_compile_sdk")
        if [[ -n "$rec_agp" ]] && ! version_ge "$AGP_VERSION" "$rec_agp"; then
          warn "AGP $AGP_VERSION may be too low for compileSdk $local_compile_sdk (suggested minimum: $rec_agp)."
          fix "Upgrade AGP in android/settings.gradle" \
              "Open: android/settings.gradle" \
              "Update plugins block: id \"com.android.application\" version \"$rec_agp\" apply false" \
              "Then run: flutter clean && flutter pub get && flutter run"
          warn "If you are targeting Android API 36.1 previews, you may need AGP 8.13.x."
        else
          ok "AGP version looks compatible with compileSdk (best effort)"
        fi
      fi
    fi
  else
    warn "Could not detect Android Gradle Plugin version from settings.gradle or build.gradle"
    fix "Declare AGP in android/settings.gradle" \
        "In the plugins block, add something like:" \
        "  id \"com.android.application\" version \"8.6.0\" apply false" \
        "Then re-run: flutter run"
  fi
else
  warn "$SETTINGS_GRADLE not found. Are you in the repository root?"
  fix "Run this script from the Flutter project root" \
      "You should see pubspec.yaml and android/ in the current directory" \
      "Then run: ./scripts/doctor.sh"
fi

header "Android SDK Versions"
APP_BUILD="android/app/build.gradle"
if [[ -f "$APP_BUILD" ]]; then
  compile_sdk=$(grep -Eo 'compileSdkVersion[[:space:]]+[0-9]+' "$APP_BUILD" | grep -Eo '[0-9]+' | head -n1 || true)
  target_sdk=$(grep -Eo 'targetSdkVersion[[:space:]]+[0-9]+' "$APP_BUILD" | grep -Eo '[0-9]+' | head -n1 || true)
  min_sdk=$(grep -Eo 'minSdkVersion[[:space:]]+[0-9]+' "$APP_BUILD" | grep -Eo '[0-9]+' | head -n1 || true)
  if [[ -n "$compile_sdk" ]]; then kv "compileSdkVersion" "$compile_sdk"; else warn "compileSdkVersion not found"; fi
  if [[ -n "$target_sdk" ]]; then kv "targetSdkVersion" "$target_sdk"; else warn "targetSdkVersion not found"; fi
  if [[ -n "$min_sdk" ]]; then kv "minSdkVersion" "$min_sdk"; else warn "minSdkVersion not found"; fi

  # Check Android SDK location and whether the required platform is installed
  ANDROID_SDK="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-}}"
  if [[ -n "$ANDROID_SDK" ]]; then
    kv "Android SDK path" "$ANDROID_SDK"
    if [[ -n "$compile_sdk" ]] && [[ ! -d "$ANDROID_SDK/platforms/android-$compile_sdk" ]]; then
      warn "Android SDK platform android-$compile_sdk not found under your SDK path."
      fix "Install the required Android platform" \
          "Android Studio: Settings/Preferences > Android SDK > install Android $compile_sdk" \
          "Or CLI (if sdkmanager available): sdkmanager \"platforms;android-$compile_sdk\"" \
          "Then: flutter clean && flutter run"
    else
      ok "Android SDK platform looks OK (best effort)"
    fi
  else
    warn "ANDROID_SDK_ROOT/ANDROID_HOME not set. Flutter may still work via Android Studio configuration, but explicit SDK path helps."
    fix "Ensure Android SDK is installed and configured" \
        "Install Android Studio (recommended)" \
        "Set ANDROID_SDK_ROOT (example): export ANDROID_SDK_ROOT=\"$HOME/Android/Sdk\"" \
        "Then re-run: flutter doctor -v"
  fi
else
  warn "$APP_BUILD not found. Cannot parse SDK versions."
  fix "Ensure you're in the sample app root (android/app/build.gradle exists)" \
      "From repo root, run: flutter pub get" \
      "If platform folders are missing, regenerate with: flutter create ."
fi

header "Kotlin & Gradle Plugins"
if [[ -f "$SETTINGS_GRADLE" ]]; then
  kotlin_version_line=$(grep -E 'kotlin-(android|multiplatform)' -n "$SETTINGS_GRADLE" || true)
  if [[ -n "$kotlin_version_line" ]]; then
    kv "Kotlin plugin" "$kotlin_version_line"
  else
    # Check root build.gradle for plugin version
    if [[ -f "android/build.gradle" ]]; then
      kotlin_line=$(grep -E "org.jetbrains.kotlin:kotlin-gradle-plugin" "android/build.gradle" | head -n1 || true)
      if [[ -n "$kotlin_line" ]]; then
        kotlin_version=$(echo "$kotlin_line" | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' || true)
        kv "Kotlin version" "$kotlin_version"
      else
        warn "Kotlin plugin version not found"
      fi
    fi
  fi
else
  warn "Cannot inspect Kotlin plugin without $SETTINGS_GRADLE"
fi

header "iOS (macOS only)"
if [[ "$(uname)" == "Darwin" ]]; then
  if command -v pod >/dev/null 2>&1; then
    pod_version=$(pod --version)
    kv "CocoaPods version" "$pod_version"
  else
    warn "CocoaPods (pod) is not installed. Run 'sudo gem install cocoapods' or use Homebrew."
    fix "Install CocoaPods" \
        "macOS (RubyGems): sudo gem install cocoapods" \
        "macOS (Homebrew): brew install cocoapods" \
        "Then: cd ios && pod install && cd .."
  fi
fi

header "Summary"
echo "If any of the items above are marked with a warning (⚠) or error (✖), please review the accompanying notes and adjust your setup accordingly."
echo "This script is a helper and does not modify your system."

exit 0
