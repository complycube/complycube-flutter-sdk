# Compatibility Matrix

This page documents the **minimum** and **recommended** development tools required to **build** and **run** the ComplyCube Flutter sample app.

It includes:
- **Baseline requirements** (what we recommend you install locally).
- A **CI-validated matrix** (generated automatically) across multiple **Flutter** versions.

## Key concepts

- **Flutter SDK version** – Flutter’s stable channel moves quickly. This repository validates against:
  - **Minimum (older stable)**: Flutter 3.27.4
  - **Recommended (project baseline)**: Flutter 3.29.3
  - **Latest stable (tracked by CI)**: Flutter 3.38.5
- **Build JDK (Android)** – the Java runtime used to **execute Gradle and the Android Gradle Plugin (AGP)**. AGP 8.x requires **Java 17+** to run.
- **AGP / Gradle wrapper** – the Android toolchain versions used by this repo live in:
  - `android/settings.gradle` (AGP + Kotlin plugin)
  - `android/gradle/wrapper/gradle-wrapper.properties` (Gradle wrapper)
- **iOS toolchain** – iOS builds require Xcode, CocoaPods and Ruby. CI records the detected versions on the macOS runner, but your local versions may differ.

## Minimum vs. recommended (baseline)

| Component | Minimum | Recommended | Notes |
| --- | --- | --- | --- |
| **Flutter SDK (stable)** | **3.27.4** | **3.29.3** | CI also tests **latest stable** (currently 3.38.5). |
| **Android Build JDK (runs Gradle/AGP)** | **17** | **17** | AGP 8.x requires Java 17+ to run. |
| **Gradle wrapper** | **8.9** | **8.9** | Use `android/gradlew` (never your system Gradle). |
| **Android Gradle Plugin (AGP)** | **8.2.2** | **8.2.2** | Repo baseline. |
| **Kotlin plugin** | **1.9.24** | **1.9.24** | Repo baseline. |
| **Android SDK – compileSdk / targetSdk** | **(resolved by Flutter)** | **35 (current)** | CI records the *resolved* values for each Flutter version. |
| **iOS deployment target** | **13.0** | **13.0** | Podfile sets `platform :ios, '13.0'`. |
| **CocoaPods** | **1.16.x** | **1.16.x** | `pod install` required before iOS build. |

---

<!-- GENERATED:START -->

> Generated matrix will be inserted here by CI.

<!-- GENERATED:END -->

## How to use this matrix

1. **Prefer the recommended versions** in the table above.
2. If you must deviate, pick a combination that is **validated as ✅ pass** in the CI table.
3. If your build fails, run the repo doctor scripts first:
  - `scripts/doctor.sh` (macOS/Linux)
  - `scripts/doctor.ps1` (Windows)
