import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Frek/components/cards.dart';
import '../data/models.dart';
import '../components/cards.dart';
import 'package:Frek/services/database.dart';
import 'home.dart';
import 'settings.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class ImportScreen extends StatefulWidget {
  final Function() triggerRefetch;
  final MyHomePageState homePageState;
  final String importedType;
  final Settings settings;
  ImportScreen({
    this.triggerRefetch,
    this.homePageState,
    this.importedType,
    this.settings,
    Key key,
  }) : super(key: key) {}

  @override
  ImportScreenState createState() => ImportScreenState();
}

class ImportScreenState extends State<ImportScreen> with TickerProviderStateMixin {
  NotesModel currentNote;
  TextEditingController searchController = TextEditingController();
  NoteCardComponent currentDisplayedCard;
  List<String> fetchedListOfCollectionNames = [];
  List<DropdownMenuItem> dropdownMenuItems = [];
  List<NotesModel> importedNotes = [];
  String _selectedCollectionName = 'Choose a collection';
  int selectedCollectionNameIndex = 0;
  bool _popContextOnError = false;
  String _popContextOnErrorMessageForSnackBar = '';

  // backup restore
  bool allowExitSettings = true;
  bool _showBackupProgress = false;
  bool _backupJustDone = false;
  bool _corruptedFileErrorDuringBackup = false;
  double _backupProgress = 0.0;
  bool _backupRestoreMode = false;
  bool _checkboxConfirmed = false;

  @override
  void initState() {
    currentNote = null;
    super.initState();
    NotesDatabaseService.db.init();
    _backupRestoreMode = false;
    print("Imported type in initState import.dart: ${this.widget.importedType}");
    switch (this.widget.importedType) {
      case "FrekDB":
        handleImportFrekDB();
        break;
      case "FrekCard":
        handleImportFrekCard();
        break;
      case "FrekCollection":
        handleImportFrekCollection();
        break;

      default:
        this._popContextOnError = true;
        this._popContextOnErrorMessageForSnackBar = 'Corrupted or\nincompatible file.';
        print("Type ${this.widget.importedType} not recognized in import.dart");
    }
  }

