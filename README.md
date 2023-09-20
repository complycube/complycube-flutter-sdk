# ComplyCube Flutter SDK

The ComplyCube Flutter SDK makes it quick and easy to build a frictionless customer onboarding and biometric re-authentication experience in your Flutter app. We provide powerful, smart, and customizable UI screens that can be used out-of-the-box to capture the data you need for identity verification.

> :information_source: Please get in touch with your **Account Manager** or **[support](https://support.complycube.com/hc/en-gb/requests/new)** to get access to our Mobile SDK.

## Table of contents

- [ComplyCube Flutter SDK](#complycube-flutter-sdk)
  - [Table of Contents](#table-of-contents)
  - [Features](#features)
  - [1. Requirements](#1-requirements)
    - [iOS](#ios)
    - [Android](#android)
  - [2. Installing the SDK](#2-installing-the-sdk)
    - [Flutter Package](#flutter-package)
    - [CocoaPods](#cocoapods)
    - [Android](#android-1)
  - [3. Usage](#3-usage)
    - [1. Creating a client](#1-creating-a-client)
      - [Example request](#example-request)
      - [Example response](#example-response)
    - [2. Creating an SDK token](#2-creating-an-sdk-token)
      - [Example request](#example-request-1)
      - [Example response](#example-response-1)
    - [3. Prepare stages](#3-prepare-stages)
    - [4. Client ID and token](#4-client-id-and-token)
    - [5. Widget Setup](#5-widget-setup)
    - [6. Perform checks](#6-perform-checks)
    - [7. Setup webhooks and retrieve results](#7-setup-webhooks-and-retrieve-results)
  - [4. Customization](#4-customization)
    - [Stages](#stages)
      - [Welcome stage](#welcome-stage)
      - [Consent stage](#consent-stage)
      - [Document stage](#document-stage)
      - [Selfie photo and video stage](#selfie-photo-and-video-stage)
      - [Proof of address stage](#proof-of-address-stage)
      - [Adding NFC Support](#adding-nfc-support)
    - [Appearance](#appearance)
    - [Localization](#localization)
  - [6. Result handling](#6-result-handling)
  - [7. Error handling](#7-error-handling)
  - [8. Going live](#8-going-live)
  - [Additional info](#additional-info)

## Features

<img 
	src="https://assets.complycube.com/images/complycube-ios-sdk-github.jpg" 
	alt="ComplyCube iOS SDK illustrations."
/>

**Native & intuitive UI**: We provide mobile-native screens that guide your customers in capturing their selfies, video recordings, government-issued IDs (such as passports, driving licenses, and residence permits), and proof of address documents (bank statements and utility bills)

**Liveness**: Our market-leading liveness detection provides accurate and extremely fast presence detection on your customers' selfies (3D Passive and Active) and documents to prevent fraud and protect your business. It detects and deters several spoofing vectors, including **printed photo attacks**, **printed mask attacks**, **video replay attacks**, and **3D mask attacks**.

**Auto-capture**: Our UI screens attempt to auto-capture your customer's documents and selfies and run quality checks to ensure that only legible captures are processed by our authentication service.

**Branding & customization**: You can customize the experience by adding your brand colors and text. Furthermore, screens can be added and removed.

**ComplyCube API**: Our [REST API](https://docs.complycube.com/api-reference) can be used to build entirely custom flows on top of this native mobile UI layer. We offer backend SDK libraries ([Node.js](https://www.npmjs.com/package/@complycube/api), [PHP](https://github.com/complycube/complycube-php), [Python](https://pypi.org/project/complycube/), and [.NET](https://www.nuget.org/packages/Complycube/)) to facilitate custom integrations.

**Localized**: We offer multiple localization options to fit your customer needs.

**Secure**: Our GPDR, CCPA, and ISO-certified platform ensure secure and data privacy-compliant end-to-end capture.

## Requirements

- [iOS requirements](https://github.com/complycube/complycube-ios-sdk#requirements)
- [Android requirements](https://github.com/complycube/complycube-android-sdk#requirements)

## Getting Started

### 1. Installing the SDK

#### Flutter Package

Install the ComplyCube Flutter package by adding it to your `pubspec.yaml` file:

```yaml
dependencies:
  complycube_flutter: ^latest_version
```

#### CocoaPods

1. Before using the ComplyCube SDK, install the Cocoapods Artifactory plugin by running the following command in your terminal:

   ```bash
   gem install cocoapods-art
   ```

2. To add the library, copy your repository credentials into a `.netrc` file to your home directory and setup the repository:

   ```bash
   pod repo-art add cc-cocoapods-release-local "https://complycuberepo.jfrog.io/artifactory/api/pods/cc-cocoapods-release-local"
   ```

3. Add plugin repos by adding the snippet below to the top of your `ios/PodFile` and install the pod using the `pod install` command.

   ```ruby
   plugin 'cocoapods-art', :sources => [
     'cc-cocoapods-release-local',
     'trunk'
   ]
   ...

   platform :ios, '13.0' # Or above

   target 'YourApp' do
       ...
       pod 'ComplyCube'
       ...
   end
   ```

#### Application permissions

##### iOS

Our SDK uses the device camera and microphone for capture. You must add the following keys to your application `Info.plist` file.

- `NSCameraUsageDescription`

```xml
<key>NSCameraUsageDescription</key>
<string>Used to capture facials biometrics and documents</string>
```

- `NSMicrophoneUsageDescription`

```xml
<key>NSMicrophoneUsageDescription</key>
<string>Used to capture video biometrics</string>
```

##### Android

Start by adding your access credentials for the ComplyCube SDK repository to the `gradle.properties` file of your **mobile app**:

```gradle
artifactory_user= "USERNAME"
artifactory_password= "ENCRYPTED PASS"
artifactory_contextUrl= https://complycuberepo.jfrog.io/artifactory
```

Then update your application `build.gradle` file with the ComplyCube SDK repository maven settings and SDK dependency:

```gradle
buildscript {
    ...
    repositories {
        ...
        artifactory {
            contextUrl = "${artifactory_contextUrl}"  
            resolve {
                repository {
                    repoKey = 'cc-gradle-release-local'
                    username = "${artifactory_user}"
                    password = "${artifactory_password}"
                    maven = true
                }
            }
        }
    }
    dependencies {
        ....
        //Check for the latest version here: http://plugins.gradle.org/plugin/com.jfrog.artifactory
        classpath "org.jfrog.buildinfo:build-info-extractor-gradle:4+"
        implementation "com.complycube:sdk:+"
    }
}

plugins {
    ...
    id "com.jfrog.artifactory"
}
```

### 2. Creating a client

Before launching the SDK, your app must first [create a client](https://docs.complycube.com/api-reference/clients/create-a-client) using the ComplyCube API.

A client represents the individual on whom you need to perform identity verification checks on. A client is required to generate an SDK token.

This must be done on your **mobile app backend** server.

#### Example request

```bash
curl -X POST https://api.complycube.com/v1/clients \
     -H 'Authorization: <YOUR_API_KEY>' \
     -H 'Content-Type: application/json' \
     -d '{  "type": "person",
            "email": "john.doe@example.com",
            "personDetails":{
                "firstName": "Jane",
                "lastName" :"Doe"
            }
         }'
```

#### Example response

The response will contain an id (the Client ID). It is required for the next step.

```json
{
    "id": "5eb04fcd0f3e360008035eb1",
    "type": "person",
    "email": "john.doe@example.com",
    "personDetails": {
        "firstName": "John",
        "lastName": "Doe",
    },
    "createdAt": "2023-01-01T17:24:29.146Z",
    "updatedAt": "2023-01-01T17:24:29.146Z"
}
```

### 3. Creating an SDK token

**SDK Tokens** enable clients to securely send personal data from your **mobile app** to ComplyCube.
[To learn more about our SDK Token endpoint](https://docs.complycube.com/api-reference/other-resources/tokens).

> You must generate a new token each time you initialize the ComplyCube Web SDK.

#### Example request

```bash
curl -X POST https://api.complycube.com/v1/tokens \
     -H 'Authorization: <YOUR_API_KEY>' \
     -H 'Content-Type: application/json' \
     -d '{
           "clientId":"CLIENT_ID",
           "appId": "com.complycube.SampleApp"
         }'
```

#### Example response

```json
{
    "token": "<CLIENT_TOKEN>"
}
```

### 4. Prepare the SDK stages

Initialize the `stages` in a `settings` object with the stages you wish to include so that it can be used in the Flutter component.

```dart
import 'package:complycube_flutter/ComplyCubeMobileSDK.dart';

final settings = {
  ...
  "stages": [
      {
        "name": 'intro',
        "heading": 'Green Bank ID verification',
      },
      {
        "name": 'documentCapture',
        "showGuidance": false,
        "useMLAssistance": true,
        "retryLimit": 1,
        "documentTypes": {
          "passport": true,
          "driving_license": ['GB', 'FR'],
        },
      },
      'faceCapture',
  ],
  ...
}
```

### 5. Initialize the Flutter Widget

Initialize the `settings` object by setting the SDK token, client ID, and the stages of the flow.

```dart
final settings = {
  "clientID": "<CLIENT_ID>",
  "clientToken": "<CLIENT_TOKEN>",
  "stages": [...],
  ...
}
```

You can now incorporate the ComplyCube Flutter widget into your screen.

```dart
return MaterialApp(
  home: Scaffold(
    appBar: AppBar(
      title: Text('ComplyCube Integration'),
    ),
    body: ComplyCubeWidget(settings: settings),
  ),
);
```

### 6. Perform checks

Using the results returned in the `onSuccess` callback, you can trigger your mobile backend to run the necessary checks on your client.

For example, use the result of a selfie and document capture as follows:

- `result.documentId` to run a [Document Check](https://docs.complycube.com/api-reference/check-types/document-check)

- `result.documentId` and `result.livePhotoId` to run an [Identity Check](https://docs.complycube.com/api-reference/check-types/identity-check)

#### Example response

```bash
curl -X POST https://api.complycube.com/v1/checks \
     -H 'Authorization: <YOUR_API_KEY>' \
     -H 'Content-Type: application/json' \
     -d '{
            "clientId":"CLIENT_ID",
            "type": "document_check",
            "documentId":"DOCUMENT_ID"
         }'
```

### 7. Setup webhooks and retrieve results

Our checks are asynchronous, and all results and event notifications are done via webhooks.

Follow our [webhook guide](https://docs.complycube.com/documentation/guides/webhooks) for a step-by-step walkthrough.

Your mobile backend can retrieve all check results using our API.

## 4. Customization

### Stages

Each stage in the flow can be customized to create the ideal journey for your clients. Every stage must be in the stages array in the settings object.

Stages can be a string or an object that contains the stage’s customizations.

#### Welcome stage

This is the first screen of the flow. It displays a welcome message and a summary of the stages you have configured for the client. If you would like to use a custom title and message, you can set them as follows:

```dart
final settings = {
  ...
  "stages": [
    {
        "name": 'intro',
        "heading": 'My Company Verification',
        "message": 'We will now verify your identity so you can start trading.',
      },
      ...
  ]
  ...
}
```

The welcome stage will always default to show as the first screen.

#### Consent stage

You can optionally add this stage to enforce explicit consent collection before the client can progress in the flow. The consent screen allows you to set a custom title and the consenting body.

```dart
final settings = {
  ...
  "stages": [
    {
        "name": 'consent',
        "heading": 'Terms of Service',
        "message": 'At My company, we are committed to protecting the privacy and security of our users. This privacy policy explains how we collect, use, and protect...',
      },
      ...
  ]
  ...
}
```

#### Document stage

This stage allows clients to select the type of identity document they would like to submit. You can customize these screens to:

- Limit the scope of document types the client can select, e.g., Passport only.
- Set the document issuing countries they are allowed for each document type.
- Add or remove automated capture using smart assistance.
- Show or hide the instruction screens before capture.
- Set a retry limit to allow clients to progress the journey regardless of capture quality.

> If you provide only one document type, the document type selection screen will be skipped. The country selection screen will be skipped if you provide only a single country for a given document type.

You can remove the information screens shown before camera captures by enabling or disabling guidance. You should only consider omitting this if you have clearly informed your customer of the capture steps required.

> :warning: Please note the retryLimit you set here will take precedence over the retry limit that has been set globally in the [developer console](https://portal.complycube.com/automations).

```dart
final settings = {
  ...
  "stages": [
    ...
   {
        "name": 'documentCapture',
        "showGuidance": false,
        "useMLAssistance": true,
        "retryLimit": 1,
        "liveCapture": false,
        "documentTypes": {
          "passport": true,
          "driving_license": ['GB', 'US'],
        },
      },
      ...
  ]
  ...
}
```

#### Selfie photo and video stage

You can request a selfie photo ([live photo](https://docs.complycube.com/api-reference/live-photos)) capture or video ([live video](https://docs.complycube.com/api-reference/live-videos)) capture from your customer.

```dart
final settings = {
  ...
  "stages": [
    ...
   {
        "name": 'faceCapture',
        "mode": 'photo', // Or video
        "useMLAssistance": false
    },
      ...
  ]
  ...
}
```

#### Proof of address stage

When requesting a proof of address document, you can set the allowed document type and whether the client can upload the document. When liveCapture is set to false, the client will be forced to perform a live capture.

```dart
final settings = {
  ...
  "stages": [
    ...
   {
        "name": 'poaCapture',
        "liveCapture": false
    },
      ...
  ]
  ...
}
```

#### Adding NFC Support
To add NFC support to a document stage for some document types you need to add the following to your settings object:

```dart
final settings = {
  ...
  "stages": [
    ...
   {
        "name": 'documentCapture',
        "showGuidance": false,
        "useMLAssistance": true,
        "retryLimit": 1,
        "liveCapture": false,
        "documentTypes": {
          "passport": true,
          "driving_license": ['GB', 'US'],
        },
        "nfcCapture": true // Add this line to enable NFC
      },
      ...
  ]
  ...
}
```

### Appearance

The SDK allows you to set colors, button radius, and force a specific theme whether it's `dark` or `light` to match your existing application or brand. 

You can customize the colors by setting the relevant values when building your flow. You also have to put it in the settings object:

```dart
final settings = {
  ...
  "lookAndFeel": {
    "colors": {
        "primaryButtonBgColor": '#FFFFFF',
        },
    "theme": "dark",
    "buttonRadius": 10,
  }
}
```

Available properties for color customization:

| Property                       | Description                                     | 
| ------------------------------ | ----------------------------------------------- |
| primaryButtonBgColor           | Primary action button background color          |
| primaryButtonPressedBgColor    | Primary action button pressed background color  |
| primaryButtonTextColor         | Primary action button text color                |
| primaryButtonBorderColor       | Primary action button border color              |
| secondaryButtonBgColor         | Secondary button background color               |
| secondaryButtonPressedBgColor  | Primary action button pressed background color  |
| secondaryButtonTextColor       | Secondary action button text color              |
| secondaryButtonBorderColor     | Secondary action button border color            |
| docTypeBgColor                 | Document type selection button color            |
| docTypeBorderColor             | Document type selection button border color     |
| docTypeTextColor               | Document type title text color                  |
| headerTitle                    | Title heading text color                        |
| subheaderTitle                 | Subheading text color                           |
| linkButtonTextColor            | Links color                                     |


Available properties for `theme` customization:

| Property                       | Description                                     |
| ------------------------------ | ----------------------------------------------- |
| inherit                        | Inherit actual device (default)                 |
| light                          | Light theme                                     |
| dark                           | Dark theme                                      |

### Localization

The SDK provides multiple languages support. You can set the language by setting the `languages` property in the settings object:

```dart
final settings = {
  ...
  "language": ["fr"]
}
```

Supported languages:
- English - en 🇬🇧
- French - fr 🇫🇷
- German - de 🇩🇪
- Italian - it 🇮🇹
- Spanish - es 🇪🇸
- Arabic - ar 🇦🇪
- Dutch(Netherland) - nl 🇳🇱
- Norwegian - no 🇳🇴
- Polish - pl 🇵🇱
- Portuguese - pt 🇵🇹
- Swedish - sv 🇸🇪
- Chinese - zh 🇨🇳



## 6. Result handling

To handle result callbacks, you can use the `onSuccess`, `onCancelled`, and `onError` callbacks provided by the ComplyCube widget:

```dart
void onSuccess(Map<String, dynamic> results) {
  final documentId = results["documentIds"][0];
  final selfieId = results["livePhotoIds"][0];
  sendToServer(documentId, selfieId); // Send the IDs to your server to perform checks

}


...

ComplyCubeWidget(
  settings: settings,
  onSuccess: onSuccess,
  onCancelled: onCancelled,
  onError: onError,
),
```

Upon an `onSuccess` callback, you can create check requests using the captured data. The IDs of the uploaded resources are returned in the `results` parameter, which is a Dart Map.

For example, our default flow, which includes an Identity Document, a Selfie (Live Photo), and Proof of Address, would have a `results` parameter with `"documentIds": ["xxxxx"]`, `"livePhotoIds": ["xxxxx"]`, "liveVideoIds": ["xxxxxx"] and `"poaIds": ["xxxxxx"]`.

## 7. Error handling

If the SDK experiences any issues, an `ComplyCubeError` object is returned with a string description and the error code as `ComplyCubeErrorCode`.

You can implement the error handling as follows:

```dart
void onCancelled() {
  print("The user cancelled");
  
}


void onError(ComplyCubeError error) {
    // Managing errors based on code
  switch (error.code) {
    case ComplyCubeErrorCode.deleted_resource:
      print("The resource has been deleted")
      break;
    case ComplianceErrorCode.limit_rate:
        print("The rate limit has been reached")
      break;
    // Add more cases for other error codes
    default:
      print("An error has occurred")
  }
}
```

The following error codes are available:

| Error code                    | Description                                                                 |
| ----------------------------- | ----------------------------------------------------------------------------|
| resource_not_found            | The requested resource is deleted.                                          |
| unauthorized                  | The 'Authorization' header is invalid                                       |
| invalid_request               | A parameter has been missing                                                |
| rate_limit_exceeded           | The rate limit has been reached                                             |
| internal_server_error         | An internal server error has occurred                                       | 

## 8. Going live

Check out our handy [integration checklist here](https://docs.complycube.com/documentation/guides/integration-checklist) before you go live.

## Additional info

You can find our full [API reference here](https://docs.complycube.com/api-reference), and our guides and example flows can be found [here](https://docs.complycube.com/documentation/).
