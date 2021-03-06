import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/painting.dart' as prefix0;
import 'package:flutter/widgets.dart';
import 'package:Frek/data/models.dart';
import 'package:Frek/screens/home.dart';
import 'package:Frek/services/database.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import '../components/cards.dart';
import '../screens/home.dart';

class EditNotePage extends StatefulWidget {
  Function() triggerRefetch;
  NotesModel existingNote;
  MyHomePageState homePageState;
  EditNotePage({
    Key key,
    Function() triggerRefetch,
    NotesModel existingNote,
    MyHomePageState homePageState,
  }) : super(key: key) {
    this.triggerRefetch = triggerRefetch;
    this.existingNote = existingNote;
    this.homePageState = homePageState;
  }
  @override
  _EditNotePageState createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  bool isDirty = false;
  bool isNoteNew = true;
  bool _checkDateOfMostDueCard = false;
  FocusNode titleFocus = FocusNode();
  FocusNode originalContentFocus = FocusNode();
  FocusNode meaningContentFocus = FocusNode();

  NotesModel currentNote;
  TextEditingController originalContentController = TextEditingController();
  TextEditingController meaningContentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingNote == null) {
      currentNote = NotesModel(
        originalContent: '',
        meaningContent: '',
        date: DateTime.now(),
        dueDate: DateTime.now(),
        isLearned: false,
        isExpanded: false,
      );
      isNoteNew = true;
      _setDueDateBeforeDateOfMostDueCard();
    } else {
      currentNote = widget.existingNote;
      isNoteNew = false;
    }
    originalContentController.text = currentNote.originalContent;
    meaningContentController.text = currentNote.meaningContent;
  }

  void _setDueDateBeforeDateOfMostDueCard() async {
    currentNote.dueDate = (await NotesDatabaseService.db.getDateTimeOfFirstNote()).subtract(Duration(microseconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    Widget noteCard = NoteCardComponent(
      noteData: NotesModel(
        id: -1,
        originalContent: originalContentController.text,
        meaningContent: meaningContentController.text,
        date: DateTime.now(),
        dueDate: DateTime.now(),
        isExpanded: true,
        isLearned: this.currentNote.isLearned,
      ),
      hideDueInfo: true,
      onTapAction: (note) {},
      onHoldAction: (note) {},
      refreshView: () {},
      settings: this.widget.homePageState.widget.settings,
    );
    return Scaffold(
        body: Stack(
      children: <Widget>[
        GestureDetector(
          child: Container(
            child: ListView(
              children: <Widget>[
                GestureDetector(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).canvasColor,
                    ),
                    height: 80,
                  ),
                  onTap: () {
                    titleFocus.unfocus();
                    FocusScope.of(context).requestFocus(originalContentFocus);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    focusNode: originalContentFocus,
                    controller: originalContentController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    onChanged: (value) {
                      markContentAsDirty(value);
                    },
                    onSubmitted: (text) {
                      titleFocus.unfocus();
                      FocusScope.of(context).requestFocus(meaningContentFocus);
                    },
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    decoration: InputDecoration.collapsed(
                      hintText: 'Concept to learn...',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 18, fontWeight: FontWeight.w500),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                GestureDetector(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).canvasColor,
                    ),
                    height: 16,
                  ),
                  onTap: () {
                    titleFocus.unfocus();
                    FocusScope.of(context).requestFocus(originalContentFocus);
                  },
                ),
                Divider(
                  height: 2.0,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    focusNode: meaningContentFocus,
                    controller: meaningContentController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    onChanged: (value) {
                      markContentAsDirty(value);
                    },
                    onSubmitted: (text) {
                      titleFocus.unfocus();
                      FocusScope.of(context).requestFocus(meaningContentFocus);
                    },
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    decoration: InputDecoration.collapsed(
                      hintText: 'Meaning...',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 18, fontWeight: FontWeight.w500),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Divider(
                  height: 4,
                ),
                Text(
                  '  Preview:',
                  style: TextStyle(fontFamily: 'ZillaSlab', color: Theme.of(context).primaryColor, fontSize: 40),
                  overflow: TextOverflow.fade,
                ),
                Container(child: noteCard),
              ],
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
            ),
          ),
          onTap: () {
            titleFocus.unfocus();
            FocusScope.of(context).requestFocus(meaningContentFocus);
          },
        ),
        ClipRect(
          child: Container(
            height: 80,
            color: Colors.grey[600],
            child: SafeArea(
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () => handleBack(context),
                  ),
                  Spacer(),
                  IconButton(
                    tooltip: 'Mark note as learned',
                    icon: Icon(Icons.done),
                    color: currentNote.isLearned ? Colors.greenAccent[400] : Colors.grey,
                    onPressed: markLearnedAsDirty,
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline),
                    onPressed: () {
                      handleDelete();
                    },
                  ),
                  GestureDetector(
                      onTap: handleSave,
                      child: AnimatedContainer(
                        margin: EdgeInsets.only(left: 10),
                        duration: Duration(milliseconds: 200),
                        width: isDirty ? 100 : 0,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Theme.of(context).accentColor,
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(100), bottomLeft: Radius.circular(100)),
                        ),
                        child: Icon(Icons.save_alt_outlined),
                      ))
                ],
              ),
            ),
          ),
        ),
      ],
    ));
  }

// curve: Curves.decelerate,
// child: RaisedButton.icon(
//   color: Theme.of(context).accentColor,
//   textColor: Colors.white,
//   shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.only(topLeft: Radius.circular(100), bottomLeft: Radius.circular(100))),
//   icon: Icon(Icons.done),
//   onPressed: handleSave,
//   label: Text(''),

  void handleSave() async {
    setState(() {
      currentNote.originalContent = originalContentController.text;
      currentNote.meaningContent = meaningContentController.text;
      //print('Hey there ${currentNote.originalContent} , ${currentNote.meaningContent}');
    });
    if (isNoteNew) {
      var latestNote = await NotesDatabaseService.db.addNoteInDB(currentNote);
      setState(() {
        currentNote = latestNote;
      });
    } else {
      await NotesDatabaseService.db.updateNoteInDB(currentNote);
    }
    setState(() {
      isNoteNew = false;
      isDirty = false;
    });
    widget.triggerRefetch();
    titleFocus.unfocus();
    originalContentFocus.unfocus();
    meaningContentFocus.unfocus();
  }

  void markTitleAsDirty(String title) {
    setState(() {
      isDirty = true;
    });
  }

  void markContentAsDirty(String content) {
    setState(() {
      isDirty = true;
    });
  }

  void markLearnedAsDirty() {
    setState(() {
      currentNote.toggleIsLearned();
    });
    handleSave();
  }

  void handleDelete() async {
    if (isNoteNew) {
      Navigator.pop(context);
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              title: Text('Delete Card'),
              content: Text('This card will be deleted permanently'),
              actions: <Widget>[
                FlatButton(
                  child: Text('DELETE', style: prefix0.TextStyle(color: Colors.red.shade300, fontWeight: FontWeight.w500, letterSpacing: 1)),
                  onPressed: () async {
                    await NotesDatabaseService.db.deleteNoteInDB(currentNote);
                    widget.triggerRefetch();
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text('CANCEL', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w500, letterSpacing: 1)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            );
          });
    }
  }

  void handleBack(BuildContext context) {
    if (isDirty) {
      showConfirmationDialog(context, 'Exit without saving?', 'Exit', Colors.red[300], 'Cancel', () => Navigator.pop(context));
    } else {
      Navigator.pop(context);
    }
  }
}
