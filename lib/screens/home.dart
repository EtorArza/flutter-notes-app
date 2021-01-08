import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:Frek/screens/import.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:Frek/components/faderoute.dart';
import 'package:Frek/data/models.dart';
import 'package:Frek/screens/edit.dart';
import 'package:Frek/screens/view.dart';
import 'package:Frek/services/database.dart';
import 'settings.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import '../components/cards.dart';
import '../data/theme.dart';
import '../screens/review.dart';
import '../main.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.settings, this.myappstate}) : super(key: key) {}

  final String title;
  final Settings settings;
  final MyAppState myappstate;
  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  bool isFlagOn = false;
  bool isMultiselectOn = false;
  bool isSettingsOpen = false;
  bool isImportOpen = false;
  bool _notesAreLoading = false;
  double _opacityNotecards = 0.0;
  static const Duration _durationAnimatedOpacity = Duration(milliseconds: 250);
  Set<NotesModel> selectedNotes = Set();
  int visibilityIndex = 2;
  DateTime timeLastUpdate = DateTime.now();
  bool headerShouldHide = false;
  List<NotesModel> notesList = [];
  List<String> listOfCollectionNames = [];
  List<bool> listOfCollectionsAreTheyDue = [];
  String nameOfOpenCollection;
  TextEditingController searchController = TextEditingController();

  String importedFileExtension = null;
  String importedFileContent = null;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool isSearchEmpty = true;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    NotesDatabaseService.db.init();
    setNotesFromDB();
    visibilityIndex = 2;

    WidgetsBinding.instance.addObserver(this);
    print('InitState home.dart');
    handleImportedString();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        if (!isMultiselectOn) {
          setState(() {
            isMultiselectOn = false;
          });
        }

        if (!isSettingsOpen) {
          // print("Sharedtext before: ${this.widget.myappstate.sharedText}");
          changeOpenCollection(this.nameOfOpenCollection);

          await this.widget.myappstate.getSharedText();
          // print("Sharedtext after: ${this.widget.myappstate.sharedText}");
          // setState(() {});
          handleImportedString();

          print('resumed.');
        }

        break;
      case AppLifecycleState.inactive:
        //
        break;
      case AppLifecycleState.paused:
        if (isMultiselectOn && !isSettingsOpen) {
          toggleIsMultiselectOn();
        }
        print('paused.');
        break;
      case AppLifecycleState.detached:
        if (isMultiselectOn && !isSettingsOpen) {
          toggleIsMultiselectOn();
        }
        print('detached.');
        break;
    }
  }

  void handleImportedString() {
    print('handleImportedString()');
    if (!this.isMultiselectOn &&
        !this.isSettingsOpen &&
        !this.isImportOpen &&
        this.widget.myappstate.sharedText != "" &&
        this.widget.myappstate.sharedText != null &&
        this.widget.myappstate.sharedText != "null") {
      this.isImportOpen = true;
      importedFileExtension = this.widget.myappstate.sharedText.substring(0, this.widget.myappstate.sharedText.indexOf('.')).trim();
      importedFileContent = this.widget.myappstate.sharedText.substring(this.widget.myappstate.sharedText.indexOf('.') + 1);
      print("file_ext: $importedFileExtension");
      print("file_cont: $importedFileContent");
      this.widget.myappstate.sharedText = "";
      gotoImport();
    }
  }

  Future<void> changeOpenCollection(String nameOfCollectionToOpen) async {
    Duration initialWait = Duration(milliseconds: 200);
    await Future.delayed(initialWait, () {
      setState(() {
        this._notesAreLoading = true;
        this._opacityNotecards = 0.0;
      });
    });

    await Future.delayed(_durationAnimatedOpacity + initialWait, () async {
      await NotesDatabaseService.db.markCollectionAsOpen(nameOfCollectionToOpen);
      await setNotesFromDB();
    });
  }

  Future<void> setNotesFromDB() async {
    setState(() {
      this._notesAreLoading = true;
    });
    //print("Entered setNotes");
    var fetchedNotes = await NotesDatabaseService.db.getNotesFromCollection();
    var fetchedListOfCollectionNames = await NotesDatabaseService.db.listOfCollectionNames();
    var fetchedListOfCollectionsAreTheyDue = await NotesDatabaseService.db.listOfCollectionsAreTheyDue(fetchedListOfCollectionNames);
    var fetchedOpenName = await NotesDatabaseService.db.whichCollectionIsOpen();

    notesList = fetchedNotes;
    listOfCollectionNames = fetchedListOfCollectionNames;
    nameOfOpenCollection = fetchedOpenName;
    listOfCollectionsAreTheyDue = fetchedListOfCollectionsAreTheyDue;

    setState(() {
      this._notesAreLoading = false;
    });
  }

  refreshHome() {
    setState(() {});
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.removeCurrentSnackBar();
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
    Future.microtask(() {
      handleImportedString();
    });

    if ((!_notesAreLoading && _opacityNotecards < 0.5)) {
      scheduleMicrotask(() {
        setState(() {
          this._opacityNotecards = 1.0;
        });
      });
    }

    print("Opacity bool: ${this._opacityNotecards}");
    print("Notes are loading : ${this._notesAreLoading}");
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
          child: Column(
            children: [
              Container(height: 30),
              buildHeaderWidget(context),
              // Text( // debug only
              //   this.widget.myappstate.sharedText ?? 'null',
              //   style: TextStyle(fontSize: 25),
              // ),
              !isMultiselectOn ? buildButtonRow(context, this.notesList.length) : Container(),
              !isMultiselectOn ? buildLearnedIndicatorText() : Container(),

              Expanded(
                child: AnimatedOpacity(
                  duration: _durationAnimatedOpacity,
                  opacity: _opacityNotecards,
                  curve: Curves.easeInSine,
                  child: ListView(
                    padding: EdgeInsets.only(top: 7),
                    physics: BouncingScrollPhysics(),
                    children: <Widget>[
                      !isMultiselectOn ? Container(height: 12) : Container(),
                      !isMultiselectOn ? buildNameWidget(context) : Container(),
                      !isMultiselectOn ? Container(height: 12) : Container(),
                      ...(_notesAreLoading ? [Container()] : buildNoteComponentsList()),
                      !_notesAreLoading && notesList.length == 0 && !isMultiselectOn
                          ? Container(child: GestureDetector(onTap: gotoEditNote, child: getAddNoteCardComponent(context)))
                          : Container(),
                      !_notesAreLoading && notesList.length == 0 && isMultiselectOn
                          ? Container(
                              height: 200,
                              child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Empty collection',
                                    style: TextStyle(fontSize: 20, color: Colors.grey[500]),
                                  )))
                          : Container(),
                      Container(height: 65),
                    ],
                  ),
                ),
              )
            ],
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
                padding: EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.centerRight,
                child: Icon(
                  OMIcons.viewHeadline,
                  color: Theme.of(context).brightness == Brightness.light ? Colors.grey.shade600 : Colors.grey.shade300,
                ),
              ),
            );
          }),
          Spacer(),
          // // only for debug
          // IconButton(
          //   tooltip: 'Create random',
          //   icon: Icon(Icons.confirmation_number),
          //   onPressed: () {
          //     for (var i = 0; i < 1000; i++) {
          //       NotesDatabaseService.db.addNoteInDB(NotesModel.random());
          //     }
          //     setNotesFromDB();
          //   },
          // ),
          IconButton(
            tooltip: 'Import',
            icon: Icon(Icons.folder_open),
            onPressed: () {
              importNoteCard(this).then((value) {
                if (value = !null && value) {
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
            onTap: () async {
              this.isSettingsOpen = true;
              await Navigator.push(context, CupertinoPageRoute(builder: (context) => SettingsPage(settings: this.widget.settings)));
              this.isSettingsOpen = false;
              setNotesFromDB();
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
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
                : () {
                    int nCardsDelete = selectedNotes.length;
                    showConfirmationDialog(
                      context,
                      'Delete ' + nCardsDelete.toString() + ' card' + (nCardsDelete == 1 ? '' : 's') + '?',
                      'DELETE',
                      Colors.red[300],
                      'CANCEL',
                      () async {
                        for (var note in selectedNotes) {
                          await NotesDatabaseService.db.deleteNoteInDB(note);
                        }
                        toggleIsMultiselectOn();
                        setNotesFromDB();
                        showInSnackBar('Deleted ' + nCardsDelete.toString() + ' card' + (nCardsDelete == 1 ? '.' : 's.'));
                      },
                    );
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
              icon: Icon(Icons.reply),
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
                          'Moved ' + nOfCardsMoved.toString() + ' card' + (nOfCardsMoved == 1 ? '' : 's') + ' to ' + destinationCollectionName + '.');
                    }),
          // toggle MultiselectOn
          IconButton(
            tooltip: 'Select',
            icon: Icon(Icons.check_box),
            onPressed: toggleIsMultiselectOn,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
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
    bool isFirstCardLearned = nCards == 0 ? false : this.notesList.first.isLearned;
    return Builder(builder: (BuildContext innerContext) {
      return Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Row(
          children: <Widget>[
            GestureDetector(
              onTap: () {
                if (nCards == 0) {
                  showInSnackBar('Add a card first.');
                } else if (isFirstCardLearned) {
                  showInSnackBar('All cards learned, no cards left to review.');
                } else if (_notesAreLoading) {
                } else {
                  gotoReview();
                }
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 160),
                height: 50,
                width: 50,
                curve: Curves.slowMiddle,
                child: Icon(Icons.local_library,
                    color: isFirstCardLearned || nCards == 0 || _notesAreLoading ? Colors.grey.shade300.withAlpha(100) : Colors.grey.shade300),
                decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(
                      width: 1,
                      color: isFirstCardLearned || nCards == 0 || _notesAreLoading ? Colors.grey.shade300.withAlpha(100) : Colors.grey.shade300,
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
                  Icons.done,
                  color: isFlagOn ? Colors.greenAccent[400] : Colors.grey.shade300,
                ),
                decoration: BoxDecoration(
                    color: isFlagOn ? Colors.grey.shade700 : Colors.transparent,
                    border: Border.all(
                      width: isFlagOn ? 2 : 1,
                      color: isFlagOn ? Colors.grey.shade700 : Colors.grey.shade300,
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
        style:
            TextStyle(fontFamily: 'ZillaSlab', color: Theme.of(context).primaryColor, fontSize: (nameOfOpenCollection ?? ' ').length < 20 ? 30 : 20),
      ),
    );
  }

  Widget buildLearnedIndicatorText() {
    return AnimatedCrossFade(
      duration: Duration(milliseconds: 200),
      firstChild: Padding(
        padding: const EdgeInsets.only(top: 16, left: 16),
        child: Text(
          'Only showing learned cards'.toUpperCase(),
          style: TextStyle(fontSize: 12, color: Colors.greenAccent[400], fontWeight: FontWeight.w500),
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
          !note.originalContent
              .toLowerCase()
              .replaceAll(
                new RegExp(
                  r'(?:\:regular\:|\:default\:|\:standard\:|\:white\:|\:green\:|\:blue\:|\:pink\:|\:yellow\:|\:orange\:|\:purple\:|\:italic\:|\:normal\:|\:bold\:)',
                  unicode: false,
                  multiLine: true,
                  caseSensitive: true,
                ),
                '',
              )
              .contains(searchController.text.toLowerCase()) &&
          !note.meaningContent
              .toLowerCase()
              .replaceAll(
                  new RegExp(
                    r'(?:\:regular\:|\:default\:|\:standard\:|\:white\:|\:green\:|\:blue\:|\:pink\:|\:yellow\:|\:orange\:|\:purple\:|\:italic\:|\:normal\:|\:bold\:)',
                    unicode: false,
                    multiLine: true,
                    caseSensitive: true,
                  ),
                  '')
              .contains(searchController.text.toLowerCase());
      if ((!isFlagOn || note.isLearned) && (!discardedBySearch)) {
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
          settings: this.widget.settings,
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
    Navigator.push(context, CupertinoPageRoute(builder: (context) => EditNotePage(triggerRefetch: setNotesFromDB, homePageState: this)));
  }

  void gotoReview() async {
    Navigator.push(context, CupertinoPageRoute(builder: (context) => ReviewScreen(triggerRefetch: setNotesFromDB, homePageState: this)));
  }

  void gotoImport() {
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => ImportScreen(
                  triggerRefetch: setNotesFromDB,
                  homePageState: this,
                  importedType: this.importedFileExtension,
                  settings: this.widget.settings,
                ))).then((value) => this.isImportOpen = false);
  }

  openNoteToRead(NotesModel noteData) async {
    setState(() {
      headerShouldHide = true;
    });
    await Future.delayed(Duration(milliseconds: 230), () {});
    Navigator.push(
        context,
        FadeRoute(
            page: ViewNotePage(
          triggerRefetch: setNotesFromDB,
          currentNote: noteData,
          homePageState: this,
        )));
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
    for (var i = 0; i < listOfCollectionNames.length; i++) {
//    for (String item in this.listOfCollectionNames) {
      if (this.listOfCollectionNames[i] == tempCollectionName) {
        continue;
      }
      res.add(
        ListTile(
          selectedTileColor: Colors.grey[800],
          selected: this.listOfCollectionNames[i] == this.nameOfOpenCollection,
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  this.listOfCollectionNames[i],
                  style: TextStyle(fontFamily: 'ZillaSlab', color: Theme.of(context).primaryColor, fontSize: 20),
                  overflow: TextOverflow.fade,
                ),
              ),
              Container(
                width: 8,
              ),
              this.listOfCollectionsAreTheyDue[i] ? getDueCircle(context) : Container(),
            ],
          ),
          onTap: () async {
            // open collection
            Navigator.pop(context);
            changeOpenCollection(this.listOfCollectionNames[i]);
          },
          onLongPress: () {
            showCollectionOptionsAlertDialog(context, this.listOfCollectionNames[i], setNotesFromDB, listOfCollectionNames.length);
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
            child: FutureBuilder(
              initialData: 'waiting',
              builder: (context, snapshot) {
                return AnimatedOpacity(
                  child: snapshot.connectionState != ConnectionState.done
                      ? Container()
                      : LayoutBuilder(builder: (context, constraints) {
                          return getLibraryHeader(context, constraints.maxWidth * 0.85);
                        }),
                  opacity: snapshot.connectionState != ConnectionState.done ? 0.0 : 1.0,
                  duration: Duration(milliseconds: 500),
                );
              },
              future: Future.delayed(Duration(milliseconds: 500)),
            ),
            padding: EdgeInsets.zero,
            margin: EdgeInsets.zero,
          ),
          Container(height: 24.0),
          ...getAllItemsInDrawer(context),
          Container(height: 15.0),
          ListTile(
            title: Container(
                margin: EdgeInsets.fromLTRB(10, 3, 10, 3),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).primaryColor, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Material(
                  borderRadius: BorderRadius.circular(16),
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 5),
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
                                  padding: const EdgeInsets.all(0.0),
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
                  setNotesFromDB();
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

  Widget getLibraryHeader(BuildContext context, double libraryWidth) {
    double barHeight = 20;
    double totalBarWidth = libraryWidth - 30;

    int nCardsNotDueNotDone = this.notesList.where((e) {
      return !e.isLearned && e.dueDate.isAfter(DateTime.now());
    }).length;
    int nCardsDue = this.notesList.where((e) {
      return e.dueDate.isBefore(DateTime.now());
    }).length;
    int nCardsLearned = this.notesList.where((e) {
      return e.isLearned;
    }).length;

    return Padding(
      padding: EdgeInsets.all(20),
      child: this.notesList.length == 0
          ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(
                'Empty collection',
                style: TextStyle(fontSize: 20, color: Colors.grey[500]),
              )
            ])
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total cards: ' + this.notesList.length.toString()),
                Divider(height: 24.0),
                Text('Cards waiting: ' + nCardsNotDueNotDone.toString(), style: TextStyle(color: Colors.grey[300])),
                Text('Cards due: ' + nCardsDue.toString(), style: TextStyle(color: Colors.blue[200])),
                Text('Cards done: ' + nCardsLearned.toString(), style: TextStyle(color: Colors.greenAccent)),
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    nCardsNotDueNotDone == 0
                        ? Container()
                        : Container(
                            // not due not learned
                            width: totalBarWidth / this.notesList.length * nCardsNotDueNotDone,
                            height: barHeight,
                            decoration: BoxDecoration(color: Colors.grey[300]),
                          ),
                    nCardsDue == 0
                        ? Container()
                        : Container(
                            // due, not learned
                            width: totalBarWidth / this.notesList.length * nCardsDue,
                            height: barHeight,
                            decoration: BoxDecoration(color: Colors.blueAccent),
                          ),
                    nCardsLearned == 0
                        ? Container()
                        : Container(
                            // learned
                            width: totalBarWidth / this.notesList.length * nCardsLearned,
                            height: barHeight,
                            decoration: BoxDecoration(color: Colors.greenAccent),
                          )
                  ],
                ),
              ],
            ),
    );
  }

  void showCollectionOptionsAlertDialog(BuildContext context, String currentCollectionName, Function reloadDB, int nCollections) {
    Widget cancelButton = FlatButton(
      child: Text('Cancel'.toUpperCase(), style: TextStyle(fontSize: 10, color: Colors.grey.shade300, fontWeight: FontWeight.w500, letterSpacing: 1)),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    Widget deleteButton = FlatButton(
      child: Text('DELETE', style: TextStyle(fontSize: 10, color: Colors.red.shade300, fontWeight: FontWeight.w500, letterSpacing: 1)),
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
      child: Text('Rename'.toUpperCase(), style: TextStyle(fontSize: 10, color: Colors.grey.shade300, fontWeight: FontWeight.w500, letterSpacing: 1)),
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
      child: Text('Open'.toUpperCase(), style: TextStyle(fontSize: 10, color: Colors.grey.shade300, fontWeight: FontWeight.w500, letterSpacing: 1)),
      onPressed: () async {
        Navigator.pop(context);
        Navigator.pop(context);
        changeOpenCollection(currentCollectionName);
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
            child: Text(buttontextCancel.toUpperCase(), style: TextStyle(color: Colors.grey.shade300, fontWeight: FontWeight.w500, letterSpacing: 1)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text(buttontextProceed.toUpperCase(), style: TextStyle(color: buttonProceedColor, fontWeight: FontWeight.w500, letterSpacing: 1)),
            onPressed: () {
              callInConfirm();
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
