import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:notes/services/database.dart';
import 'package:notes/services/sharedPref.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'home.dart';

class SettingsPage extends StatefulWidget {
  final Settings settings;

  SettingsPage({Key key, this.settings}) : super(key: key) {}
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int selectedTheme;
  bool isBackupBeingRestored = false;
  @override
  Widget build(BuildContext context) {
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
              settingTwoChoice(
                'Card position in review',
                'top',
                'bottom',
                'Top',
                'Bottom',
                (res) {
                  setState(() {
                    this.widget.settings.cardPositionInReview = res;
                  });
                  this.widget.settings.saveSettings();
                },
                this.widget.settings.settingsLoaded ? this.widget.settings.cardPositionInReview : null,
              ),
              buildCardWidget(Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Backup all collections', style: TextStyle(fontFamily: 'ZillaSlab', fontSize: 24, color: Theme.of(context).primaryColor)),
                  Spacer(),
                  IconButton(icon: Icon(Icons.save), onPressed: NotesDatabaseService.db.backupEntireDB),
                ],
              )),
              buildCardWidget(Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Restore backup', style: TextStyle(fontFamily: 'ZillaSlab', fontSize: 24, color: Theme.of(context).primaryColor)),
                  Spacer(),
                  IconButton(
                      icon: Icon(Icons.settings_backup_restore),
                      onPressed: () async {
                        showDialog(
                          barrierDismissible: true,
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Are you sure you want to restore a backup? All current data will be replaced and forever lost.',
                                  style: TextStyle(fontFamily: 'ZillaSlab', color: Theme.of(context).primaryColor, fontSize: 20)),
                              content: Container(height: 0),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text('restore backup'.toUpperCase(),
                                      style: TextStyle(color: Colors.red[300], fontWeight: FontWeight.w500, letterSpacing: 1)),
                                  onPressed: () async {
                                    isBackupBeingRestored = true;

                                    await NotesDatabaseService.db.restoreBackup(context);
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                    isBackupBeingRestored = false;
                                  },
                                ),
                                FlatButton(
                                  child: Text('cancel'.toUpperCase(),
                                      style: TextStyle(color: Colors.grey.shade300, fontWeight: FontWeight.w500, letterSpacing: 1)),
                                  onPressed: () {
                                    if (isBackupBeingRestored) {
                                      return;
                                    } else {
                                      Navigator.of(context).pop();
                                    }
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }),
                ],
              )),
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
                      'Etor Arza',
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
      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

  void openGitHub() {
    launch('https://www.github.com/roshanrahman');
  }

  Widget settingTwoChoice(String settingName, String settingOption1String, String settingOption2String, String option1Explain, String option2Explain,
      Function onChanged, var groupValue) {
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
              value: settingOption1String,
              groupValue: groupValue,
              onChanged: onChanged,
            ),
            Text(
              option1Explain,
              style: TextStyle(fontSize: 18),
            )
          ],
        ),
        Row(
          children: <Widget>[
            Radio(
              value: settingOption2String,
              groupValue: groupValue,
              onChanged: onChanged,
            ),
            Text(
              option2Explain,
              style: TextStyle(fontSize: 18),
            )
          ],
        ),
      ],
    ));
  }
}

class Settings {
  String cardPositionInReview = 'top';
  bool settingsLoaded = false;

  Settings() {
    loadSettings();
  }

  void loadSettings() async {
    settingsLoaded = false;
    Future.wait([
      // functions to get settings from persistent memory
      getCardPositionInReviewInSharedPref(),
    ]).then((listLoadedSettings) {
      // fields in which the settings are stored
      cardPositionInReview = listLoadedSettings[0] == 'top' ? 'top' : 'bottom';
      settingsLoaded = true;
    });
  }

  void saveSettings() async {
    setCardPositionInReviewInSharedPref(cardPositionInReview);
  }
}
