import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:notes/services/sharedPref.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  Function(Brightness brightness) changeTheme;
  SettingsPage({Key key, Function(Brightness brightness) changeTheme}) : super(key: key) {
    this.changeTheme = changeTheme;
  }
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int selectedTheme;
  @override
  Widget build(BuildContext context) {
    setState(() {
      if (Theme.of(context).brightness == Brightness.light) {
        selectedTheme = 1; // bright
      } else {
        selectedTheme = 2; // dark
      }
    });

    return Scaffold(
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          Container(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(padding: const EdgeInsets.only(top: 24, left: 24, right: 24), child: Icon(OMIcons.arrowBack)),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 36, right: 24),
                child: buildHeaderWidget(context),
              ),
              settingTwoChoice('App theme', 'Light', 'Dark', handleThemeSelection, selectedTheme),
              buildCardWidget(Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text('About app', style: TextStyle(fontFamily: 'ZillaSlab', fontSize: 24, color: Theme.of(context).primaryColor)),
                  Container(
                    height: 40,
                  ),
                  Center(
                    child: Text('Developed by'.toUpperCase(),
                        style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500, letterSpacing: 1)),
                  ),
                  Center(
                      child: Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                    child: Text(
                      'Roshan',
                      style: TextStyle(fontFamily: 'ZillaSlab', fontSize: 24),
                    ),
                  )),
                  Container(
                    alignment: Alignment.center,
                    child: OutlineButton.icon(
                      icon: Icon(OMIcons.link),
                      label: Text('GITHUB', style: TextStyle(fontWeight: FontWeight.w500, letterSpacing: 1, color: Colors.grey.shade500)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      onPressed: openGitHub,
                    ),
                  ),
                  Container(
                    height: 30,
                  ),
                  Center(
                    child:
                        Text('Made With'.toUpperCase(), style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500, letterSpacing: 1)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          FlutterLogo(
                            size: 40,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Flutter',
                              style: TextStyle(fontFamily: 'ZillaSlab', fontSize: 24),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ))
            ],
          ))
        ],
      ),
    );
  }

  Widget buildCardWidget(Widget child) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).dialogBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(offset: Offset(0, 8), color: Colors.black.withAlpha(20), blurRadius: 16)]),
      margin: EdgeInsets.all(24),
      padding: EdgeInsets.all(16),
      child: child,
    );
  }

  Widget buildHeaderWidget(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8, bottom: 16, left: 8),
      child: Text(
        'Settings',
        style: TextStyle(fontFamily: 'ZillaSlab', fontWeight: FontWeight.w700, fontSize: 36, color: Theme.of(context).primaryColor),
      ),
    );
  }

  void handleThemeSelection(int value) {
    setState(() {
      selectedTheme = value;
    });
    if (value == 1) {
      widget.changeTheme(Brightness.light);
    } else {
      widget.changeTheme(Brightness.dark);
    }
    setThemeinSharedPref(value);
  }

  void openGitHub() {
    launch('https://www.github.com/roshanrahman');
  }

  Widget settingTwoChoice(String settingName, String settingOption1String, String settingOption2String, Function onChanged, int groupValue) {
    return buildCardWidget(Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(settingName, style: TextStyle(fontFamily: 'ZillaSlab', fontSize: 24)),
        Container(
          height: 20,
        ),
        Row(
          children: <Widget>[
            Radio(
              value: 1,
              groupValue: groupValue,
              onChanged: onChanged,
            ),
            Text(
              settingOption1String,
              style: TextStyle(fontSize: 18),
            )
          ],
        ),
        Row(
          children: <Widget>[
            Radio(
              value: 2,
              groupValue: groupValue,
              onChanged: onChanged,
            ),
            Text(
              settingOption2String,
              style: TextStyle(fontSize: 18),
            )
          ],
        ),
      ],
    ));
  }
}
