import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/models.dart';
import '../data/theme.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import '../services/database.dart';

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
  }) : super(key: key);

  final NotesModel noteData;
  final Function(NotesModel noteData) onHoldAction;
  final Function(NotesModel noteData) onTapAction;
  final int isVisible;
  final Function() refreshView;

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
        child: Container(child: Container(child: this.widget.noteData.isExpanded ? expandedCard : nonExpandedCard)));
  }

  void refetchNotesFromDB() async {
    //await setNotesFromDB();
    //print("Refetched notes");
  }

  void updateDueDateCard(Duration timeFromNow) async {
    DateTime now = DateTime.now();

    this.widget.noteData.dueDate = now.add(timeFromNow);
    await NotesDatabaseService.db.updateNoteInDB(this.widget.noteData);
    setState(() {
      this.widget.noteData.toggleExpand();
      this.widget.refreshView();
    });
  }

  Widget getNonExpandedCard(int nRows, BuildContext context, bool showLowerButtons) {
    bool isDue = this.widget.noteData.dueDate.difference(DateTime.now()).inSeconds <= 0;
    Color color = colorList.elementAt(this.widget.noteData.meaningContent.length % colorList.length);

    Widget buttonRow = Padding(
        padding: EdgeInsets.only(top: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            InkWell(
              onTap: () {
                updateDueDateCard(Duration(seconds: -(1 + Random().nextInt(1000))));
              },
              child: ButtonBelowCard(icon: Icons.repeat),
            ),
            InkWell(
              onTap: () {
                updateDueDateCard(Duration(hours: 12));
              },
              child: ButtonBelowCard(icon: Icons.repeat_one),
            ),
            InkWell(
              onTap: () {
                updateDueDateCard(Duration(days: 5));
              },
              child: ButtonBelowCard(icon: Icons.replay_5),
            ),
            InkWell(
              onTap: () {
                updateDueDateCard(Duration(days: 30));
              },
              child: ButtonBelowCard(icon: Icons.replay_30),
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
          color: Theme.of(context).dialogBackgroundColor,
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
                  isDue
                      ? getDueCircle(context)
                      : Container(
                          height: dueCircleSize,
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
                  showLowerButtons ? buttonRow : Container(),
                  // Container(
                  //   margin: EdgeInsets.only(top: 14),
                  //   alignment: Alignment.centerRight,
                  //   child: Row(
                  //     children: <Widget>[
                  //       Icon(Icons.flag,
                  //           size: 16,
                  //           color: noteData.isImportant
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
    if (Theme.of(context).brightness == Brightness.dark) {
      return BoxShadow(
          color: this.widget.noteData.isImportant == true ? Colors.black.withAlpha(100) : Colors.black.withAlpha(10),
          blurRadius: 8,
          offset: Offset(0, 8));
    }
    return BoxShadow(
        color: this.widget.noteData.isImportant == true ? color.withAlpha(60) : color.withAlpha(25), blurRadius: 8, offset: Offset(0, 8));
  }
} // class NoteComponentCard

class ButtonBelowCard extends StatelessWidget {
  ButtonBelowCard({
    Key key,
    this.icon,
  }) : super(key: key);

  final double opacity = 0;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    Color accentColor = appThemeDark.accentColor;
    Widget res = Container(
      height: 50,
      width: 70,
      child: Icon(
        icon,
        color: Colors.grey.shade300,
      ),
      decoration: BoxDecoration(
          color: Colors.transparent, border: Border.all(width: 1.0, color: Colors.grey.shade300), borderRadius: BorderRadius.all(Radius.circular(6))),
    );

    return res;
  }
}

class AddNoteCardComponent extends StatelessWidget {
  const AddNoteCardComponent({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
    const List<String> highlightColorNames = ["white", "red", "green", "blue", "pink", "yellow", "orange", "purple"];
    const List<Color> highlightColors = [
      Color.fromARGB(255, 255, 255, 255), // white
      Color.fromARGB(255, 255, 51, 92), // red
      Color.fromARGB(255, 0, 255, 128), // green
      Color.fromARGB(255, 0, 196, 255), // blue
      Color.fromARGB(255, 255, 128, 249), // pink
      Color.fromARGB(255, 255, 255, 128), // yellow
      Color.fromARGB(255, 255, 180, 94), // orange
      Color.fromARGB(255, 160, 82, 255), // purple
    ];
    List<TextSpan> res = [];

    Color currentColor = highlightColors[highlightColorNames.indexWhere((element) {
      return element == "white";
    })];

    bool colorChanged = true;
    List<String> splittedText = text.split(sep);

    for (var i = 0; i < splittedText.length; ++i) {
      final textPiece = splittedText[i];
      if (highlightColorNames.contains(textPiece) && i != 0 && i != splittedText.length - 1) {
        colorChanged = true;
        currentColor = highlightColors[highlightColorNames.indexWhere((element) {
          return element == textPiece;
        })];
      } else {
        res.add(TextSpan(
          style: TextStyle(
            color: currentColor,
            fontFamily: DefaultTextStyle.of(context).style.fontFamily,
            fontSize: 16.0,
          ),
          text: colorChanged ? textPiece : ":" + textPiece,
        ));
        colorChanged = false;
      }
    }

    // print(text.split(sep));
    // print(text.split(sep)[0] == '');
    return res;
  }
}
