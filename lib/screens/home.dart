import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:notes/components/faderoute.dart';
import 'package:notes/data/models.dart';
import 'package:notes/screens/edit.dart';
import 'package:notes/screens/view.dart';
import 'package:notes/services/database.dart';
import 'settings.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import '../components/cards.dart';
import '../data/theme.dart';
import '../screens/review.dart';

class MyHomePage extends StatefulWidget {
  Function(Brightness brightness) changeTheme;
  MyHomePage({Key key, this.title, Function(Brightness brightness) changeTheme}) : super(key: key) {
    this.changeTheme = changeTheme;
  }

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isFlagOn = false;
  int visibilityIndex = 1;
  bool headerShouldHide = false;
  List<NotesModel> notesList = [];
  TextEditingController searchController = TextEditingController();

  bool isSearchEmpty = true;

  @override
  void initState() {
    super.initState();
    NotesDatabaseService.db.init();
    setNotesFromDB();
    visibilityIndex = 1;
  }

  setNotesFromDB() async {
    print("Entered setNotes");
    var fetchedNotes = await NotesDatabaseService.db.getNotesFromDB();
    setState(() {
      notesList = fetchedNotes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () {
          gotoEditNote();
        },
        label: Text('Add note'.toUpperCase()),
        icon: Icon(Icons.add),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Container(
          child: ListView(
            physics: BouncingScrollPhysics(),
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Navigator.push(context, CupertinoPageRoute(builder: (context) => SettingsPage(changeTheme: widget.changeTheme)));
                    },
                    child: Container(
                      padding: EdgeInsets.all(16),
                      alignment: Alignment.centerRight,
                      child: Icon(
                        OMIcons.settings,
                        color: Theme.of(context).brightness == Brightness.light ? Colors.grey.shade600 : Colors.grey.shade300,
                      ),
                    ),
                  ),
                ],
              ),
              buildHeaderWidget(context),
              buildButtonRow(),
              buildImportantIndicatorText(),
              Container(height: 32),
              ...buildNoteComponentsList(),
              GestureDetector(onTap: gotoEditNote, child: AddNoteCardComponent()),
              Container(height: 100)
            ],
          ),
          margin: EdgeInsets.only(top: 2),
          padding: EdgeInsets.only(left: 15, right: 15),
        ),
      ),
    );
  }

  Widget buildButtonRow() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              gotoReview();
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 160),
              height: 50,
              width: 50,
              curve: Curves.slowMiddle,
              child: Icon(Icons.local_library, color: Colors.grey.shade300),
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(
                    width: 1,
                    color: Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(16))),
            ),
          ),
          Container(
            width: 8.0,
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                isFlagOn = !isFlagOn;
              });
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 160),
              height: 50,
              width: 50,
              curve: Curves.slowMiddle,
              child: Icon(
                isFlagOn ? Icons.flag : OMIcons.flag,
                color: isFlagOn ? Colors.white : Colors.grey.shade300,
              ),
              decoration: BoxDecoration(
                  color: isFlagOn ? Colors.blue : Colors.transparent,
                  border: Border.all(
                    width: isFlagOn ? 2 : 1,
                    color: isFlagOn ? Colors.blue.shade700 : Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(16))),
            ),
          ),
          Container(
            width: 8.0,
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                visibilityIndex = (visibilityIndex + 1) % 3;
              });
            },
            child: getVisibilityButton(visibilityIndex),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(left: 8),
              padding: EdgeInsets.only(left: 16),
              height: 50,
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.all(Radius.circular(16))),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      maxLines: 1,
                      onChanged: (value) {
                        handleSearch(value);
                      },
                      autofocus: false,
                      keyboardType: TextInputType.text,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration.collapsed(
                        hintText: 'Search',
                        hintStyle: TextStyle(color: Colors.grey.shade300, fontSize: 18, fontWeight: FontWeight.w500),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(isSearchEmpty ? Icons.search : Icons.cancel, color: Colors.grey.shade300),
                    onPressed: cancelSearch,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildHeaderWidget(BuildContext context) {
    return Row();
  }

  Widget testListItem(Color color) {
    return new NoteCardComponent(
      noteData: NotesModel.random(),
    );
  }

  Widget buildImportantIndicatorText() {
    return AnimatedCrossFade(
      duration: Duration(milliseconds: 200),
      firstChild: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          'Only showing notes marked important'.toUpperCase(),
          style: TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w500),
        ),
      ),
      secondChild: Container(
        height: 2,
      ),
      crossFadeState: isFlagOn ? CrossFadeState.showFirst : CrossFadeState.showSecond,
    );
  }

  List<Widget> buildNoteComponentsList() {
    List<Widget> noteComponentsList = [];
    notesList.sort((a, b) {
      return a.dueDate.compareTo(b.dueDate);
    });
    if (searchController.text.isNotEmpty) {
      notesList.forEach((note) {
        if (note.originalContent.toLowerCase().contains(searchController.text.toLowerCase()) ||
            note.meaningContent.toLowerCase().contains(searchController.text.toLowerCase()))
          noteComponentsList.add(NoteCardComponent(
            noteData: note,
            onHoldAction: openNoteToRead,
            onTapAction: expandNoteCard,
            isVisible: visibilityIndex,
          ));
      });
      return noteComponentsList;
    }
    if (isFlagOn) {
      notesList.forEach((note) {
        if (note.isImportant)
          noteComponentsList.add(Container(
              child: NoteCardComponent(
            noteData: note,
            onHoldAction: openNoteToRead,
            onTapAction: expandNoteCard,
            isVisible: visibilityIndex,
          )));
      });
    } else {
      notesList.forEach((note) {
        noteComponentsList.add(Container(
            child: NoteCardComponent(
          noteData: note,
          onHoldAction: openNoteToRead,
          onTapAction: expandNoteCard,
          isVisible: visibilityIndex,
        )));
      });
    }
    return noteComponentsList;
  }

  void handleSearch(String value) {
    if (value.isNotEmpty) {
      setState(() {
        isSearchEmpty = false;
      });
    } else {
      setState(() {
        isSearchEmpty = true;
      });
    }
  }

  void gotoEditNote() {
    Navigator.push(context, CupertinoPageRoute(builder: (context) => EditNotePage(triggerRefetch: refetchNotesFromDB)));
  }

  void gotoReview() async {
    Navigator.push(context, CupertinoPageRoute(builder: (context) => ReviewScreen()));
  }

  void refetchNotesFromDB() async {
    await setNotesFromDB();
    print("Refetched notes");
  }

  openNoteToRead(NotesModel noteData) async {
    setState(() {
      headerShouldHide = true;
    });
    await Future.delayed(Duration(milliseconds: 230), () {});
    Navigator.push(context, FadeRoute(page: ViewNotePage(triggerRefetch: refetchNotesFromDB, currentNote: noteData)));
    await Future.delayed(Duration(milliseconds: 300), () {});

    setState(() {
      headerShouldHide = false;
    });
  }

  expandNoteCard(NotesModel noteData) async {
    setState(() {
      noteData.toggleExpand();
    });
  }

  void cancelSearch() {
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      searchController.clear();
      isSearchEmpty = true;
    });
  }
}

