import 'package:flutter/material.dart';
import 'package:notes/screens/settings.dart';
import 'package:notes/services/sharedPref.dart';
import 'screens/home.dart';
import 'data/theme.dart';
import 'screens/settings.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Settings settings;
  StreamSubscription _intentDataStreamSubscription;
  List<SharedMediaFile> _sharedFiles;
  String _sharedText;

  @override
  void initState() {
    super.initState();
    settings = Settings();

    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent.getTextStream().listen((String value) {
      setState(() {
        _sharedText = value;
        print("Shared: $_sharedText");
      });
    }, onError: (err) {
      print("getLinkStream error: $err");
    });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String value) {
      setState(() {
        _sharedText = value;
        print("Shared: $_sharedText");
      });
    });
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Frek',
      theme: appThemeDark,
      home: MyHomePage(title: 'Home', settings: settings),
    );
  }
}
