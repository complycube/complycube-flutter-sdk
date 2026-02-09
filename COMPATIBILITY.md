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

## Validated combinations (CI)

> This table is generated automatically by CI. Do not edit it manually.

| Row | Platform | Flutter | Runner OS | Build JDK | AGP | Gradle | Kotlin | Resolved compileSdk/targetSdk/minSdk | Xcode / Swift | CocoaPods / Ruby | Result |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `android-flutter-3.27.4-jdk17` | android | 3.27.4 | Linux runnervmwffz4 6.11.0-1018-azure #18~24.04.1-Ubuntu SMP Sat Jun 28 04:46:03 UTC 2025 x86_64 x86_64 x86_64 GNU/Linux | 17 | 8.2.2 | 8.9 | 1.8.22 |  |  |  | ❌ fail |
| `android-flutter-3.27.4-jdk21` | android | 3.27.4 | Linux runnervmwffz4 6.11.0-1018-azure #18~24.04.1-Ubuntu SMP Sat Jun 28 04:46:03 UTC 2025 x86_64 x86_64 x86_64 GNU/Linux | 21 | 8.2.2 | 8.9 | 1.8.22 |  |  |  | ❌ fail |
| `android-flutter-3.29.3-jdk17` | android | 3.29.3 | Linux runnervmwffz4 6.11.0-1018-azure #18~24.04.1-Ubuntu SMP Sat Jun 28 04:46:03 UTC 2025 x86_64 x86_64 x86_64 GNU/Linux | 17 | 8.2.2 | 8.9 | 1.8.22 |  |  |  | ❌ fail |
| `android-flutter-3.29.3-jdk21` | android | 3.29.3 | Linux runnervmwffz4 6.11.0-1018-azure #18~24.04.1-Ubuntu SMP Sat Jun 28 04:46:03 UTC 2025 x86_64 x86_64 x86_64 GNU/Linux | 21 | 8.2.2 | 8.9 | 1.8.22 |  |  |  | ❌ fail |
| `android-flutter-latest-stable-jdk17` | android | stable | Linux runnervmwffz4 6.11.0-1018-azure #18~24.04.1-Ubuntu SMP Sat Jun 28 04:46:03 UTC 2025 x86_64 x86_64 x86_64 GNU/Linux | 17 | 8.2.2 | 8.9 | 1.8.22 |  |  |  | ❌ fail |
| `android-flutter-latest-stable-jdk21` | android | stable | Linux runnervmwffz4 6.11.0-1018-azure #18~24.04.1-Ubuntu SMP Sat Jun 28 04:46:03 UTC 2025 x86_64 x86_64 x86_64 GNU/Linux | 21 | 8.2.2 | 8.9 | 1.8.22 |  |  |  | ❌ fail |
| `ios-flutter-3.27.4` | ios | 3.27.4 | Darwin iad20-fj926-d4c2b8bc-0bb2-4ad4-a1b7-0752ba091693-0E800A3AA0B1.local 24.6.0 Darwin Kernel Version 24.6.0: Wed Nov  5 21:32:20 PST 2025; root:xnu-11417.140.69.705.2~1/RELEASE_ARM64_VMAPPLE arm64 |  | 8.2.2 | 8.9 | 1.8.22 |  | Xcode 16.4 Build version 16F6 / Apple Swift version 6.1.2 (swiftlang-6.1.2.1.2 clang-1700.0.13.5) | 1.16.2 / ruby 3.3.10 (2025-10-23 revision 343ea05002) [arm64-darwin24] | ✅ pass |
| `ios-flutter-3.29.3` | ios | 3.29.3 | Darwin sjc20-cw714-bb3dad46-ee15-4998-ae43-903193ed0d8d-2A84C7540574.local 24.6.0 Darwin Kernel Version 24.6.0: Wed Nov  5 21:32:20 PST 2025; root:xnu-11417.140.69.705.2~1/RELEASE_ARM64_VMAPPLE arm64 |  | 8.2.2 | 8.9 | 1.8.22 |  | Xcode 16.4 Build version 16F6 / Apple Swift version 6.1.2 (swiftlang-6.1.2.1.2 clang-1700.0.13.5) | 1.16.2 / ruby 3.3.10 (2025-10-23 revision 343ea05002) [arm64-darwin24] | ✅ pass |
| `ios-flutter-latest-stable` | ios | stable | Darwin iad20-eo1208-7f3da2a7-abec-460a-8ccd-e154cecfa52f-768ADA54946C.local 24.6.0 Darwin Kernel Version 24.6.0: Wed Nov  5 21:32:20 PST 2025; root:xnu-11417.140.69.705.2~1/RELEASE_ARM64_VMAPPLE arm64 |  | 8.2.2 | 8.9 | 1.8.22 |  | Xcode 16.4 Build version 16F6 / Apple Swift version 6.1.2 (swiftlang-6.1.2.1.2 clang-1700.0.13.5) | 1.16.2 / ruby 3.3.10 (2025-10-23 revision 343ea05002) [arm64-darwin24] | ✅ pass |

### Notes
- Android rows build a Debug APK using the repo's Gradle wrapper (`android/gradlew`).
- iOS rows build with `flutter build ios --no-codesign` and run `pod install`.

<!-- GENERATED:END -->

## How to use this matrix

1. **Prefer the recommended versions** in the table above.
2. If you must deviate, pick a combination that is **validated as ✅ pass** in the CI table.
3. If your build fails, run the repo doctor scripts first:
  - `scripts/doctor.sh` (macOS/Linux)
  - `scripts/doctor.ps1` (Windows)
