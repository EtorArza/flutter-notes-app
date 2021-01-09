import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/models.dart';
import '../data/theme.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import '../services/database.dart';
import '../screens/settings.dart';

List<Color> colorList = [Colors.blue, Colors.green, Colors.indigo, Colors.red, Colors.cyan, Colors.teal, Colors.amber.shade900, Colors.deepOrange];

double dueCircleSize = 10.0;
Widget getDueCircle(BuildContext context) {
  return Align(
    alignment: Alignment.centerRight,
    child: Icon(
      Icons.brightness_1,
      color: Theme.of(context).accentColor,
      size: dueCircleSize,
    ),
  );
}

class NoteCardComponent extends StatefulWidget {
  NoteCardComponent({
    Key key,
    this.noteData,
    this.onHoldAction,
    this.onTapAction,
    this.isVisible,
    this.refreshView,
    this.settings,
    this.hideDueInfo = false,
  }) : super(key: key);

  final NotesModel noteData;
  final Function(NotesModel noteData) onHoldAction;
  final Function(NotesModel noteData) onTapAction;
  final int isVisible;
  final Function() refreshView;
  final Settings settings;
  final bool hideDueInfo;

  @override
  _NoteCardComponentState createState() => _NoteCardComponentState();
}

class _NoteCardComponentState extends State<NoteCardComponent> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget nonExpandedCard = getNonExpandedCard(1, context, false);

    Widget expandedCard = getNonExpandedCard(1, context, true);

    return AnimatedSize(
      duration: Duration(milliseconds: 230),
      alignment: Alignment.topCenter,
      vsync: this,
      child: Container(child: this.widget.noteData.isExpanded ? expandedCard : nonExpandedCard),
    );
  }

  void updateDueDateCard(Duration timeFromNow) async {
    DateTime now = DateTime.now();

    this.widget.noteData.dueDate = now.add(timeFromNow);
    this.widget.noteData.date = DateTime.now();
    await NotesDatabaseService.db.updateNoteInDB(this.widget.noteData);
    setState(() {
      this.widget.noteData.toggleExpand();
      this.widget.refreshView();
    });
  }

  Widget getNonExpandedCard(int nRows, BuildContext context, bool showLowerButtons) {
    bool isDue = this.widget.noteData.dueDate.difference(DateTime.now()).inSeconds <= 0;
    int nDaysSinceLastUpdate = -this.widget.noteData.date.difference(DateTime.now()).inDays;

    Color color = colorList.elementAt(this.widget.noteData.meaningContent.length % colorList.length);

    Widget buttonRow = Padding(
        padding: EdgeInsets.only(top: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            InkWell(
              onTap: () async {
                int nextDueMiliseconds = await NotesDatabaseService.db.getNumberOfSecondsDueOfSecondNote();

                // next card is due a long time ago
                if (nextDueMiliseconds < -30) {
                  nextDueMiliseconds = 0 - (1 + Random().nextInt(15)); // set due this after all long time due
                }
                // next card is due short time ago
                else if (nextDueMiliseconds <= 0) {
                  if (nextDueMiliseconds != 0) {
                    nextDueMiliseconds = -(Random().nextInt(nextDueMiliseconds.abs())); //
                  }
                }
                // next card is NOT due (nextDueSeconds > -4)
                else {
                  nextDueMiliseconds = 0 - (1 + Random().nextInt(15));
                }

                updateDueDateCard(Duration(milliseconds: nextDueMiliseconds));
              },
              child: ButtonBelowCard(icon: Icons.repeat),
            ),
            InkWell(
              onTap: () {
                updateDueDateCard(Duration(hours: 12, days: this.widget.settings.nDaysRepeat[0] - 1));
              },
              child: ButtonBelowCard(icon: fromNDaysToButtonText(this.widget.settings.nDaysRepeat[0])),
            ),
            InkWell(
              onTap: () {
                updateDueDateCard(Duration(days: this.widget.settings.nDaysRepeat[1]));
              },
              child: ButtonBelowCard(icon: fromNDaysToButtonText(this.widget.settings.nDaysRepeat[1])),
            ),
            InkWell(
              onTap: () {
                updateDueDateCard(Duration(days: this.widget.settings.nDaysRepeat[2]));
              },
              child: ButtonBelowCard(icon: fromNDaysToButtonText(this.widget.settings.nDaysRepeat[2])),
            ),
            InkWell(
              onTap: () {
                updateDueDateCard(Duration(days: this.widget.settings.nDaysRepeat[3]));
              },
              child: ButtonBelowCard(icon: fromNDaysToButtonText(this.widget.settings.nDaysRepeat[3])),
            ),
          ],
        ));

    return Container(
        margin: EdgeInsets.fromLTRB(10.0, 2.0, 10.0, 6.0),
        //height: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [buildBoxShadow(color, context)],
          border: Border.all(width: 2, color: this.widget.noteData.isSelected ? Colors.white : Colors.transparent),
        ),
        child: Material(
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          color: this.widget.noteData.isLearned ? Colors.grey[300].withAlpha(70) : Theme.of(context).dialogBackgroundColor,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              //print(this.widget.noteData.isExpanded);
              this.widget.onTapAction(this.widget.noteData);
              //print(this.widget.noteData.isExpanded);
            },
            onLongPress: () {
              this.widget.onHoldAction(this.widget.noteData);
            },
            splashColor: color.withAlpha(20),
            highlightColor: color.withAlpha(10),
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 16.0 - dueCircleSize, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  this.widget.hideDueInfo
                      ? Container(
                          height: 10,
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              nDaysSinceLastUpdate.toString() + 'd ',
                              style: TextStyle(color: Color.fromARGB(min(30 + nDaysSinceLastUpdate * 8, 255), 255, 255, 255)),
                            ),
                            isDue
                                ? getDueCircle(context)
                                : Container(
                                    height: dueCircleSize,
                                  ),
                          ],
                        ),
                  Container(
                    margin: EdgeInsets.only(),
                    child: this.widget.isVisible == 0 || this.widget.isVisible == 1 || this.widget.noteData.isExpanded
                        ? FormattedText(nLines: 1, completeString: this.widget.noteData.originalContent)
                        : Text(" "),
                  ),

                  Divider(height: 24.0),
                  Container(
                      margin: EdgeInsets.only(),
                      child: this.widget.isVisible == 0 || this.widget.isVisible == 2 || this.widget.noteData.isExpanded
                          ? FormattedText(nLines: 1, completeString: this.widget.noteData.meaningContent)
                          : Container()),
                  !showLowerButtons || this.widget.noteData.isLearned || this.widget.hideDueInfo ? Container() : buttonRow,
                  // Container(
                  //   margin: EdgeInsets.only(top: 14),
                  //   alignment: Alignment.centerRight,
                  //   child: Row(
                  //     children: <Widget>[
                  //       Icon(Icons.flag,
                  //           size: 16,
                  //           color: noteData.isLearned
                  //               ? color
                  //               : Colors.transparent),
                  //       Spacer(),
                  //       Text(
                  //         '$neatDate',
                  //         textAlign: TextAlign.right,
                  //         style: TextStyle(
                  //             fontSize: 12,
                  //             color: Colors.grey.shade300,
                  //             fontWeight: FontWeight.w500),
                  //       ),
                  //     ],
                  //   ),
                  // )
                ],
              ),
            ),
          ),
        ));
  }

  BoxShadow buildBoxShadow(Color color, BuildContext context) {
    return BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 8, offset: Offset(0, 8));
  }
} // class NoteComponentCard

