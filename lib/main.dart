import 'package:flutter/material.dart';
import 'package:complycube/complycube.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: ComplyCubeWidget(
          settings:const {
            "clientID": "CLIENT_ID",
            "clientToken": "CLIENT_TOKEN",
            "stages": [
              {
                "name": "intro",
                "title": "ID verification",
                "message": "We will now verify your identity.",
              },
              {
                "name": 'documentCapture',
              },
              'faceCapture',
            ],
            "lookAndFeel": {
              "primaryButtonBgColor": "#000000",
              "primaryButtonPressedBgColor": "#000000",
              "primaryButtonBorderColor": "#000000",
              "primaryButtonTextColor": "#FFFFFF",

              "linkButtonTextColor": "#000000",
              "headerTitle": "#000000",
              "subheaderTitle": "#000000",
              "textSecondary": "#000000",

              "docTypeBgColor": "#000000",
              "docTypeTextColor": "#000000",
              "docTypeBorderColor": "#000000",

              "textItemType": "#000000",
              "blueBigType": "#000000",
              "popUpBgColor": "#000000",
              "popUpTitleColor": "#000000",

              "backgroundContentColor": "#000000",
              "documentSelectorIconColor": "#000000",
              "documentSelectorTitleTextColor": "#000000",

              "headingTextColor": "#000000",
              "cameraButtonColor": "#000000",
              "borderRadius": 16,
            }
          },
          onError: (errors) {
            print("CCube Errors:: ${errors.map((e) => e.toJson())}");
          },
          onSuccess: (result) {
            print("CCube Result:: ${result.toJson()}");
          },
          onCancelled: (error) {
            print("CCube Errors:: ${error.toJson()}");
          },
          onComplyCubeEvent: (event) {
            print("CCube Event:: $event");
          },
        ),
      ),
    );
  }
}