  Widget backButton(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(padding: const EdgeInsets.only(top: 24, left: 24, right: 24), child: Icon(OMIcons.arrowBack)),
    );
  }

  void handleImportFrekDB() async {
    _backupRestoreMode = true;
  }

  void handleImportFrekCard() async {
    print("handleImportFrekCard");
    try {
      this.importedNotes = [fromStringToNotesModel(this.widget.homePageState.importedFileContent)];
      await handleImportColelctionOrCart();
    } catch (e) {
      _popContextOnErrorMessageForSnackBar = 'Error importing card,\ncorrupted file.';
      setState(() {
        _popContextOnError = true;
      });
    }
  }

  void handleImportFrekCollection() async {
    print("handleImportFrekCollection");
    try {
      this.importedNotes = fromStringToListOfNotesModel(this.widget.homePageState.importedFileContent);
      await handleImportColelctionOrCart();
    } catch (e) {
      _popContextOnErrorMessageForSnackBar = 'Error importing collection,\ncorrupted file.';
      setState(() {
        _popContextOnError = true;
      });
    }
  }

  Future<void> handleImportColelctionOrCart() async {
    fetchedListOfCollectionNames = await NotesDatabaseService.db.listOfCollectionNames();

    List<DropdownMenuItem<dynamic>> fetchedDropdownItems = [];
    for (var i = 0; i < fetchedListOfCollectionNames.length; i++) {
      fetchedDropdownItems.add(DropdownMenuItem(
          child: Text(
            fetchedListOfCollectionNames[i].length > 15 ? fetchedListOfCollectionNames[i].substring(0, 13) + '...' : fetchedListOfCollectionNames[i],
          ),
          value: i));
    }

    setState(() {
      dropdownMenuItems = fetchedDropdownItems;
    });
  }

  Future<void> restoreBackup() async {
    allowExitSettings = false;
    setState(() {
      _showBackupProgress = true;
    });

    await NotesDatabaseService.db.restoreBackup(this, context, this.widget.homePageState);
  }

  Widget buildImportFrekDB(BuildContext context) {
    return _showBackupProgress
        ? WillPopScope(
            onWillPop: () async {
              return allowExitSettings;
            },
            child: Scaffold(
              body: ListView(
                physics: BouncingScrollPhysics(),
                children: <Widget>[Container(child: this._getProgressBar())],
              ),
            ))
        : Scaffold(
            body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 25,
              ),
              backButton(context),
              Spacer(),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'This is a backup file.',
                          style: TextStyle(fontFamily: 'ZillaSlab', color: Theme.of(context).primaryColor, fontSize: 25),
                        )),
                    Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          "You can restore it. If you do, all your data will be irreversibly replaced.",
                          style: TextStyle(fontFamily: 'ZillaSlab', color: Colors.grey[400], fontSize: 16),
                        )),
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Text(
                            "I understand what I am doing",
                            style: TextStyle(
                              fontFamily: 'ZillaSlab',
                              color: Colors.grey[400],
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.visible,
                          ),
                          Checkbox(
                              value: _checkboxConfirmed,
                              onChanged: (value) {
                                setState(() {
                                  _checkboxConfirmed = value;
                                });
                              }),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Container(
                              padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: Colors.grey[600], border: Border.all()),
                              child: Text(
                                'cancel'.toUpperCase(),
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            if (_checkboxConfirmed && _backupRestoreMode) {
                              await restoreBackup();
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Container(
                              padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: _checkboxConfirmed ? Colors.blueAccent : Colors.grey[600],
                                  border: Border.all()),
                              child: Text(
                                'restore'.toUpperCase(),
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Spacer(),
            ],
          ));
  }

  Widget buildImportFrekCard(BuildContext context) {
    print("buildImportFrekCard");
    return buildImportFrekCollection(context); // the same as importing collection
  }

  Widget buildImportFrekCollection(BuildContext context) {
    print("buildImportFrekCollection");
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 25,
          ),
          backButton(context),
          Padding(
            padding: EdgeInsets.only(top: 5, left: 20),
            child: Text(
              "Import  ${this.importedNotes.length} card${this.importedNotes.length == 1 ? '' : 's'}",
              style: TextStyle(fontFamily: 'ZillaSlab', color: Theme.of(context).primaryColor, fontSize: 30),
            ),
          ),
          Container(height: 30),
          Expanded(
            child: ListView(
              padding: EdgeInsets.only(top: 7),
              physics: BouncingScrollPhysics(),
              children: <Widget>[
                ...getCardsFromImportedNotes(),
              ],
            ),
          ),
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 5, left: 15),
                child: Text(
                  "to collection ",
                  style: TextStyle(fontFamily: 'ZillaSlab', color: Theme.of(context).primaryColor, fontSize: 25),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: Colors.cyan[800], border: Border.all()),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                        value: selectedCollectionNameIndex,
                        items: dropdownMenuItems,
                        onChanged: (value) {
                          setState(() {
                            _selectedCollectionName = fetchedListOfCollectionNames[value];
                            selectedCollectionNameIndex = value;
                          });
                        }),
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Container(
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: Colors.grey[600], border: Border.all()),
                    child: Text(
                      'cancel'.toUpperCase(),
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  await NotesDatabaseService.db.markCollectionAsOpen(_selectedCollectionName);
                  DateTime timeDueFirst = (await NotesDatabaseService.db.getDateTimeOfFirstNote()).subtract(Duration(microseconds: 1));
                  for (var note in importedNotes) {
                    note.date = DateTime.now();
                    note.dueDate = timeDueFirst;
                    await NotesDatabaseService.db.addNoteInDB(note);
                  }

                  Navigator.pop(context);
                  this.widget.triggerRefetch();
                },
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Container(
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: Colors.green[600], border: Border.all()),
                    child: Text(
                      'import'.toUpperCase(),
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> getCardsFromImportedNotes() {
    List<Widget> noteComponentsList = [];

    this.importedNotes.forEach((note) {
      var noteCard = NoteCardComponent(
        noteData: note,
        onHoldAction: (NotesModel note) {},
        onTapAction: (NotesModel note) {},
        isVisible: 0,
        refreshView: () {},
        settings: this.widget.settings,
        hideDueInfo: true,
      );
      noteComponentsList.add(Container(child: noteCard));
    });

    return noteComponentsList;
  }

  @override
  Widget build(BuildContext context) {
    print("_popContextOnError: $_popContextOnError");

    if (_popContextOnError) {
      print("_popContextOnErrorMessageForSnackBar: $_popContextOnErrorMessageForSnackBar");

      // Future.delayed(Duration(milliseconds: 4000), () {
      //   Navigator.pop(context, _popContextOnErrorMessageForSnackBar);
      // });

      return Scaffold(
          body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 25,
          ),
          backButton(context),
          Spacer(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _popContextOnErrorMessageForSnackBar,
                  style: TextStyle(fontFamily: 'ZillaSlab', color: Theme.of(context).primaryColor, fontSize: 25),
                ),
                IconButton(
                  icon: Icon(Icons.error_outline),
                  onPressed: () {},
                  color: Colors.yellow[800],
                  iconSize: 25,
                )
              ],
            ),
          ),
          Spacer(),
        ],
      ));
    }

    if (dropdownMenuItems.length == 0 && (this.widget.importedType == 'FrekCard' || this.widget.importedType == 'FrekCollection')) {
      return Scaffold();
    }
    Widget res;
    switch (this.widget.importedType) {
      case "FrekDB":
        res = buildImportFrekDB(context);
        break;
      case "FrekCard":
        res = buildImportFrekCard(context);
        break;
      case "FrekCollection":
        res = buildImportFrekCollection(context);
        break;

      default:
        print("Type ${this.widget.importedType} not recognized in import.dart");
    }