class ButtonBelowCard extends StatelessWidget {
  ButtonBelowCard({
    Key key,
    this.icon,
  }) : super(key: key);

  final double opacity = 0;
  final icon;

  @override
  Widget build(BuildContext context) {
    MediaQueryData queryData;
    queryData = MediaQuery.of(context);

    Color accentColor = appThemeDark.accentColor;
    Widget res = Container(
      height: 50,
      width: MediaQuery.of(context).size.width * 0.15,
      child: icon is IconData
          ? Icon(
              icon,
              color: Colors.grey.shade300,
            )
          : Align(
              alignment: Alignment.center,
              child: Text(
                icon,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, color: Colors.grey.shade300, fontFamily: 'ZillaSlab'),
              )),
      decoration: BoxDecoration(
          color: Colors.transparent, border: Border.all(width: 1.0, color: Colors.grey.shade300), borderRadius: BorderRadius.all(Radius.circular(6))),
    );

    return res;
  }
}

Widget getAddNoteCardComponent(BuildContext context) {
  return Container(
      margin: EdgeInsets.fromLTRB(10, 8, 10, 8),
      height: 110,
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).primaryColor, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.add,
                      color: Theme.of(context).primaryColor,
                    ),
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Add card',
                          style: TextStyle(fontFamily: 'ZillaSlab', color: Theme.of(context).primaryColor, fontSize: 20),
                        ))
                  ],
                ),
              )
            ],
          ),
        ),
      ));
}

