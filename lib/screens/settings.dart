import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:Frek/services/database.dart';
import 'package:Frek/services/sharedPref.dart';
import '../screens/home.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../components/cards.dart';
import 'home.dart';
import 'dart:math';

class SettingsPage extends StatefulWidget {
  final Settings settings;
  final MyHomePageState homeState;
  final bool restoreBackup;

  SettingsPage({
    Key key,
    this.settings,
    this.homeState,
    this.restoreBackup = false,
  }) : super(key: key) {}
  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  int selectedTheme;
  bool allowExitSettings = true;
  bool _showBackupProgress = false;
  bool _backupJustDone = false;
  bool _corruptedFileErrorDuringBackup = false;
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

  final GlobalKey<ScaffoldState> _scaffoldKeySettings = new GlobalKey<ScaffoldState>();

  void closeProgressBar() {
    const int nSteps = 20;
    const int nMilSecondsLastPartProgress = 1000;
    const int nMiliSecondsDoneInScreen = 750;
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

    Future.delayed(Duration(milliseconds: nMiliSecondsDoneInScreen + nMilSecondsLastPartProgress), () {
      Navigator.pop(context);
    });

    Future.delayed(Duration(milliseconds: nMiliSecondsDoneInScreen + nMilSecondsLastPartProgress + 500), () {
      // setState(() {
      //   _showBackupProgress = false;
      //   _backupJustDone = false;
      // });
    });
  }

  void closeProgressBarOnCorruptedFile() {
    const int nSteps = 60;
    const int nMilSecondsLastPartProgress = 250;
    const int nMiliSecondsDoneInScreen = 4750;
    double currentProgress = _backupProgress;

    for (int i = 0; i <= nSteps; i++) {
      Future.delayed(Duration(milliseconds: nMilSecondsLastPartProgress * i ~/ nSteps), () {
        setState(() {
          _backupProgress = currentProgress * (1.0 - i.toDouble() / nSteps.toDouble());
        });
      });
    }
    Future.delayed(Duration(milliseconds: nMilSecondsLastPartProgress), () {
      setState(() {
        _corruptedFileErrorDuringBackup = true;
      });
    });

    Future.delayed(Duration(milliseconds: nMiliSecondsDoneInScreen + nMilSecondsLastPartProgress), () {
      Navigator.pop(context);
    });
  }

  void showInSnackBarSettings(String value) {
    _scaffoldKeySettings.currentState.showSnackBar(
      SnackBar(
        duration: Duration(milliseconds: 6800),
        backgroundColor: Colors.blueGrey.shade800,
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            //Icon widget of your choice HERE,
            Text(value, style: TextStyle(color: Colors.white)),
            // GestureDetector(
            //   onTap: () {
            //     gotoEditNote();
            //   },
            //   child: Container(
            //       padding: EdgeInsets.symmetric(vertical: 3, horizontal: 9),
            //       decoration: BoxDecoration(
            //         color: Colors.white,
            //         borderRadius: BorderRadius.all(Radius.circular(100)),
            //       ),
            //       child: Row(children: <Widget>[
            //         Icon(Icons.add, color: Colors.black),
            //         Text('Add card'.toUpperCase(), style: TextStyle(color: Colors.black)),
            //       ])),
            // ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          return allowExitSettings;
        },
        child: Scaffold(
          key: _scaffoldKeySettings,
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
                  buildCardWidget(Column(
                    children: [
                      Text('Repetition intervals', style: TextStyle(fontFamily: 'ZillaSlab', fontSize: 24)),
                      Container(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [changeNDaysRepeatWidget(0), changeNDaysRepeatWidget(1), changeNDaysRepeatWidget(2), changeNDaysRepeatWidget(3)],
                      )
                    ],
                  )),
                  buildCardWidget(Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Backup all\ncollections', style: TextStyle(fontFamily: 'ZillaSlab', fontSize: 24, color: Theme.of(context).primaryColor)),
                      Spacer(),
                      iconButtonWithFrame(Icons.save, NotesDatabaseService.db.backupEntireDB),
                    ],
                  )),
                  buildCardWidget(Column(children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Restore backup', style: TextStyle(fontFamily: 'ZillaSlab', fontSize: 24, color: Theme.of(context).primaryColor)),
                        Spacer(),
                        iconButtonWithFrame(
                          Icons.settings_backup_restore,
                          () async {
                            showDialog(
                              barrierDismissible: true,
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('To restore a backup, open a .FrekDB file from a file manager.',
                                      style: TextStyle(fontFamily: 'ZillaSlab', color: Theme.of(context).primaryColor, fontSize: 20)),
                                  content: Container(height: 0),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text('OK'.toUpperCase(),
                                          style: TextStyle(color: Colors.grey.shade300, fontWeight: FontWeight.w500, letterSpacing: 1)),
                                      onPressed: () {
                                        Navigator.of(context).pop();
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
                  buildCardWidget(Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Restore default\n settings',
                          style: TextStyle(fontFamily: 'ZillaSlab', fontSize: 24, color: Theme.of(context).primaryColor)),
                      Spacer(),
                      iconButtonWithFrame(Icons.list_alt, () {
                        showConfirmationDialog(
                          context,
                          "Restore default settings? This will irreversibly replace your current settings.",
                          "restore",
                          Colors.amber,
                          "cancel",
                          () async {
                            await deleteAllPrefs();
                            await this.widget.settings.loadSettings();
                            setState(() {});
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
                          label: Text('GITHUB', style: TextStyle(fontWeight: FontWeight.w500, letterSpacing: 1, color: Colors.grey.shade500)),
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
      crossAxisAlignment: CrossAxisAlignment.center,
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

  Widget changeNDaysRepeatWidget(int indexOfButton) {
    return Column(
      children: [
        IconButton(
            icon: Icon(Icons.add),
            onPressed: this.widget.settings.nDaysRepeat[indexOfButton] > 690
                ? null
                : () {
                    setState(() {
                      this.widget.settings.nDaysRepeat[indexOfButton] += this.widget.settings.nDaysRepeat[indexOfButton] >= 99 ? 7 : 1;
                    });
                    this.widget.settings.saveSettings();
                  }),
        ButtonBelowCard(icon: fromNDaysToButtonText(this.widget.settings.nDaysRepeat[indexOfButton])),
        IconButton(
            icon: Icon(Icons.remove),
            onPressed: this.widget.settings.nDaysRepeat[indexOfButton] == 1
                ? null
                : () {
                    setState(() {
                      this.widget.settings.nDaysRepeat[indexOfButton] -= this.widget.settings.nDaysRepeat[indexOfButton] > 99 ? 7 : 1;
                    });
                    this.widget.settings.saveSettings();
                  }),
      ],
    );
  }
}

class Settings {
  static const String _defaultCardPositionInReview = 'top';
  static const List<int> _defaultNDaysRepeat = [1, 7, 16, 35];

  String cardPositionInReview = _defaultCardPositionInReview;
  List<int> nDaysRepeat = _defaultNDaysRepeat;

  bool settingsLoaded = false;
  Settings() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    settingsLoaded = false;

    // load values from sharedprefs, use
    cardPositionInReview = await getCardPositionInReviewInSharedPref() ?? _defaultCardPositionInReview;
    nDaysRepeat = await getnDaysRepeatInSharedPref() ?? [..._defaultNDaysRepeat];

    settingsLoaded = true;
    return;
  }

  void saveSettings() async {
    setCardPositionInReviewInSharedPref(cardPositionInReview);
    setnDaysRepeatInSharedPref(nDaysRepeat);
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
