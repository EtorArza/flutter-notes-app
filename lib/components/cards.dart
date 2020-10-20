import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/models.dart';
import '../data/theme.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

List<Color> colorList = [Colors.blue, Colors.green, Colors.indigo, Colors.red, Colors.cyan, Colors.teal, Colors.amber.shade900, Colors.deepOrange];

class NoteCardComponent extends StatefulWidget {
  NoteCardComponent({
    Key key,
    this.noteData,
    this.onHoldAction,
    this.onTapAction,
    this.isVisible,
  }) : super(key: key);

  final NotesModel noteData;
  final Function(NotesModel noteData) onHoldAction;
  final Function(NotesModel noteData) onTapAction;
  final int isVisible;

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

  Widget getNonExpandedCard(int nRows, BuildContext context, bool showLowerButtons) {
    bool isDue = this.widget.noteData.dueDate.difference(DateTime.now()).inSeconds <= 0;
    Color color = colorList.elementAt(this.widget.noteData.meaningContent.length % colorList.length);
    double circleSize = 10.0;
    Widget accentCircle = Align(
      alignment: Alignment.topRight,
      child: Icon(
        Icons.brightness_1,
        color: Theme.of(context).accentColor,
        size: circleSize,
      ),
    );

    Widget buttonRow = Padding(
        padding: EdgeInsets.only(top: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                print('tapped_button_1');
              },
              child: ButtonBelowCard(icon: Icons.access_alarm),
            ),
            GestureDetector(
              onTap: () {
                print('tapped_button_2');
              },
              child: ButtonBelowCard(icon: Icons.snooze),
            ),
            GestureDetector(
              onTap: () {
                print('tapped_button_3');
              },
              child: ButtonBelowCard(icon: Icons.snooze),
            ),
            GestureDetector(
              onTap: () {
                print('tapped_button_4');
              },
              child: ButtonBelowCard(icon: Icons.snooze),
            ),
          ],
        ));

    return Container(
        margin: EdgeInsets.fromLTRB(10.0, 2.0, 10.0, 8.0),
        //height: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [buildBoxShadow(color, context)],
        ),
        child: Material(
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          color: Theme.of(context).dialogBackgroundColor,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              this.widget.onTapAction(this.widget.noteData);
            },
            onLongPress: () {
              this.widget.onHoldAction(this.widget.noteData);
            },
            splashColor: color.withAlpha(20),
            highlightColor: color.withAlpha(10),
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 16.0 - circleSize, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  isDue
                      ? accentCircle
                      : Container(
                          height: circleSize,
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
                        ? Text(
                            '${this.widget.noteData.meaningContent.trim().split('\n').first.length <= 40 ? this.widget.noteData.meaningContent.trim().split('\n').first : this.widget.noteData.meaningContent.trim().split('\n').first.substring(0, 40) + '...'}',
                            style: TextStyle(fontSize: 16, color: Colors.grey.shade50),
                          )
                        : Container(),
                  ),
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
      width: 80.902,
      child: Icon(
        icon,
        color: Colors.grey.shade300,
      ),
      decoration: BoxDecoration(
          color: Colors.transparent, border: Border.all(width: 1, color: Colors.grey.shade300), borderRadius: BorderRadius.all(Radius.circular(16))),
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
                            'Add new note',
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
        text: '',
        style: DefaultTextStyle.of(context).style,
        children: buildListOfTextSpan(completeString, context),
      ),
    );
  }

  List<TextSpan> buildListOfTextSpan(String text, BuildContext context) {
    const String sep = ":";
    const List<String> highlightColors = ["green", "blue", "red"];
    List<TextSpan> res = [];

    for (var textPiece in text.split(sep)) {
      res.add(TextSpan(
        style: TextStyle(
          color: Colors.white,
          fontFamily: DefaultTextStyle.of(context).style.fontFamily,
          fontSize: 16.0,
        ),
        text: textPiece,
      ));
    }

    print(text.split(sep));
    print(text.split(sep)[0] == '');
    return res;
  }
}
