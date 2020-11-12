import 'package:flutter/material.dart';
import 'package:notes/screens/settings.dart';
import 'package:notes/services/sharedPref.dart';
import 'screens/home.dart';
import 'data/theme.dart';
import 'screens/settings.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Settings settings;
  @override
  void initState() {
    super.initState();
    settings = Settings();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: appThemeDark,
      home: MyHomePage(title: 'Home', settings: settings),
    );
  }
}
