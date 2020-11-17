import 'dart:async';
import 'dart:math';
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
  MyHomePage({Key key, this.title, this.settings}) : super(key: key) {}

  final String title;
  final Settings settings;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  bool isFlagOn = false;
  bool isMultiselectOn = false;
  Set<NotesModel> selectedNotes = Set();

  int visibilityIndex = 1;
  bool headerShouldHide = false;
  List<NotesModel> notesList = [];
  List<String> listOfCollectionNames = [];
  String nameOfOpenCollection;
  TextEditingController searchController = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool isSearchEmpty = true;

  @override
  void initState() {
    super.initState();
    NotesDatabaseService.db.init();
    setNotesFromDB();
    visibilityIndex = 1;
  }

  setNotesFromDB() async {
    //print("Entered setNotes");
    var fetchedNotes = await NotesDatabaseService.db.getNotesFromCollection();
    var fetchedListOfCollectionNames = await NotesDatabaseService.db.listOfCollectionNames();
    var fetchedOpenName = await NotesDatabaseService.db.whichCollectionIsOpen();

    setState(() {
      notesList = fetchedNotes;
      listOfCollectionNames = fetchedListOfCollectionNames;
      nameOfOpenCollection = fetchedOpenName;
    });
  }

  refreshHome() {
    setState(() {});
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        duration: Duration(milliseconds: 1800),
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
    //print("build_home: " + DateTime.now().toIso8601String());
    return WillPopScope(
      onWillPop: () async {
        if (isMultiselectOn) {
          toggleIsMultiselectOn();
          return false;
        }
        return true;
      },
      child: Scaffold(
        key: _scaffoldKey,
        drawer: !isMultiselectOn ? getLibraryWidget(context) : null,
        floatingActionButton: !isMultiselectOn
            ? FloatingActionButton.extended(
                backgroundColor: Theme.of(context).primaryColor,
                onPressed: () {
                  gotoEditNote();
                },
                label: Text('Add card'.toUpperCase()),
                icon: Icon(Icons.add),
              )
            : null,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Container(
            child: ListView(
              physics: BouncingScrollPhysics(),
              children: <Widget>[
                buildHeaderWidget(context),
                !isMultiselectOn ? buildButtonRow(context, this.notesList.length) : Container(),
                !isMultiselectOn ? buildImportantIndicatorText() : Container(),
                !isMultiselectOn ? Container(height: 12) : Container(),
                !isMultiselectOn ? buildNameWidget(context) : Container(),
                Container(height: 12),
                ...buildNoteComponentsList(),
                notesList.length == 0 ? GestureDetector(onTap: gotoEditNote, child: AddNoteCardComponent()) : Container(),
                Container(height: 65)
              ],
            ),
            margin: EdgeInsets.only(top: 2),
            padding: EdgeInsets.only(left: 15, right: 15),
          ),
        ),
      ),
    );
  }

  Widget buildHeaderWidget(context) {
    Widget res;

    // is not multiselect
    if (!isMultiselectOn) {
      res = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          new Builder(builder: (context) {
            return new GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Scaffold.of(context).openDrawer();
              },
              child: Container(
                padding: EdgeInsets.all(16),
                alignment: Alignment.centerRight,
                child: Icon(
                  OMIcons.viewHeadline,
                  color: Theme.of(context).brightness == Brightness.light ? Colors.grey.shade600 : Colors.grey.shade300,
                ),
              ),
            );
          }),
          Spacer(),
          // only for debug
          IconButton(
            tooltip: 'Create random',
            icon: Icon(Icons.confirmation_number),
            onPressed: () {
              for (var i = 0; i < 100; i++) {
                NotesDatabaseService.db.addNoteInDB(NotesModel.random());
              }
              setNotesFromDB();
            },
          ),
          IconButton(
            tooltip: 'Import',
            icon: Icon(Icons.folder_open),
            onPressed: () {
              importNoteCard().then((value) {
                if (value) {
                  setNotesFromDB();
                }
              });
            },
          ),
          IconButton(
              tooltip: 'Select',
              icon: Icon(Icons.check_box_outline_blank),
              onPressed: () {
                toggleIsMultiselectOn();
              }),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.push(context, CupertinoPageRoute(builder: (context) => SettingsPage(settings: this.widget.settings)));
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
      );

      // is multiselect
    } else {
      res = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // delete selected
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: selectedNotes.length == 0
                ? null
                : () async {
                    for (var note in selectedNotes) {
                      await NotesDatabaseService.db.deleteNoteInDB(note);
                    }
                    toggleIsMultiselectOn();
                    setNotesFromDB();
                  },
          ),

          // share selected
          IconButton(
            icon: Icon(Icons.share),
            onPressed: selectedNotes.length == 0
                ? null
                : () {
                    shareListOfNoteCards(selectedNotes.toList());
                    toggleIsMultiselectOn();
                  },
          ),

          // select all
          IconButton(
            icon: Icon(Icons.select_all),
            onPressed: () {
              if (selectedNotes.length < notesList.length) {
                for (var i = 0; i < notesList.length; i++) {
                  notesList[i].isSelected = true;
                }
                selectedNotes = notesList.toSet();
                setState(() {});
              } else {
                for (var i = 0; i < notesList.length; i++) {
                  notesList[i].isSelected = false;
                }
                selectedNotes = Set();
                setState(() {});
              }
            },
          ),
          Spacer(),

          // move selected
          IconButton(
              icon: Icon(Icons.reply_all),
              onPressed: selectedNotes.length == 0
                  ? null
                  : () async {
                      var destinationCollectionName = await chooseStringAlertDialog(context, listOfCollectionNames);

                      if (destinationCollectionName == null) {
                        return;
                      }

                      String openCollectionName = nameOfOpenCollection;

                      for (var note in selectedNotes) {
                        await NotesDatabaseService.db.deleteNoteInDB(note);
                      }
                      await NotesDatabaseService.db.markCollectionAsOpen(destinationCollectionName);

                      for (var note in selectedNotes) {
                        NotesDatabaseService.db.addNoteInDB(note);
                      }

                      int nOfCardsMoved = selectedNotes.length;
                      toggleIsMultiselectOn();
                      await NotesDatabaseService.db.markCollectionAsOpen(openCollectionName);
                      setNotesFromDB();
                      showInSnackBar(
                          'Moved ' + nOfCardsMoved.toString() + ' card' + (nOfCardsMoved == 1 ? '' : 's') + ' to ' + destinationCollectionName);
                    }),
          // toggle MultiselectOn
          IconButton(
            tooltip: 'Select',
            icon: Icon(Icons.check_box),
            onPressed: toggleIsMultiselectOn,
          ),
          Container(
            padding: EdgeInsets.all(16),
            alignment: Alignment.centerRight,
            child: Icon(
              OMIcons.settings,
              color: Colors.transparent,
            ),
          ),
          Container(),
        ],
      );
    }
    return res;
  }

  Widget buildButtonRow(BuildContext paramContext, int nCards) {
    return Builder(builder: (BuildContext innerContext) {
      return Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Row(
          children: <Widget>[
            GestureDetector(
              onTap: () {
                if (nCards == 0) {
                  showInSnackBar('Add a card first.');
                } else {
                  gotoReview();
                }
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
    });
  }

  Widget buildNameWidget(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20),
      child: Text(
        nameOfOpenCollection == null ? ' ' : nameOfOpenCollection,
        style: TextStyle(fontFamily: 'ZillaSlab', color: Theme.of(context).primaryColor, fontSize: 30),
      ),
    );
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

    notesList.forEach((note) {
      bool discardedBySearch = searchController.text.isNotEmpty &&
          !note.originalContent.toLowerCase().contains(searchController.text.toLowerCase()) &&
          !note.meaningContent.toLowerCase().contains(searchController.text.toLowerCase());
      if ((!isFlagOn || note.isImportant) && (!discardedBySearch)) {
        noteComponentsList.add(Container(
            child: NoteCardComponent(
          noteData: note,
          onHoldAction: !isMultiselectOn ? openNoteToRead : (NotesModel note) {},
          onTapAction: !isMultiselectOn
              ? expandNoteCard
              : (NotesModel note) {
                  selectNoteCard(note);
                },
          isVisible: visibilityIndex,
          refreshView: refreshHome,
        )));
      }
    });

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
    Navigator.push(context, CupertinoPageRoute(builder: (context) => ReviewScreen(triggerRefetch: refetchNotesFromDB, homePageState: this)));
  }

  void refetchNotesFromDB() async {
    await setNotesFromDB();
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

  selectNoteCard(NotesModel noteData) async {
    if (noteData.isSelected) {
      selectedNotes.remove(noteData);
    } else {
      selectedNotes.add(noteData);
    }
    setState(() {
      noteData.toggleSelected();
    });
  }

  void cancelSearch() {
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      searchController.clear();
      isSearchEmpty = true;
    });
  }

  void toggleIsMultiselectOn() {
    setState(() {
      isMultiselectOn = !isMultiselectOn;
    });
    while (selectedNotes.length > 0) {
      selectNoteCard(selectedNotes.first);
    }
  }

  static const String tempCollectionName = 'temp_collection_namerjw9843h34fdwflk04';

  List<Widget> getAllItemsInDrawer(BuildContext context) {
    List<Widget> res = [];
    for (String item in this.listOfCollectionNames) {
      if (item == tempCollectionName) {
        continue;
      }
      res.add(
        ListTile(
          title: Text(
            item,
            style: TextStyle(fontFamily: 'ZillaSlab', color: Theme.of(context).primaryColor, fontSize: 20),
          ),
          onTap: () async {
            // Update the state of the app.
            // ...
            await NotesDatabaseService.db.markCollectionAsOpen(item);

            refetchNotesFromDB();
            Navigator.pop(context);
          },
          onLongPress: () {
            showCollectionOptionsAlertDialog(context, item, refetchNotesFromDB, listOfCollectionNames.length);
          },
        ),
      );
    }
    return res;
  }

  Widget getLibraryWidget(BuildContext context) {
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: FittedBox(fit: BoxFit.fitWidth, child: Image(image: AssetImage('images/libraryDrawer.jpg'))),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
            ),
            padding: EdgeInsets.zero,
            margin: EdgeInsets.zero,
          ),
          ...getAllItemsInDrawer(context),
          ListTile(
            title: Container(
                margin: EdgeInsets.fromLTRB(10, 3, 10, 3),
                height: 80,
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
                                  padding: const EdgeInsets.all(1.0),
                                  child: Text(
                                    'Add new collection',
                                    style: TextStyle(fontFamily: 'ZillaSlab', color: Theme.of(context).primaryColor, fontSize: 20),
                                  ))
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )),
            onTap: () {
              // Add new collection
              showTextInputAlertDialog(context, tempCollectionName, (buttonNameAndInputTextTouple) async {
                String buttonName = buttonNameAndInputTextTouple[0];
                String inputText = buttonNameAndInputTextTouple[1];
                if (buttonName == 'Cancel' || buttonName == 'Back') {
                } else if (buttonName == 'OK') {
                  await NotesDatabaseService.db.createNewCollection(inputText == '' ? 'New Collection' : inputText);
                  await refetchNotesFromDB();
                } else {
                  print('Error, unrecognized button.');
                }
              });
            },
          ),
        ],
      ),
    );
  }

  void showCollectionOptionsAlertDialog(BuildContext context, String currentCollectionName, Function reloadDB, int nCollections) {
    Widget cancelButton = FlatButton(
      child: Text('Cancel'.toUpperCase(), style: TextStyle(color: Colors.grey.shade300, fontWeight: FontWeight.w500, letterSpacing: 1)),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    Widget deleteButton = FlatButton(
      child: Text('DELETE', style: TextStyle(color: Colors.red.shade300, fontWeight: FontWeight.w500, letterSpacing: 1)),
      onPressed: () {
        showConfirmationDialog(
          context,
          'Delete "' + currentCollectionName + '"?',
          'Delete',
          Colors.red.shade300,
          'Cancel',
          () async {
            if (nCollections == 1) {
              await Navigator.pop(context);
              await Navigator.pop(context);
              showInSnackBar('Cannot remove last collection.');
            } else {
              await NotesDatabaseService.db.deleteCollection(currentCollectionName);
              await reloadDB();
              Navigator.pop(context);
            }
          },
        );
      },
    );

    Widget renameButton = FlatButton(
      child: Text('Rename'.toUpperCase(), style: TextStyle(color: Colors.grey.shade300, fontWeight: FontWeight.w500, letterSpacing: 1)),
      onPressed: () {
        Navigator.pop(context);
        showTextInputAlertDialog(context, currentCollectionName, (buttonNameAndInputTextTouple) async {
          String buttonName = buttonNameAndInputTextTouple[0];
          String inputText = buttonNameAndInputTextTouple[1];
          if (inputText != '') {
            await NotesDatabaseService.db.renameCollection(currentCollectionName, inputText);
            await reloadDB();
          }
        });
      },
    );

    Widget openButton = FlatButton(
      child: Text('Open'.toUpperCase(), style: TextStyle(color: Colors.grey.shade300, fontWeight: FontWeight.w500, letterSpacing: 1)),
      onPressed: () async {
        // Update the state of the app.
        // ...
        await NotesDatabaseService.db.markCollectionAsOpen(currentCollectionName);
        await reloadDB();
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(
        currentCollectionName,
        style: TextStyle(fontFamily: 'ZillaSlab', color: Theme.of(context).primaryColor, fontSize: 20),
      ),
      content: Text(" "),
      actions: [
        Row(children: [
          cancelButton,
          deleteButton,
          renameButton,
          openButton,
        ]),
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  String showTextInputAlertDialog(BuildContext context, String currentCollectionName, Function(List<String>) callInExit) {
    String dialogText;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(
            "Collection name",
            style: TextStyle(fontFamily: 'ZillaSlab', color: Theme.of(context).primaryColor, fontSize: 20),
          ),
          content: TextField(
            maxLength: 40,
            onChanged: (String textTyped) {
              dialogText = textTyped;
            },
            keyboardType: TextInputType.text,
            decoration: InputDecoration(hintText: 'eg: Geman Verbs'),
            style: TextStyle(fontFamily: 'ZillaSlab', color: Theme.of(context).primaryColor, fontSize: 20),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            Row(
              children: <Widget>[
                new FlatButton(
                  child:
                      new Text('Cancel'.toUpperCase(), style: TextStyle(color: Colors.grey.shade300, fontWeight: FontWeight.w500, letterSpacing: 1)),
                  onPressed: () {
                    dialogText = '';
                    Navigator.of(context).pop(['Cancel', dialogText]);
                  },
                ),
                Container(
                  width: 10,
                ),
                new FlatButton(
                  child: new Text('Ok'.toUpperCase(), style: TextStyle(color: Colors.grey.shade300, fontWeight: FontWeight.w500, letterSpacing: 1)),
                  onPressed: () async {
                    Navigator.of(context).pop(['OK', dialogText]);
                  },
                )
              ],
            ),
          ],
        );
      },
    ).then((exit) {
      if (exit == null) {
        exit = ['Back', ''];
      }
      if (exit[1] == null) {
        exit[1] = '';
      }
      callInExit(exit);
    });
    return dialogText;
  }
}

void showConfirmationDialog(
  BuildContext context,
  String mainConfirmationText,
  String buttontextProceed,
  Color buttonProceedColor,
  String buttontextCancel,
  Function callInConfirm,
) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(mainConfirmationText, style: TextStyle(fontFamily: 'ZillaSlab', color: Theme.of(context).primaryColor, fontSize: 20)),
        content: Container(height: 0),
        actions: <Widget>[
          FlatButton(
            child: Text(buttontextProceed.toUpperCase(), style: TextStyle(color: buttonProceedColor, fontWeight: FontWeight.w500, letterSpacing: 1)),
            onPressed: () {
              callInConfirm();
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text(buttontextCancel.toUpperCase(), style: TextStyle(color: Colors.grey.shade300, fontWeight: FontWeight.w500, letterSpacing: 1)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Future<String> chooseStringAlertDialog(BuildContext context, List<String> listOfCHoices) async {
  String res = await showDialog(
    context: context,
    builder: (BuildContext context) {
      // return object of type Dialog
      return AlertDialog(
        title: new Text(
          "Collection name",
          style: TextStyle(fontFamily: 'ZillaSlab', color: Theme.of(context).primaryColor, fontSize: 20),
        ),
        content: Container(
          height: 300,
          width: 300,
          child: ListView(
            children: listOfCHoices.map(
              (element) {
                return ListTile(
                  title: Text(
                    element,
                    style: TextStyle(fontFamily: 'ZillaSlab', color: Theme.of(context).primaryColor, fontSize: 20),
                  ),
                  onTap: () async {
                    Navigator.of(context).pop(element);
                  },
                );
              },
            ).toList(),
          ),
        ),
      );
    },
  );
  return res;
}
