import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/models.dart';
import '../data/theme.dart';
import 'package:outline_material_icons/outline_material_icons.dart';


List<Color> colorList = [
  Colors.blue,
  Colors.green,
  Colors.indigo,
  Colors.red,
  Colors.cyan,
  Colors.teal,
  Colors.amber.shade900,
  Colors.deepOrange
];

class NoteCardComponent extends StatelessWidget {
  const NoteCardComponent({
    this.noteData,
    this.onHoldAction,
    this.onTapAction,
    this.isVisible,
    Key key,
  }) : super(key: key);

  

  final NotesModel noteData;
  final Function(NotesModel noteData) onHoldAction;
  final Function(NotesModel noteData) onTapAction;
  final int isVisible;

  @override
  Widget build(BuildContext context) {

    Widget nonExpandedCard = getNonExpandedCard(1, context);
    
    Widget expandedCard = Column(
      children: <Widget>[
        nonExpandedCard,
        Row(
          mainAxisAlignment:MainAxisAlignment.spaceEvenly,
          children: <Widget>[ 
            GestureDetector(
              onTap: () { print('tapped_button_1');},
              child: getButtonBelowCard(Icons.access_alarm),
            ),
            GestureDetector(
              onTap: () { print('tapped_button_2');},
              child: getButtonBelowCard(Icons.snooze),
            ),
          ],
        ),
        Padding(padding: const EdgeInsetsDirectional.only(top:8.0),),
      ],
    );

    return noteData.isExpanded ? expandedCard : nonExpandedCard ;
  }

  Widget getNonExpandedCard(int nRows, BuildContext context)
  {
    bool isDue =  noteData.dueDate.difference(DateTime.now()).inSeconds <= 0;
    Color color = colorList.elementAt(noteData.meaningContent.length % colorList.length);
    double circleSize = 10.0;
    Widget accentCircle = Align(alignment: Alignment.topRight, child: Icon(Icons.brightness_1, color: Theme.of(context).accentColor, size: circleSize,),);
    
    return Container(
        margin: EdgeInsets.fromLTRB(10.0, 2.0, 10.0, 8.0),
        height: 90,
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
              onTapAction(noteData);
            },
            onLongPress: () {
              onHoldAction(noteData);
            },
            splashColor: color.withAlpha(20),
            highlightColor: color.withAlpha(10),
            child: Container(
              padding: EdgeInsets.fromLTRB(16,16.0 - circleSize,16,16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                      isDue ? accentCircle : Container(height: circleSize,), 
                  Container(
                      margin: EdgeInsets.only(),
                    child: isVisible==0 || isVisible==1 || noteData.isExpanded ?  Text('${noteData.originalContent.trim().split('\n').first.length <= 40 ? noteData.originalContent.trim().split('\n').first : noteData.originalContent.trim().split('\n').first.substring(0, 40) + '...'}', style:TextStyle(fontSize: 14, color: Colors.grey.shade50),) : Text(' ', style:TextStyle(fontSize: 14, color: Colors.grey.shade50),),
                  ),
                  
                  Divider(height: 24.0),
                  Container(
                      margin: EdgeInsets.only(),
                      child: isVisible==0 || isVisible==2 || noteData.isExpanded ?  Text('${noteData.meaningContent.trim().split('\n').first.length <= 40 ? noteData.meaningContent.trim().split('\n').first : noteData.meaningContent.trim().split('\n').first.substring(0, 40) + '...'}', style: TextStyle(fontSize: 14, color: Colors.grey.shade50),) : Container(),
                  ),
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
          color: noteData.isImportant == true
              ? Colors.black.withAlpha(100)
              : Colors.black.withAlpha(10),
          blurRadius: 8,
          offset: Offset(0, 8));
    }
    return BoxShadow(
        color: noteData.isImportant == true
            ? color.withAlpha(60)
            : color.withAlpha(25),
        blurRadius: 8,
        offset: Offset(0, 8));
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
                            style: TextStyle(
                                fontFamily: 'ZillaSlab',
                                color: Theme.of(context).primaryColor,
                                fontSize: 20),
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


Widget getButtonBelowCard(IconData icon)
{
  Color accentColor = appThemeDark.accentColor;
  Widget res =  Container(
              height: 50,
              width: 160,
              child: Icon(icon, color: Colors.grey.shade300,),
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(width:1, color: Colors.grey.shade300),
                borderRadius: BorderRadius.all(Radius.circular(16))
              ),
        ); 
  

    return res;
}