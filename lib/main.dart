import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Frek/screens/settings.dart';
import 'package:Frek/services/sharedPref.dart';
import 'screens/home.dart';
import 'data/theme.dart';
import 'screens/settings.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  Settings settings;
  StreamSubscription _intentDataStreamSubscription;
  static const platform = const MethodChannel('app.channel.shared.data');
  String dataShared = "No data";

  @override
  void initState() {
    print('Initializing state in main.');

    super.initState();
    settings = Settings();
    getSharedText();
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("Data shared: " + dataShared);
    return MaterialApp(
      title: 'Frek',
      theme: appThemeDark,
      home: MyHomePage(title: 'Home', settings: settings, myappstate: this),
    );
  }

  getSharedText() async {
    var sharedData = await platform.invokeMethod("getSharedText");
    if (sharedData != null) {
      setState(() {
        dataShared = sharedData;
      });
    }
  }
}
