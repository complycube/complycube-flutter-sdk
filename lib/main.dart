import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
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
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    if (!mounted) return;

    setState(() {
      // _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: ComplyCubeWidget(
            settings: const {
              'clientID': "<CLIENT_ID>",
              'clientToken': "<TOKEN>",
              'stages': [
                // {
                //   'name': "intro",
                //   'heading': 'Am from Java script',
                //   'message': 'A message for our users',
                // },
                {
                  'name': 'documentCapture',
                  'documentTypes': {
                    'passport': true,
                    'driving_license': ['GB', 'FR', 'DZ'],
                  },
                },
                {
                  'name': 'faceCapture',
                }
              ],
              'scheme': {
                // primaryButtonBgColor: '#FFFFFF',
              },
            },
            // ignore: unnecessary_const
            onCanceled: (arg) {
              print("Cancelled $arg");
            },
            onSuccess: (ids) {
              print("Succeeded $ids");
            },
            onError: (errors) {
              print("Error $errors");
            },
          ),
        ),
      ),
    );
  }
}
