# ComplyCube Example App
 
This repository provides a pre-built UI that uses the ComplyCube SDK. It guides you through the ComplyCube identity verification process, which includes collecting client ID documents, proof of address documents, and biometric selfies.
 
> :information_source: Please get in touch with your **Account Manager** or **[support](https://support.complycube.com/hc/en-gb/requests/new)** to get access to our Mobile SDK.
 
## To run the app
 
### Install the flutter pub
 
1. To add the repo token execute this command
 
```bash
dart pub token add "https://complycuberepo.jfrog.io/artifactory/api/pub/cc-pub-release-local"
```

3. And the add the token provided by jFrog repository.

4. Install the pub

```bash
dart pub get
```
 
### Install CocoaPods
 
1. Before using the ComplyCube SDK, install the Cocoapods Artifactory plugin by running the following command in your terminal:
 
   ```bash
   gem install cocoapods-art
   ```
 
2. To add the library, copy your repository credentials into a `.netrc` file to your home directory and setup the repository:
 
   ```bash
   pod repo-art add cc-cocoapods-release-local "https://complycuberepo.jfrog.io/artifactory/api/pods/cc-cocoapods-release-local"
   ```
 
### Add Artifactory Credentials for Gradle
 
1. Replace `ARTIFACTORY_USER` and `ARTIFACTORY_PASSWORD` in `android/gradle.properties` with your JFrog User and encrypted JFrog Password
 
 
### Update Token and Client ID in Source Code
1. [Create a client](), and replace `CLIENT_ID` in `App.js` with the returned Client ID.
2. [Generate an SDK token](https://docs.complycube.com/documentation/guides/mobile-sdk-guide/mobile-sdk-integration-guide#id-3.-generate-an-sdk-token), and replace `SDK_TOKEN` in `App.js` with the generated token.
 
### Run the apps
1. Run the android app by running `flutter run`
2. Run the ios app only by running `flutter run -d ios`