Widget getVisibilityButton(int visibilityIndex) {
  Widget visibilityButton;
  Color accentColor = appThemeDark.accentColor;
  if (visibilityIndex == 0) {
    visibilityButton = AnimatedContainer(
      duration: Duration(milliseconds: 250),
      height: 50,
      width: 50,
      curve: Curves.slowMiddle,
      child: Icon(
        Icons.visibility,
        color: Colors.white,
      ),
      decoration: BoxDecoration(
          color: accentColor, border: Border.all(width: 2, color: Colors.blue.shade700), borderRadius: BorderRadius.all(Radius.circular(16))),
    );
  } else if (visibilityIndex == 1) {
    visibilityButton = Container(
      height: 50,
      width: 50,
      child: Icon(
        OMIcons.visibility,
        color: Colors.grey.shade300,
      ),
      decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [accentColor, Colors.transparent]),
          color: accentColor,
          border: Border.all(width: 1, color: Colors.grey.shade300),
          borderRadius: BorderRadius.all(Radius.circular(16))),
    );
  } else if (visibilityIndex == 2) {
    visibilityButton = Container(
      height: 50,
      width: 50,
      child: Icon(
        OMIcons.visibility,
        color: Colors.grey.shade300,
      ),
      decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [accentColor, Colors.transparent]),
          color: accentColor,
          border: Border.all(width: 1, color: Colors.grey.shade300),
          borderRadius: BorderRadius.all(Radius.circular(16))),
    );
  }

  return visibilityButton;
}
