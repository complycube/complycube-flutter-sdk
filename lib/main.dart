import 'dart:async';

import 'package:flutter/foundation.dart';
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

  StreamSubscription<ComplyCubeEvent>? _sub;
  String _status = 'idle';

  @override
  void initState() {
    super.initState();
    _sub = ComplyCube.events.listen((evt) {
      if (evt is ComplyCubeSuccess) {
        setState(() => _status = 'success: ${evt.payload}');
        if (kDebugMode) {
          print('success event: ${evt.payload}');
        }
      } else if (evt is ComplyCubeError) {
        setState(() => _status = 'error ${evt.code}: ${evt.message}');
        if (kDebugMode) {
          print('error event: ${evt.message}');
        }
      } else if (evt is ComplyCubeCancelled) {
        setState(() => _status = 'cancelled');
        if (kDebugMode) {
          print('cancelled event: ${evt.reason}');
        }
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
            title: Text("Start Flow"),
            subtitle: Text(""),
            onTap: () async {
              _start("6875fb819b4d200002899140", "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJwYXlsb2FkIjoiTTJGa056VTNZamMzWTJKa1lqVTBZelUzTVRFd1pEZzVOV1UxTkdNNE0yWXlaVEZsWXpVMk1XWXhNalkwWWpFek1tTmlOalU0TlRnMU5HRXhOVGs0WWprMlpXWXdOV015TkRBNU1EZzBOR0poWWpaaU5EQXdOVGs0T0dNNE1XTTJOek5sWWpJNU1XUXlZamd3TlRZMk5qTTBOREJrTm1KaVpUSTFOekkxTnpGa05XUTRNamt3TVRabE5EUmpabVk0WVdWbE5UWm1Nell5TlRabU5qRmpNVGRsTVdJMU9UaGlNekkyT1RjeVl6VmxaRGsxTkdZeE9XVTNZakkxWmpZM1pUaGtPV0UxWVRnellqTTNNekl6TjJJNU5UbGxZakJrTnpBeE5EYzRaRE5rWVRZNE1XTXdNbVUyWWpkbFpEQTFZVFk0TmpNMFl6QTBPV1EyWVRCa01HWmhNamxtWW1JMVpUZGlNalZrTW1RME9EQTBaVGRrTWpVd01UZzBObUZsIiwiZW52aXJvbm1lbnQiOiJsaXZlIiwidXJscyI6eyJhcGkiOiJodHRwczovL2FwaS5jb21wbHljdWJlLmNvbSIsInN5bmMiOiJ3c3M6Ly94ZHMuY29tcGx5Y3ViZS5jb20iLCJjcm9zc0RldmljZSI6Imh0dHBzOi8veGQuY29tcGx5Y3ViZS5jb20ifSwib3B0aW9ucyI6eyJoaWRlQ29tcGx5Q3ViZUxvZ28iOmZhbHNlLCJlbmFibGVDdXN0b21Mb2dvIjp0cnVlLCJlbmFibGVUZXh0QnJhbmQiOnRydWUsImVuYWJsZUN1c3RvbUNhbGxiYWNrcyI6dHJ1ZSwiZW5hYmxlTmZjIjp0cnVlLCJpZGVudGl0eUNoZWNrTGl2ZW5lc3NBdHRlbXB0cyI6NSwiZG9jdW1lbnRJbmZsaWdodFRlc3RBdHRlbXB0cyI6MiwibmZjUmVhZEF0dGVtcHRzIjo1LCJlbmFibGVBZGRyZXNzQXV0b2NvbXBsZXRlIjp0cnVlLCJlbmFibGVXaGl0ZUxhYmVsaW5nIjpmYWxzZX0sImlhdCI6MTc2NTc4ODM0MSwiZXhwIjoxNzY1NzkxOTQxfQ.Wn4sGvGra19FbB7PlsMniAYV_4Sm9H3KxcMox9JfsP4", "IGNORE_THIS_WORKFLOW_ID");
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
          "name": "intro",
          "title": "Green Bank ID verification",
          "message": "We will now verify your identity so you can start trading."
        },
        {
          "name": "consent",
          "title": "Terms of Service",
          "message": "Complete your identity verification to start trading with Green Bank."
        },
        // {
        //   "name": "documentCapture",
        //   "title": "Document Capture",
        //   "nfcEnabled": false,
        //   "showGuidance": false,
        //   "useLiveCaptureOnly": false,
        //   "useMLAssistance": true,
        //   "retryLimit": 1,
        //   "documentTypes": {
        //     "passport": true,
        //     "driving_license": ["GB", "FR"],
        //     "national_identity_card": ["GB", "FR"],
        //     "residence_permit": ["GB", "FR"]
        //   }
        // },
        // {
        //   "name": "faceCapture",
        //   "mode": "photo",
        //   "showGuidance": false,
        //   "useLiveCaptureOnly": false,
        //   "useMLAssistance": true,
        //   "retryLimit": 1
        // },
        // {
        //   "name": "faceCapture",
        //   "mode": "video",
        //   "showGuidance": false,
        //   "useLiveCaptureOnly": false,
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
        {
          "name": "addressCapture",
          "allowedCountries": ["GB"],
          "useAutoComplete": true
        },
      ],
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
