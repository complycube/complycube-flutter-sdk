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
| `android-flutter-3.27.4-jdk17` | android | 3.27.4 | Linux runnervmejwal 6.17.0-1022-azure #22-Ubuntu SMP Mon Jul 27 17:24:03 UTC 2026 x86_64 x86_64 x86_64 GNU/Linux | 17 | 8.2.2 | 8.9 | 1.8.22 |  |  |  | ❌ fail |
| `android-flutter-3.27.4-jdk21` | android | 3.27.4 | Linux runnervmejwal 6.17.0-1022-azure #22-Ubuntu SMP Mon Jul 27 17:24:03 UTC 2026 x86_64 x86_64 x86_64 GNU/Linux | 21 | 8.2.2 | 8.9 | 1.8.22 |  |  |  | ❌ fail |
| `android-flutter-3.29.3-jdk17` | android | 3.29.3 | Linux runnervmejwal 6.17.0-1022-azure #22-Ubuntu SMP Mon Jul 27 17:24:03 UTC 2026 x86_64 x86_64 x86_64 GNU/Linux | 17 | 8.2.2 | 8.9 | 1.8.22 |  |  |  | ❌ fail |
| `android-flutter-3.29.3-jdk21` | android | 3.29.3 | Linux runnervmejwal 6.17.0-1022-azure #22-Ubuntu SMP Mon Jul 27 17:24:03 UTC 2026 x86_64 x86_64 x86_64 GNU/Linux | 21 | 8.2.2 | 8.9 | 1.8.22 |  |  |  | ❌ fail |
| `android-flutter-latest-stable-jdk17` | android | stable | Linux runnervmejwal 6.17.0-1022-azure #22-Ubuntu SMP Mon Jul 27 17:24:03 UTC 2026 x86_64 x86_64 x86_64 GNU/Linux | 17 | 8.2.2 | 8.9 | 1.8.22 |  |  |  | ❌ fail |
| `android-flutter-latest-stable-jdk21` | android | stable | Linux runnervmejwal 6.17.0-1022-azure #22-Ubuntu SMP Mon Jul 27 17:24:03 UTC 2026 x86_64 x86_64 x86_64 GNU/Linux | 21 | 8.2.2 | 8.9 | 1.8.22 |  |  |  | ❌ fail |
| `ios-flutter-3.27.4` | ios | 3.27.4 | Darwin iad20-gt1022-4020f4d6-6245-4475-892c-f7b94b7a2c83-DAACC3AB7429.local 25.6.0 Darwin Kernel Version 25.6.0: Fri Jul 31 19:16:43 PDT 2026; root:xnu-12377.161.14~5/RELEASE_ARM64_VMAPPLE arm64 |  | 8.2.2 | 8.9 | 1.8.22 |  | Xcode 26.6 Build version 17F113 / Apple Swift version 6.3.3 (swiftlang-6.3.3.1.3 clang-2100.1.1.101) | 1.17.0 / ruby 3.4.10 (2026-06-30 revision 2b0b7728dc) +PRISM [arm64-darwin25] | ❌ fail |
| `ios-flutter-3.29.3` | ios | 3.29.3 | Darwin iad20-gt1026-b26413da-2d8e-46f1-8f94-994699401c9a-7EF776BCA71A.local 25.6.0 Darwin Kernel Version 25.6.0: Fri Jul 31 19:16:43 PDT 2026; root:xnu-12377.161.14~5/RELEASE_ARM64_VMAPPLE arm64 |  | 8.2.2 | 8.9 | 1.8.22 |  | Xcode 26.6 Build version 17F113 / Apple Swift version 6.3.3 (swiftlang-6.3.3.1.3 clang-2100.1.1.101) | 1.17.0 / ruby 3.4.10 (2026-06-30 revision 2b0b7728dc) +PRISM [arm64-darwin25] | ❌ fail |
| `ios-flutter-latest-stable` | ios | stable | Darwin sat12-bq167-b26bcc7a-6337-4d95-8ec9-e4faf2e3cbd1-06E950D89ECE.local 25.5.0 Darwin Kernel Version 25.5.0: Tue Jun  9 22:26:00 PDT 2026; root:xnu-12377.121.10~1/RELEASE_ARM64_VMAPPLE arm64 |  | 8.2.2 | 8.9 | 1.8.22 |  | Xcode 26.6 Build version 17F113 / Apple Swift version 6.3.3 (swiftlang-6.3.3.1.3 clang-2100.1.1.101) | 1.17.0 / ruby 3.4.10 (2026-06-30 revision 2b0b7728dc) +PRISM [arm64-darwin25] | ❌ fail |

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
