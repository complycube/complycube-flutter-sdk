# ComplyCube Example App (Flutter)

A public sample app demonstrating how to integrate and run the ComplyCube Flutter SDK end-to-end:
document capture (ID + proof of address) and selfie/biometrics.

> If you're looking to integrate the SDK into your own app, see the integration guide:
> https://docs.complycube.com/documentation/guides/mobile-sdk-guide/mobile-sdk-integration-guide

### Table of contents
- [Quick start](#quick-start)
- [Prerequisites](#prerequisites)
    - [Android](#android-prerequisites)
    - [iOS](#ios-prerequisites)
- [Validate your environment](#validate-your-environment)
- [Configure the sample (Client ID + SDK Token)](#configure-the-sample-client-id--sdk-token)
- [Run the app](#run-the-app)
    - [Run on Android](#run-on-android)
    - [Run on iOS](#run-on-ios)
- [FAQ / Troubleshooting](#faq--troubleshooting)
- [Compatibility matrix](#compatibility-matrix)
- [Support](#support)
- [About ComplyCube](#about-complycube)

## Quick start
1. Install dependencies:
   ```bash
   flutter pub get
   ```
2.  Configure credentials (Client ID + SDK token):  
    See [Configure the sample](https://chatgpt.com/g/g-p-67c097874ac88191a0678d1da269ba72-flutter/c/694271d6-b2e8-8327-a416-417f0d15d5bc#configure-the-sample-client-id--sdk-token)

3.  Run:
    ```bash
    flutter run
    ```
## Prerequisites

> **Supported Flutter versions:** TODO (we will link to the compatibility matrix once created)

### Android prerequisites

-   Flutter SDK installed and on PATH:

    ```bash
    flutter --version
    ```

-   Android Studio installed (for Android SDK + emulator tooling)

-   **JDK installed and configured** (recommended: JDK 17 for modern Android toolchains)

    ```bash
    java -version
    ```

-   Android SDK components installed:

    -   Android SDK Platform (matching the sample’s `compileSdk`)

    -   Build-tools (matching the sample’s build-tools version)

    -   Platform-tools

-   Android licenses accepted:

    ```bash
    flutter doctor --android-licenses
    ```


### iOS prerequisites (macOS only)

-   Xcode installed + command line tools

-   CocoaPods installed:

    ```bash
    pod --version
    ```


## Validate your environment

Run Flutter’s built-in diagnostics first:

```bash
flutter doctor -v
```
Then run the sample’s environment checks (recommended):

### macOS / Linux

```bash
chmod +x ./scripts/doctor.sh
./scripts/doctor.sh
```

### Windows (PowerShell)

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\doctor.ps1
```

## Configure the sample (Client ID + SDK Token)

You need two values from the ComplyCube API:

1.  Create a Client ID:  
    [https://docs.complycube.com/documentation/guides/mobile-sdk-guide/mobile-sdk-integration-guide#id-2.-create-a-client](https://docs.complycube.com/documentation/guides/mobile-sdk-guide/mobile-sdk-integration-guide#id-2.-create-a-client)

2.  Generate an SDK token:  
    [https://docs.complycube.com/documentation/guides/mobile-sdk-guide/mobile-sdk-integration-guide#id-3.-generate-an-sdk-token](https://docs.complycube.com/documentation/guides/mobile-sdk-guide/mobile-sdk-integration-guide#id-3.-generate-an-sdk-token)


### Option A (simple): update `main.dart`

Open `lib/main.dart` and replace:

-   `CLIENT_ID`

-   `SDK_TOKEN`


> Do not commit real credentials.

## Run the app

### Run on Android

1.  Start an emulator in Android Studio **or** connect a device with USB debugging enabled.

2.  Confirm a device is visible:

    ```bash
    flutter devices
    ```

3.  Run:

    ```bash
    flutter run
    ```


#### Build APK (optional)

```bash
flutter build apk
```

### Run on iOS

1.  Install pods (first time, or after dependency changes):

    ```bash
    cd ios
    pod install
    cd ..
    ```

2.  Run:

    ```bash
    flutter run
    ```

## FAQ / Troubleshooting

### “Android toolchain” issues in `flutter doctor`

Run:

```bash
flutter doctor -v
flutter doctor --android-licenses
```

Ensure Android SDK + platform tools are installed.

### JDK / Gradle / AGP mismatch errors

Symptoms include:

-   “Unsupported class file major version…”

-   “Gradle version is incompatible with Java…”

-   “Android Gradle plugin requires Java…”


Fix approach:

1.  Check JDK version:

    ```bash
    java -version
    ```

2.  Use JDK 17 (recommended for modern Android Gradle Plugin setups).

3.  Re-run:

    	```bash
    	chmod +x ./scripts/doctor.sh
    	./scripts/doctor.sh
    	```
    ### OR
    ```powershell
    powershell -ExecutionPolicy Bypass -File .\scripts\doctor.ps1
    ```


### “Execution failed for task …:androidJdkImage” / jlink errors

Often caused by Android Studio shipping a newer JDK than your build expects. Use JDK 17 and ensure Gradle/AGP versions align (see compatibility matrix).

### CocoaPods / iOS build failures

Try:

```bash
cd ios
pod repo update
pod install
cd ..
flutter clean
flutter pub get
flutter run
```

### “Works on my machine” differences

This repo uses the Gradle Wrapper (`android/gradlew`) to keep Gradle consistent between machines. Avoid running system Gradle directly.

## Compatibility matrix

See: `COMPATIBILITY.md` (TODO: add in Task 3)

This document lists the Flutter + Android build toolchain combinations that are tested in CI.

## Support

- 📌 Compatibility Matrix: [COMPATIBILITY.md](./COMPATIBILITY.md)

If you hit an issue:

1.  Run:

    ```bash
    flutter doctor -v
    ./scripts/doctor.sh
	or
	powershell -ExecutionPolicy Bypass -File .\scripts\doctor.ps1
    ```

2.  Open a GitHub issue and include:

    -   OS + CPU architecture

    -   Flutter version (`flutter --version`)

    -   Output of `flutter doctor -v`

    -   The exact error log + steps to reproduce

## About ComplyCube

[ComplyCube](https://www.complycube.com/en) is an award-winning SaaS & API platform renowned for its advanced Identity Verification (IDV), Anti-Money Laundering (AML), and Know Your Customer (KYC) compliance solutions. Its broad customer base includes sectors like financial services, transport, healthcare, e-commerce, cryptocurrency, FinTech, and telecoms, reinforcing its status as a global leader in IDV.

As an ISO-certified platform, ComplyCube is praised for its speedy omnichannel integration and extensive service offerings, including Low/No-Code solutions, powerful API, Mobile SDKs, Client Libraries, and seamless CRM integrations.