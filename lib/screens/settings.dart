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
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  int selectedTheme;
  bool allowExitSettings = true;
  bool _showBackupProgress = false;
  bool _backupJustDone = false;
  double _backupProgress = 0.0;

  void setBackupProgress(double progress) {
    print("progress: " + progress.toString());
    setState(() {
      _backupProgress = progress * 0.8;
    });
  }

  void showProgressBar() {
    setState(() {
      _showBackupProgress = true;
    });
  }

  Widget _getProgressBar() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 36),
        child: Column(
          children: [
            Text('Restoring backup...', style: TextStyle(fontFamily: 'ZillaSlab', color: Theme.of(context).primaryColor, fontSize: 20)),
            Container(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.done),
                  onPressed: () {},
                  color: Color.fromARGB(0, 0, 0, 0),
                ),
                Container(
                  color: Color.fromARGB(255, 0, 0, 0),
                  width: MediaQuery.of(context).size.width * 0.9 - 100,
                  child: LinearProgressIndicator(
                    value: _backupProgress,
                  ),
                ),
                _backupJustDone
                    ? IconButton(
                        icon: Icon(Icons.done),
                        onPressed: () {},
                      )
                    : IconButton(
                        icon: Icon(Icons.done),
                        onPressed: () {},
                        color: Color.fromARGB(0, 0, 0, 0),
                      ),
              ],
            ),
          ],
        ));
  }

  void closeProgressBar() {
    const int nSteps = 20;
    const int nMilSecondsLastPartProgress = 1000;
    for (int i = 0; i <= nSteps; i++) {
      Future.delayed(Duration(milliseconds: nMilSecondsLastPartProgress * i ~/ nSteps), () {
        setState(() {
          _backupProgress = 0.8 + 0.2 * i.toDouble() / nSteps.toDouble();
        });
      });
    }
    Future.delayed(Duration(milliseconds: nMilSecondsLastPartProgress), () {
      setState(() {
        _backupJustDone = true;
      });
    });

    Future.delayed(Duration(milliseconds: 2000 + nMilSecondsLastPartProgress), () {
      setState(() {
        _showBackupProgress = false;
        _backupJustDone = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          return allowExitSettings;
        },
        child: Scaffold(
          body: ListView(
            physics: BouncingScrollPhysics(),
            children: <Widget>[
              Container(
                  child: _showBackupProgress
                      ? this._getProgressBar()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: _showBackupProgress
                                  ? Container()
                                  : Container(padding: const EdgeInsets.only(top: 24, left: 24, right: 24), child: Icon(OMIcons.arrowBack)),
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
                                Text('Backup all collections',
                                    style: TextStyle(fontFamily: 'ZillaSlab', fontSize: 24, color: Theme.of(context).primaryColor)),
                                Spacer(),
                                iconButtonWithFrame(Icons.save, NotesDatabaseService.db.backupEntireDB),
                              ],
                            )),
                            buildCardWidget(Column(children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Restore backup',
                                      style: TextStyle(fontFamily: 'ZillaSlab', fontSize: 24, color: Theme.of(context).primaryColor)),
                                  Spacer(),
                                  iconButtonWithFrame(
                                    Icons.settings_backup_restore,
                                    () async {
                                      showDialog(
                                        barrierDismissible: true,
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text(
                                                'Are you sure you want to restore a backup? All current data will be replaced and forever lost.',
                                                style: TextStyle(fontFamily: 'ZillaSlab', color: Theme.of(context).primaryColor, fontSize: 20)),
                                            content: Container(height: 0),
                                            actions: <Widget>[
                                              FlatButton(
                                                child: Text('restore backup'.toUpperCase(),
                                                    style: TextStyle(color: Colors.red[300], fontWeight: FontWeight.w500, letterSpacing: 1)),
                                                onPressed: () async {
                                                  allowExitSettings = false;
                                                  Navigator.of(context).pop();
                                                  await NotesDatabaseService.db.restoreBackup(this, context);
                                                  allowExitSettings = true;
                                                },
                                              ),
                                              FlatButton(
                                                child: Text('cancel'.toUpperCase(),
                                                    style: TextStyle(color: Colors.grey.shade300, fontWeight: FontWeight.w500, letterSpacing: 1)),
                                                onPressed: () {
                                                  if (!allowExitSettings) {
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
                                    },
                                  ),
                                ],
                              ),
                            ])),
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
                                    label:
                                        Text('GITHUB', style: TextStyle(fontWeight: FontWeight.w500, letterSpacing: 1, color: Colors.grey.shade500)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    onPressed: openGitHubEtor,
                                  ),
                                ),
                                Container(
                                  height: 30,
                                ),
                                Center(
                                  child: Text('Forked from \'flutter-notes-app\' by'.toUpperCase(),
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
                                    label:
                                        Text('GITHUB', style: TextStyle(fontWeight: FontWeight.w500, letterSpacing: 1, color: Colors.grey.shade500)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    onPressed: openGitHubRoshan,
                                  ),
                                ),
                                Container(
                                  height: 30,
                                ),
                                Center(
                                  child: Text('Made With'.toUpperCase(),
                                      style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500, letterSpacing: 1)),
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
        ));
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

  void openGitHubRoshan() {
    launch('https://github.com/roshanrahman/flutter-notes-app');
  }

  void openGitHubEtor() {
    launch('https://github.com/EtorArza/memorize-with-cards-and-spaced-repetitions');
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

Widget iconButtonWithFrame(IconData icon, Function onTap) {
  return GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: Duration(milliseconds: 160),
      height: 50,
      width: 50,
      curve: Curves.slowMiddle,
      child: Icon(icon, color: Colors.grey.shade300),
      decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            width: 1,
            color: Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.all(Radius.circular(16))),
    ),
  );
}
