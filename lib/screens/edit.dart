import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/painting.dart' as prefix0;
import 'package:flutter/widgets.dart';
import 'package:notes/data/models.dart';
import 'package:notes/services/database.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class EditNotePage extends StatefulWidget {
  Function() triggerRefetch;
  NotesModel existingNote;
  EditNotePage({Key key, Function() triggerRefetch, NotesModel existingNote}) : super(key: key) {
    this.triggerRefetch = triggerRefetch;
    this.existingNote = existingNote;
  }
  @override
  _EditNotePageState createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  bool isDirty = false;
  bool isNoteNew = true;
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
        dueDate: DateTime.now().add(Duration(days: -1000)),
        isLearned: false,
        isExpanded: false,
      );
      isNoteNew = true;
    } else {
      currentNote = widget.existingNote;
      isNoteNew = false;
    }
    originalContentController.text = currentNote.originalContent;
    meaningContentController.text = currentNote.meaningContent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        ListView(
          children: <Widget>[
            Container(
              height: 80,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
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
            Divider(
              height: 16.0,
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
            )
          ],
        ),
        ClipRect(
          child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                height: 80,
                color: Theme.of(context).canvasColor.withOpacity(0.3),
                child: SafeArea(
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: handleBack,
                      ),
                      Spacer(),
                      IconButton(
                        tooltip: 'Mark note as learned',
                        icon: Icon(currentNote.isLearned ? Icons.flag : Icons.outlined_flag),
                        onPressed: originalContentController.text.trim().isNotEmpty && meaningContentController.text.trim().isNotEmpty
                            ? markLearnedAsDirty
                            : null,
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
                            child: Icon(Icons.done),
                          ))
                    ],
                  ),
                ),
              )),
        )
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
      currentNote.isLearned = !currentNote.isLearned;
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

  void handleBack() {
    Navigator.pop(context);
  }
}
