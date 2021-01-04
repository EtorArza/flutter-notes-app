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
  _ImportScreen createState() => _ImportScreen();
}

class _ImportScreen extends State<ImportScreen> with TickerProviderStateMixin {
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

  @override
  void initState() {
    currentNote = null;
    super.initState();
    NotesDatabaseService.db.init();
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

  void handleImportFrekDB() {
    print("handleImportFrekDB");
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

  Widget buildImportFrekDB(BuildContext context) {
    print("buildImportFrekDB");
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
              Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'This is a backup file. You can restore it from settings.',
                    style: TextStyle(fontFamily: 'ZillaSlab', color: Theme.of(context).primaryColor, fontSize: 25),
                  )),
              Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    "If you do, all your data will be replaced. To avoid unintentionally deleting all your data, you need to go to settings to restore the backup. By forcing the user to first go settings and then select the backup file, we make sure that the user knows what it is doing (replacing all its data with the backup's content).",
                    style: TextStyle(fontFamily: 'ZillaSlab', color: Colors.grey[400], fontSize: 16),
                  )),
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
}
