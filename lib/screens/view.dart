import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:Frek/data/models.dart';
import 'package:Frek/screens/edit.dart';
import 'package:Frek/screens/home.dart';
import 'package:Frek/services/database.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:share/share.dart';

class ViewNotePage extends StatefulWidget {
  Function() triggerRefetch;
  NotesModel currentNote;
  MyHomePageState homePageState;
  ViewNotePage({Key key, Function() triggerRefetch, NotesModel currentNote, MyHomePageState homePageState}) : super(key: key) {
    this.triggerRefetch = triggerRefetch;
    this.currentNote = currentNote;
    this.homePageState = homePageState;
  }
  @override
  _ViewNotePageState createState() => _ViewNotePageState();
}

class _ViewNotePageState extends State<ViewNotePage> {
  @override
  void initState() {
    super.initState();
    showHeader();
  }

  void showHeader() async {
    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        headerShouldShow = true;
      });
    });
  }

  bool headerShouldShow = false;
  @override
  Widget build(BuildContext context) {
    dynamic textAlign = TextAlign.left;

    if (widget.currentNote.originalContent.trim().split('\n').length == 1 && widget.currentNote.originalContent.length < 30) {
      textAlign = TextAlign.center;
    }

    return Scaffold(
        body: Stack(
      children: <Widget>[
        ListView(
          physics: BouncingScrollPhysics(),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
            ),
            Container(
              height: 40,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24.0, top: 36, bottom: 24, right: 24),
              child: Text(
                widget.currentNote.originalContent,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                textAlign: textAlign,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24.0, top: 36, bottom: 24, right: 24),
              child: Divider(
                height: 16.0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24.0, top: 36, bottom: 24, right: 24),
              child: Text(
                widget.currentNote.meaningContent,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                textAlign: textAlign,
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
                        icon: Icon(Icons.done),
                        color: this.widget.currentNote.isLearned ? Colors.greenAccent[400] : Colors.grey,
                        onPressed: () {
                          markLearnedAsDirty();
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline),
                        onPressed: handleDelete,
                      ),
                      IconButton(
                        icon: Icon(OMIcons.share),
                        onPressed: () => shareNoteCard(this.widget.currentNote),
                      ),
                      IconButton(
                        icon: Icon(OMIcons.edit),
                        onPressed: handleEdit,
                      ),
                    ],
                  ),
                ),
              )),
        )
      ],
    ));
  }

  void handleSave() async {
    await NotesDatabaseService.db.updateNoteInDB(widget.currentNote);
    widget.triggerRefetch();
  }

  void markLearnedAsDirty() {
    setState(() {
      widget.currentNote.isLearned = !widget.currentNote.isLearned;
    });
    handleSave();
  }

  void handleEdit() {
    Navigator.pop(context);
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => EditNotePage(
                  existingNote: widget.currentNote,
                  triggerRefetch: widget.triggerRefetch,
                  homePageState: this.widget.homePageState,
                )));
  }

  void handleBack() {
    Navigator.pop(context);
  }

  void handleDelete() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: Text('Delete Card'),
            content: Text('This card will be deleted permanently'),
            actions: <Widget>[
              FlatButton(
                child: Text('DELETE', style: TextStyle(color: Colors.red.shade300, fontWeight: FontWeight.w500, letterSpacing: 1)),
                onPressed: () async {
                  await NotesDatabaseService.db.deleteNoteInDB(widget.currentNote);
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
