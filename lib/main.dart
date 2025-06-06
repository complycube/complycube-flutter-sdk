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
                "title": "XTM ID verification",
                "message": "We will now verify your identity.",
              },
              {
                "name": "customerInfo",
                "title": "CustomerInfo",
                "customerInfoFields": [
                  {
                    "metadata": [
                      {
                        "key": "Tax Residence",
                        "question": "Are you a tax resident outside of Canada?",
                        "componentType": "SINGLE_CHOICE",
                        "options": [
                          {
                            "label": "No, Just Canada",
                            "value": "Canada"
                          },
                          {
                            "label": "Yes, I am",
                            "value": "Outside"
                          }
                        ],
                        "required": true,
                        "description": "Tax residency is usually based on where you primarily live and spend time."
                      },
                      {
                        "key": "Jurisdiction Country",
                        "question": "Tax residences",
                        "componentType": "MULTI_SELECT_COUNTRY",
                        "constraint": {
                          "expression": "metadata.Tax Residence contains Outside"
                        },
                        "required": true,
                        "description": "Please select all the countries that you're a tax resident in."
                      },
                      {
                        "key": "Has SSN",
                        "question": "Do you have Social Security Number?",
                        "componentType": "SINGLE_CHOICE",
                        "options": [
                          { "label": "Yes", "value": "yes"},
                          { "label": "No", "value": "no"}
                        ],
                        "constraint": {
                          "expression": "metadata.Jurisdiction Country contains US"
                        },
                        "required": true,
                        "description": "Your data is processed securely."
                      },
                      {
                        "key": "SSN Reason",
                        "question": "Don't have Social Security Number?",
                        "componentType": "SINGLE_CHOICE",
                        "options": [
                          { "label": "Pending Application", "value": "PA"},
                          { "label": "Not Applicable", "value": "NA"},
                          { "label": "Other Reason", "value": "Other"},
                        ],
                        "constraint": { "expression": "metadata.Has SSN contains no"},
                        "required": true,
                        "description": "Let us know why you do not have SSN"
                      },
                      {
                        "key": "SSN Reason Other",
                        "question": "Provide short explanation for not having SSN?",
                        "componentType": "PARAGRAPH",
                        "format": {
                          "type": "MAXCHAR",
                          "validation": "500"
                        },
                        "constraint": {
                          "expression": "metadata.SSN Reason contains Other"
                        },
                        "required": true,
                        "description": "Let us know why so we can verify your identity another way"
                      },
                      {
                        "key": "Has SIN",
                        "question": "Do you have Social Insurance Number?",
                        "componentType": "SINGLE_CHOICE",
                        "options": [
                          { "label": "Yes", "value": "yes"},
                          { "label": "No", "value": "no"}
                        ],
                        "constraint": {
                          "expression": "metadata.Jurisdiction Country contains CA"
                        },
                        "required": true,
                        "description": "Your data is processed securely."
                      },
                      {
                        "key": "SIN Reason",
                        "question": "Don't have Social Insurance Number?",
                        "componentType": "SINGLE_CHOICE",
                        "options": [
                          { "label": "Pending Application", "value": "PA"},
                          { "label": "Not Applicable", "value": "NA"},
                          { "label": "Other Reason", "value": "Other"},
                        ],
                        "constraint": { "expression": "metadata.Has SIN contains no"},
                        "required": true,
                        "description": "Let us know why you do not have Social Insurance Number"
                      },
                      {
                        "key": "SIN Reason Other",
                        "question": "Provide short explanation for not having Social Insurance Number",
                        "componentType": "PARAGRAPH",
                        "format": {
                          "type": "MAXCHAR",
                          "validation": "500"
                        },
                        "constraint": {
                          "expression": "metadata.SIN Reason contains Other"
                        },
                        "required": true,
                        "description": "Let us know why so we can verify your identity another way"
                      }
                    ],
                    "metadataTemplates": [
                      {
                        "templateKey": "TIN_HAS",
                        "question": "Do you have a TIN or equivalent for {country}",
                        "componentType": "SINGLE_CHOICE",
                        "options": [
                          { "label": "Yes", "value": "yes" },
                          { "label": "No", "value": "no" }
                        ],
                        "description": "Select Yes if you have a valid Tax Identification Number or similar tax number for {country}"
                      },
                      {
                        "templateKey": "TIN",
                        "question": "Tax Identification Number for {country}",
                        "componentType": "SHORT_ANSWER",
                        "format": { "type": "MAXCHAR", "validation": "100" },
                        "description": "Enter your Tax Identification Number for {country}"
                      },
                      {
                        "templateKey": "TIN_REASON",
                        "question": "Don't have a TIN for {country}?",
                        "componentType": "SINGLE_CHOICE",
                        "options": [
                          { "label": "Pending Application", "value": "pending" },
                          { "label": "Not Applicable", "value": "na" },
                          { "label": "Other", "value": "other" }
                        ],
                        "description": "Let us know why you do not have a TIN",
                      },
                      {
                        "templateKey": "TIN_REASON_OTHER",
                        "question": "Let us know why you do not have a TIN.",
                        "componentType": "PARAGRAPH",
                        "format": { "type": "MAXCHAR", "validation": "500" },
                        "description": "Provide short explanation for not having a TIN"
                      }
                    ]
                  },
                  {
                    "details": [
                      {
                        "person": [
                          {
                            "name": "ssn",
                            "constraint": {
                              "expression": "metadata.Has SSN contains yes"
                            }
                          },
                          {
                            "name": "social_insurance_number",
                            "constraint": {
                              "expression": "metadata.Has SIN contains yes"
                            }
                          },
                        ]
                      }
                    ]
                  },
                ]
              }
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
          //Handle callbacks
          onError: (errors) {
            print("CCube Errors:: ${errors.map((e) => e.toJson())}");
            // if (kDebugMode) {
            //   print("CCube Errors:: ${errors.map((e) => e.toJson())}");
            // }
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
