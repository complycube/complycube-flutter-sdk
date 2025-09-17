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
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: _start,
                child: const Text('Start Verification'),
              ),
              const SizedBox(height: 16),
              Text('Status: $_status'),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _start() async {
    // pass stages or workflowTemplateId if you pass both workflowTemplateId will be used
    //also pass color scheme or look and feel to customize the ui look and feel has priority over color scheme
    final settings = {
      "clientID": "<YOUR_CLIENT_ID>",
      "clientToken": "<YOUR_TOKEN>",
      // "workflowTemplateId": "<YOUR_WORKFLOW_ID>",
      "stages": ["welcome","consent","documentCapture","faceCapture","addressCapture","poaCapture"],
      "lookAndFeel": {
        "borderRadius": 16,
        "enableAnimations": false,
        "primaryButtonColor": "#000000",
        "primaryButtonBgColor": "#000000",
        "primaryButtonTextColor": "#FFFFFF",
        "primaryButtonBorderColor": "#000000",
        "secondaryButtonColor": "#FFFFFF",
        "secondaryButtonBgColor": "#FFFFFF",
        "secondaryButtonTextColor": "#000000",
        "secondaryButtonBorderColor": "#333333",
        "documentSelectorColor": "#FFFFFF",
        "documentSelectorBorderColor": "#E0E0E0",
        "documentSelectorIconColor": "#000000",
        "documentSelectorTitleTextColor": "#111111",
        "documentSelectorDescriptionTextColor": "#555555",
        "documentTypeSelectorBgColor": "#FFFFFF",
        "documentTypeSelectorBorderColor": "#DDDDDD",
        "documentTypeSelectorIconColor": "#000000",
        "documentTypeSelectorTitleTextColor": "#111111",
        "documentTypeSelectorDescriptionTextColor": "#555555",
        "infoPopupColor": "#F2F2F2",
        "infoPopupIconColor": "#000000",
        "infoPopupTitleTextColor": "#111111",
        "infoPopupDescriptionTextColor": "#555555",
        "infoPanelColor": "#F2F2F2",
        "infoPanelBgColor": "#F2F2F2",
        "infoPanelIconColor": "#000000",
        "infoPanelTitleTextColor": "#111111",
        "infoPanelDescriptionTextColor": "#555555",
        "errorPopupColor": "#F8F8F8",
        "errorPopupIconColor": "#333333",
        "errorPopupTitleTextColor": "#000000",
        "errorPopupDescriptionTextColor": "#666666",
        "errorPanelColor": "#F8F8F8",
        "errorPanelBgColor": "#F8F8F8",
        "errorPanelIconColor": "#333333",
        "errorPanelTitleTextColor": "#000000",
        "errorPanelDescriptionTextColor": "#666666",
        "cameraButtonColor": "#000000",
        "bodyTextColor": "#222222",
        "headingTextColor": "#000000",
        "subheadingTextColor": "#444444",
        "backgroundColor": "#FFFFFF",
        "backgroundContentColor": "#000000",
        "backgroundContentContrastColor": "#333333",
        "backgroundDividerColor": "#E0E0E0",
        "editTextColor": "#111111"
      }
    };
    await ComplyCube.start(settings);
  }
}