class FormattedText extends StatelessWidget {
  const FormattedText({
    this.nLines,
    this.completeString,
    Key key,
  }) : super(key: key);

  final int nLines;
  final String completeString;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: ' ',
        style: DefaultTextStyle.of(context).style,
        children: buildListOfTextSpan(completeString, context),
      ),
    );
  }

  List<TextSpan> buildListOfTextSpan(String text, BuildContext context) {
    const String sep = ":";
    const List<String> highlightColorNames = [
      "regular",
      "default",
      "standard",
      "white",
      "red",
      "green",
      "blue",
      "pink",
      "yellow",
      "orange",
      "purple",
      "grey"
    ];
    const List<String> fontModeNames = ["regular", "default", "standard", "normal", "italic", "bold"];

    const List<Color> highlightColors = [
      Color.fromARGB(255, 255, 255, 255), // regular (white)
      Color.fromARGB(255, 255, 255, 255), // default (white)
      Color.fromARGB(255, 255, 255, 255), // standard (white)
      Color.fromARGB(255, 255, 255, 255), // white
      Color.fromARGB(255, 255, 90, 90), // red
      Color.fromARGB(255, 0, 255, 128), // green
      Color.fromARGB(255, 0, 196, 255), // blue
      Color.fromARGB(255, 255, 128, 249), // pink
      Color.fromARGB(255, 255, 255, 128), // yellow
      Color.fromARGB(255, 255, 180, 94), // orange
      Color.fromARGB(255, 160, 82, 255), // purple
      Color.fromARGB(255, 150, 150, 150), // grey
    ];
    List<TextSpan> res = [];

    Color currentColor = highlightColors[highlightColorNames.indexWhere((element) {
      return element == "white";
    })];

    FontWeight currentFontWeight = FontWeight.normal;
    FontStyle currentFontStyle = FontStyle.normal;

    bool styleChanged = true;
    List<String> splittedText = text.split(sep);

    for (var i = 0; i < splittedText.length; ++i) {
      final textPiece = splittedText[i];
      if ((highlightColorNames.contains(textPiece) || fontModeNames.contains(textPiece)) && i != 0 && i != splittedText.length - 1) {
        styleChanged = true;
        if (highlightColorNames.contains(textPiece)) {
          currentColor = highlightColors[highlightColorNames.indexWhere((element) {
            return element == textPiece;
          })];
        }

        if (fontModeNames.contains(textPiece)) {
          if (textPiece == 'normal' || textPiece == 'standard' || textPiece == 'regular' || textPiece == 'default') {
            currentFontWeight = FontWeight.normal;
            currentFontStyle = FontStyle.normal;
          } else if (textPiece == 'bold') {
            currentFontWeight = FontWeight.bold;
            currentFontStyle = FontStyle.normal;
          } else if (textPiece == "italic") {
            currentFontWeight = FontWeight.normal;
            currentFontStyle = FontStyle.italic;
          }
        }
      } else {
        res.add(TextSpan(
          style: TextStyle(
            color: currentColor,
            fontFamily: DefaultTextStyle.of(context).style.fontFamily,
            fontSize: 16.0,
            fontWeight: currentFontWeight,
            fontStyle: currentFontStyle,
          ),
          text: styleChanged ? textPiece : ":" + textPiece,
        ));
        styleChanged = false;
      }
    }

    // print(text.split(sep));
    // print(text.split(sep)[0] == '');
    return res;
  }
}

String fromNDaysToButtonText(int nDays) {
  return nDays < 100 ? nDays.toString() + 'd' : (nDays ~/ 7).toString() + 'w';
}
