import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:complycube/complycube.dart';

void main() {
  runApp(const MyApp());
}

enum VerificationStatus { PENDING, COMPLETED, FAILED }

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  StreamSubscription<ComplyCubeEvent>? _sub;
  String _status = 'idle';
  late final AppLifecycleListener _listener;
  VerificationStatus _currentStatus = VerificationStatus.PENDING;

  @override
  void initState() {
    super.initState();

    _listener = AppLifecycleListener(
      onResume: () {
        // This is called when the app returns to the foreground
        print("App Resumed - equivalent to onResume");
        if (_currentStatus == VerificationStatus.PENDING) {
          // The user returned to the app but we have no status yet
          // This could mean they abandoned the flow
          setState(() => _status = 'abandoned');
          if (kDebugMode) {
            print('User may have abandoned the verification flow');
          }
          _currentStatus = VerificationStatus.FAILED;
        }
      },
      // Optional: detect other transitions
      onRestart: () => print("App Restarted"),
    );


    _sub = ComplyCube.events.listen((evt) {
      if (evt is ComplyCubeSuccess) {
        setState(() => _status = 'success: ${evt.payload}');
        if (kDebugMode) {
          print('success event: ${evt.payload}');
        }
        _currentStatus = VerificationStatus.COMPLETED;
      } else if (evt is ComplyCubeError) {
        setState(() => _status = 'error ${evt.code}: ${evt.message}');
        if (kDebugMode) {
          print('error event: ${evt.message}');
        }
        _currentStatus = VerificationStatus.FAILED;
      } else if (evt is ComplyCubeCancelled) {
        setState(() => _status = 'cancelled');
        if (kDebugMode) {
          print('cancelled event: ${evt.reason}');
        }
        _currentStatus = VerificationStatus.FAILED;
      } else if (evt is ComplyCubeCustom) {
        // optional
        if (kDebugMode) {
          print('custom event: ${evt.event}');
        }
      }
    });
  }

  @override
  void dispose() {
    _listener.dispose();
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Card(
          child: ListTile(
            title: const Text("Start Flow"),
            subtitle: const Text(""),
            onTap: () async {
              _start("69662ca82b64c6000268004b",
                  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJwYXlsb2FkIjoiTTJGa056VTNZamMzWTJKa1lqVTBZelUzTVRFd1pEZzVOV1UxTkdNNE0yWXlaVEZsWXpVMk1XWXhNalkwWWpFek1tTmlOalU0TlRnMU5HRXhOVGs0WW1JM1lUY3dZVGcwWlRVMFlUVTNOMkl3WldSbE9HWTRNREkwTnpVME5EVXlORFEzTldRek1HUmxOalV3TVdRd09UWm1ZekkwTUdJM01XVmxPVGd6WkRRek9EVTNZbU15WVdKaU56WTRNekJpT0RNd04yTmlZMlV3WlRsaE1EWmpabVZpT1RrNU5XTTBaVGN4TURjelptRmtNMlUwTmpZNE1UUXhOMkZoT1RjMk4yTmlORGMzT0dWbFpXUmlZV1U0T1dWbU16bGxaalJrWm1ZME5HWTBNalEyTUROaE5USTVNMlUzTnpobU9XVTJNams1WWpWbE5qRm1OakUxWVRoa1pXTm1NRFU1WkRNMU5HVmhaVFl3TWpRNE56WTBPR1psT0RJMllUY3hNek5qIiwiZW52aXJvbm1lbnQiOiJsaXZlIiwidXJscyI6eyJhcGkiOiJodHRwczovL2FwaS5jb21wbHljdWJlLmNvbSIsInN5bmMiOiJ3c3M6Ly94ZHMuY29tcGx5Y3ViZS5jb20iLCJjcm9zc0RldmljZSI6Imh0dHBzOi8veGQuY29tcGx5Y3ViZS5jb20ifSwib3B0aW9ucyI6eyJoaWRlQ29tcGx5Q3ViZUxvZ28iOmZhbHNlLCJlbmFibGVDdXN0b21Mb2dvIjp0cnVlLCJlbmFibGVUZXh0QnJhbmQiOnRydWUsImVuYWJsZUN1c3RvbUNhbGxiYWNrcyI6dHJ1ZSwiZW5hYmxlTmZjIjp0cnVlLCJpZGVudGl0eUNoZWNrTGl2ZW5lc3NBdHRlbXB0cyI6NSwiZG9jdW1lbnRJbmZsaWdodFRlc3RBdHRlbXB0cyI6MiwibmZjUmVhZEF0dGVtcHRzIjo1LCJlbmFibGVBZGRyZXNzQXV0b2NvbXBsZXRlIjp0cnVlLCJlbmFibGVXaGl0ZUxhYmVsaW5nIjpmYWxzZX0sImlhdCI6MTc3NDg3MTE5MCwiZXhwIjoxNzc0ODc0NzkwfQ.sZm7w8-34t-sKq90uR9_vyp0we7b4sp9CeZsZfuHR_w",
                  "IGNORE_THIS_WORKFLOW_ID");
            },
          ),
        ),
      ),
    );
  }

  Future<void> _start(String clientId, String token, String workflowId) async {
    final settings = {
      "clientID": clientId,
      "clientToken": token,
      // "workflowTemplateId": workflowId,
      "stages": [
        {
          "name": 'intro',
          "heading": 'Remit KYC verification',
          'title': 'Identity Verification',
          "message": "We will now verify your identity so you can do payments."
        },
        {
          "name":"consent"
        },
        {
          "title": "Compliance ID Verification",
          "name": 'documentCapture',
          "showGuidance": true,
          "useLiveCaptureOnly": true,
          "retryLimit": 1,
          "documentTypes": {
            "passport": true,
            "driving_license": ["GB"],
          },
        },
        {
          "title": "Remit Face verifications",
          "name": "faceCapture",
          "mode": "photo",
          "useMLAssistance": true,
          "showGuidance": true,
          "retryLimit": 1
        },
        // {"name": "addressCapture", "useAutoComplete": true, "allowedCountries": ["GB"]},
        {
          "name": "poaCapture",
          "documentTypes": {
            "bank_statement": true,
            "utility_bill": true,
            "driving_license": true,
            "tax_document": true
          },
          "showGuidance": true,
          "useLiveCaptureOnly": false,
          "retryLimit": 1,
          "isAddressCaptureEnabled": true
        },
        // "complete",
        // {
        //   "name": "complete",
        //   "title": "Success!",
        //   "message": "You're all set"
        // }
        // {"name": "addressCapture", "useAutoComplete": true, "allowedCountries": ["GB"]},
        // {
        //   "name": "poaCapture",
        //   "documentTypes": {"bank_statement": true, "utility_bill": true, "driving_license": true, "tax_document": true},
        //   "showGuidance": true,
        //   "useLiveCaptureOnly": false,
        //   "retryLimit": 1,
        //   "isAddressCaptureEnabled": false
        // },
        // {
        //   "name": "faceCapture",
        //   "mode": "photo",
        //   "showGuidance": false,
        //   "useLiveCaptureOnly": true,
        //   "useMLAssistance": true,
        //   "retryLimit": 1
        // },
        // {
        //   "name": "poaCapture",
        //   "documentTypes" : {
        //     "bank_statement": true,
        //     "utility_bill": true
        //   },
        //   "showGuidance": false,
        //   "useLiveCaptureOnly": false,
        //   "useMLAssistance": true,
        //   "retryLimit": 1,
        //   "isAddressCaptureEnabled": true
        // },
        // {
        //   "name": "addressCapture",
        //   "allowedCountries": ["GB"],
        //   "useAutoComplete": true
        // },
      ],
      "lookAndFeel": {
        "isDarkMode": false,
        "uiInterfaceStyle": "light",
        "primaryButtonBgColor": "#09EB7E",
        "primaryButtonBorderColor": "#FFFFFF",
        "primaryButtonTextColor": "#011E3C",
        "secondaryButtonBgColor": "#F6F6F6",
        "secondaryButtonTextColor": "#000000",
        "secondaryButtonBorderColor": "#000000",
        "headingTextColor": "#000000",
        "editTextColor": "#808080",
        "errorPanelColor": "#F2F2F2",
        "errorPanelBgColor": "#F2F2F2",
        "errorPanelIconColor": "#D32F2F",
        "errorPanelTitleTextColor": "#D32F2F",
        "errorPanelDescriptionTextColor": "#D32F2F",
        "errorPopupColor": "#D32F2F",
        "errorPopupIconColor": "#D32F2F",
        "errorPopupTitleTextColor": "#D32F2F",
        "errorPopupDescriptionTextColor": "#D32F2F",
        "documentTypeSelectorBorderColor": "#808080",
        "documentTypeSelectorBgColor": "#FFFFFF",
        "documentTypeSelectorIconColor": "#09EB7E",
        "documentTypeSelectorTitleTextColor": "#000000",
        "documentTypeSelectorDescriptionTextColor": "#000000",
        "borderRadius": 30
      }
      // "lookAndFeel": {
      //   "borderRadius": 16,
      //   "enableAnimations": false,
      //   "primaryButtonColor": "#000000",
      //   "primaryButtonBgColor": "#000000",
      //   "primaryButtonTextColor": "#FFFFFF",
      //   "primaryButtonBorderColor": "#000000",
      //   "secondaryButtonColor": "#FFFFFF",
      //   "secondaryButtonBgColor": "#FFFFFF",
      //   "secondaryButtonTextColor": "#000000",
      //   "secondaryButtonBorderColor": "#333333",
      //   "documentSelectorColor": "#FFFFFF",
      //   "documentSelectorBorderColor": "#E0E0E0",
      //   "documentSelectorIconColor": "#000000",
      //   "documentSelectorTitleTextColor": "#111111",
      //   "documentSelectorDescriptionTextColor": "#555555",
      //   "documentTypeSelectorBgColor": "#FFFFFF",
      //   "documentTypeSelectorBorderColor": "#DDDDDD",
      //   "documentTypeSelectorIconColor": "#000000",
      //   "documentTypeSelectorTitleTextColor": "#111111",
      //   "documentTypeSelectorDescriptionTextColor": "#555555",
      //   "infoPopupColor": "#F2F2F2",
      //   "infoPopupIconColor": "#000000",
      //   "infoPopupTitleTextColor": "#111111",
      //   "infoPopupDescriptionTextColor": "#555555",
      //   "infoPanelColor": "#F2F2F2",
      //   "infoPanelBgColor": "#F2F2F2",
      //   "infoPanelIconColor": "#000000",
      //   "infoPanelTitleTextColor": "#111111",
      //   "infoPanelDescriptionTextColor": "#555555",
      //   "errorPopupColor": "#F8F8F8",
      //   "errorPopupIconColor": "#333333",
      //   "errorPopupTitleTextColor": "#000000",
      //   "errorPopupDescriptionTextColor": "#666666",
      //   "errorPanelColor": "#F8F8F8",
      //   "errorPanelBgColor": "#F8F8F8",
      //   "errorPanelIconColor": "#333333",
      //   "errorPanelTitleTextColor": "#000000",
      //   "errorPanelDescriptionTextColor": "#666666",
      //   "cameraButtonColor": "#000000",
      //   "bodyTextColor": "#222222",
      //   "headingTextColor": "#000000",
      //   "subheadingTextColor": "#444444",
      //   "backgroundColor": "#FFFFFF",
      //   "backgroundContentColor": "#000000",
      //   "backgroundContentContrastColor": "#333333",
      //   "backgroundDividerColor": "#E0E0E0",
      //   "editTextColor": "#111111"
      // }
    };
    await ComplyCube.start(settings);
  }

}
