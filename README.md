# ComplyCube Example App

This repository provides a pre-built UI that uses the ComplyCube SDK. It guides you through the ComplyCube identity verification process, which includes collecting client ID documents, proof of address documents, and biometric selfies.

> :information_source: Please get in touch with your **Account Manager** or **[support](https://support.complycube.com/hc/en-gb/requests/new)** to get access to our Mobile SDK.

## To run the app

### Installing Flutter dependencies

### Install the SDK

Install the Flutter library by running:

```sh
flutter pub add complycube
```

### CocoaPods

1. Before using the ComplyCube SDK, install the CocoaPods plugin by running the following command in your terminal:

    ```sh
    sudo gem install cocoapods
    ```

2. Open your `ios/Podfile` and add the following configuration:

    ```ruby
    source 'https://github.com/CocoaPods/Specs.git'

    platform :iOS, '13.0'

    target 'YourApp' do
        use_frameworks!
        use_modular_headers!

        # Other existing pod configurations

        post_install do |installer|
            installer.pods_project.targets.each do |target|
                target.build_configurations.each do |build_configuration|
                    build_configuration.build_settings['ENABLE_BITCODE'] = 'NO'
                    build_configuration.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
                    build_configuration.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.1'
                    build_configuration.build_settings['ARCHS'] = ['$(ARCHS_STANDARD)', 'x86_64']
                    build_configuration.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = ['arm64', 'arm64e', 'armv7', 'armv7s']
                    build_configuration.build_settings['GENERATE_INFOPLIST_FILE'] = 'YES'
                end
            end
        end

        $static_frameworks = [
            # pods that must be built statically
        ]

        pre_install do |installer|
            Pod::Installer::Xcode::TargetValidator.send(:define_method, :verify_no_static_framework_transitive_dependencies) {}

            installer.pod_targets.each do |target|
                if $static_frameworks.include?(target.name)
                    puts "Overriding the static_framework method for #{target.name}"
                    def target.build_type;
                        Pod::BuildType.static_library
                    end
                end
            end
        end
    end
    ```

3. Save the `Podfile`.

4. Run `pod install` in your `ios` directory to install the pods and apply the configurations.

#### Application Permissions

Our SDK uses the device camera and microphone for capture. You must add the following keys to your application's `ios/Info.plist` file.

1. `NSCameraUsageDescription`
    ```xml
    <key>NSCameraUsageDescription</key>
    <string>Used to capture facial biometrics and documents</string>
    ```

2. `NSMicrophoneUsageDescription`
    ```xml
    <key>NSMicrophoneUsageDescription</key>
    <string>Used to capture video biometrics</string>
    ```
   
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
<br>
<br>
As an ISO-certified platform, ComplyCube is praised for its speedy omnichannel integration and extensive service offerings, including Low/No-Code solutions, powerful API, Mobile SDKs, Client Libraries, and seamless CRM integrations.
