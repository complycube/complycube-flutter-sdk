# ComplyCube Example App

This repository provides a pre-built UI that uses the ComplyCube SDK. It guides you through the ComplyCube identity verification process, which includes collecting client ID documents, proof of address documents, and biometric selfies.

## To run the app

1. [Create a Client ID](https://docs.complycube.com/documentation/guides/mobile-sdk-guide/mobile-sdk-integration-guide#id-2.-create-a-client).
2. [Generate an SDK token](https://docs.complycube.com/documentation/guides/mobile-sdk-guide/mobile-sdk-integration-guide#id-3.-generate-an-sdk-token).
3. In the `main.dart` file, replace `CLIENT_ID` and `SDK_TOKEN` with the generated values from the previous steps.

4. Install dependencies:

   ```bash
   flutter pub get
   ```

5. Navigate to the `ios/` directory and install iOS pods:

   ```bash
   cd ios
   pod install
   cd ..
   ```

6. Run the app:

   ```bash
   flutter run
   ```

## Integrating our SDK

For detailed instructions on integrating our SDK, please refer to our [integration guide](https://docs.complycube.com/documentation/guides/mobile-sdk-guide/mobile-sdk-integration-guide).

For an overview of our core platform and its multiple features, please refer to our [user guide](https://docs.complycube.com) or browse the [API reference](https://docs.complycube.com/api-reference) for fine-grained documentation of all our services.


## About ComplyCube

[ComplyCube](https://www.complycube.com/en) is an award-winning SaaS & API platform renowned for its advanced Identity Verification (IDV), Anti-Money Laundering (AML), and Know Your Customer (KYC) compliance solutions. Its broad customer base includes sectors like financial services, transport, healthcare, e-commerce, cryptocurrency, FinTech, and telecoms, reinforcing its status as a global leader in IDV.
<br>
<br>
As an ISO-certified platform, ComplyCube is praised for its speedy omnichannel integration and extensive service offerings, including Low/No-Code solutions, powerful API, Mobile SDKs, Client Libraries, and seamless CRM integrations.
