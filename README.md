# ComplyCube Example App

This repository provides a pre-built UI that uses the ComplyCube SDK. It guides you through the ComplyCube identity verification process, which includes collecting client ID documents, proof of address documents, and biometric selfies.

> :information_source: Please get in touch with your **Account Manager** or **[support](https://support.complycube.com/hc/en-gb/requests/new)** to get access to our Mobile SDK.

## To run the app

### Installing Flutter dependencies

#### Add Repository Token for Dart

1. To access the ComplyCube repository, you must add a repository token. Run the following command in your terminal:

```bash
dart pub token add "https://complycuberepo.jfrog.io/artifactory/api/pub/cc-pub-release-local"
```

After executing the command, you will need to add the token provided by the jFrog repository.

#### Install Dart packages

1. To install the required Dart packages, run the following command:

```bash
dart pub get
```

### Install CocoaPods

1. Before using the ComplyCube SDK, install the CocoaPods Artifactory plugin by running the following command in your terminal:

   ```bash
   gem install cocoapods-art
   ```

2. To add the library, copy your repository credentials into a `.netrc` file to your home directory and setup the repository:

   ```bash
   pod repo-art add cc-cocoapods-release-local "https://complycuberepo.jfrog.io/artifactory/api/pods/cc-cocoapods-release-local"
   ```

### Add Artifactory Credentials for Gradle

1. In the `android/gradle.properties` file, replace `ARTIFACTORY_USER` and `ARTIFACTORY_PASSWORD` with your JFrog Username and the encrypted JFrog Password.

### Run the apps

1. [Create a Client ID](https://docs.complycube.com/documentation/guides/mobile-sdk-guide/mobile-sdk-integration-guide#id-2.-create-a-client).
2. [Generate an SDK token](https://docs.complycube.com/documentation/guides/mobile-sdk-guide/mobile-sdk-integration-guide#id-3.-generate-an-sdk-token).
3. In the `main.dart` file, replace `CLIENT_ID` and `SDK_TOKEN` with the generated values from the previous steps.
4. Run the Android app:

   ```bash
   flutter run
   ```

5. Run the iOS app:

   ```bash
    flutter run -d ios
   ```

## Integrating our SDK

For detailed instructions on integrating our SDK, please refer to our [integration guide](https://docs.complycube.com/documentation/guides/mobile-sdk-guide/mobile-sdk-integration-guide).

For an overview of our core platform and its multiple features, please refer to our [user guide](https://docs.complycube.com) or browse the [API reference](https://docs.complycube.com/api-reference) for fine-grained documentation of all our services.


## About ComplyCube

[ComplyCube](https://www.complycube.com/en) is an award-winning SaaS & API platform renowned for its advanced Identity Verification (IDV), Anti-Money Laundering (AML), and Know Your Customer (KYC) compliance solutions. Its broad customer base includes sectors like financial services, transport, healthcare, e-commerce, cryptocurrency, FinTech, and telecoms, reinforcing its status as a global leader in IDV.
As an ISO-certified platform, ComplyCube is praised for its speedy omnichannel integration and extensive service offerings, including Low/No-Code solutions, powerful API, Mobile SDKs, Client Libraries, and seamless CRM integrations.
