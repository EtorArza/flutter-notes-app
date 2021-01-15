import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Frek/screens/settings.dart';
import 'screens/home.dart';
import 'data/theme.dart';
import 'screens/settings.dart';
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
  String sharedText = "";

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
    print("Data shared: " + sharedText);
    return MaterialApp(
      title: 'Frek',
      theme: appThemeDark,
      home: MyHomePage(title: 'Home', settings: settings, myappstate: this),
    );
  }

  Future<void> getSharedText() async {
    var sharedData = await platform.invokeMethod("getSharedText");
    print("sharedData = $sharedData");
    if (sharedData != null) {
      setState(() {
        sharedText = sharedData;
      });
    }
    return;
  }
}