//    return Scaffold(body: res);
    return Scaffold(body: res);
  }

  Widget buildCardWidget(Widget child) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).dialogBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(offset: Offset(0, 8), color: Colors.black.withAlpha(20), blurRadius: 16)]),
      margin: EdgeInsets.all(24),
      padding: EdgeInsets.all(16),
      child: child,
    );
  }

  void setBackupProgress(double progress) {
    print("progress: " + progress.toString());
    setState(() {
      _backupProgress = progress * 0.8;
    });
  }

  void showProgressBar() {
    setState(() {
      _showBackupProgress = true;
    });
  }

  void closeProgressBar() {
    const int nSteps = 20;
    const int nMilSecondsLastPartProgress = 1000;
    const int nMiliSecondsDoneInScreen = 750;
    for (int i = 0; i <= nSteps; i++) {
      Future.delayed(Duration(milliseconds: nMilSecondsLastPartProgress * i ~/ nSteps), () {
        setState(() {
          _backupProgress = 0.8 + 0.2 * i.toDouble() / nSteps.toDouble();
        });
      });
    }
    Future.delayed(Duration(milliseconds: nMilSecondsLastPartProgress), () {
      setState(() {
        _backupJustDone = true;
      });
    });

    Future.delayed(Duration(milliseconds: nMiliSecondsDoneInScreen + nMilSecondsLastPartProgress), () {
      allowExitSettings = true;
      Navigator.pop(context);
    });

    Future.delayed(Duration(milliseconds: nMiliSecondsDoneInScreen + nMilSecondsLastPartProgress + 500), () {
      // setState(() {
      //   _showBackupProgress = false;
      //   _backupJustDone = false;
      // });
    });
  }

  void closeProgressBarOnCorruptedFile() {
    const int nSteps = 60;
    const int nMilSecondsLastPartProgress = 250;
    const int nMiliSecondsDoneInScreen = 4750;
    double currentProgress = _backupProgress;

    for (int i = 0; i <= nSteps; i++) {
      Future.delayed(Duration(milliseconds: nMilSecondsLastPartProgress * i ~/ nSteps), () {
        setState(() {
          _backupProgress = currentProgress * (1.0 - i.toDouble() / nSteps.toDouble());
        });
      });
    }
    Future.delayed(Duration(milliseconds: nMilSecondsLastPartProgress), () {
      setState(() {
        _corruptedFileErrorDuringBackup = true;
      });
    });

    Future.delayed(Duration(milliseconds: nMiliSecondsDoneInScreen + nMilSecondsLastPartProgress), () {
      allowExitSettings = true;
      Navigator.pop(context);
    });
  }

  Widget _getProgressBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 36),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Restoring backup...', style: TextStyle(fontFamily: 'ZillaSlab', color: Theme.of(context).primaryColor, fontSize: 20)),
            Container(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.done),
                  onPressed: () {},
                  color: Color.fromARGB(0, 0, 0, 0),
                ),
                Container(
                  color: Color.fromARGB(255, 0, 0, 0),
                  width: MediaQuery.of(context).size.width * 0.9 - 100,
                  child: LinearProgressIndicator(
                    value: _backupProgress,
                  ),
                ),
                _backupJustDone || _corruptedFileErrorDuringBackup
                    ? IconButton(
                        icon: Icon(_corruptedFileErrorDuringBackup ? Icons.error_outline : Icons.done),
                        onPressed: () {},
                        color: _corruptedFileErrorDuringBackup ? Colors.yellow[800] : Colors.green[400],
                      )
                    : IconButton(
                        icon: Icon(Icons.done),
                        onPressed: () {},
                        color: Color.fromARGB(0, 0, 0, 0),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
