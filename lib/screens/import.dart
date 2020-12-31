import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:Frek/components/cards.dart';
import '../data/models.dart';
import '../data/theme.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import '../components/cards.dart';
import 'package:Frek/services/database.dart';
import 'home.dart';
import 'package:Frek/screens/edit.dart';

class ImportScreen extends StatefulWidget {
  final Function() triggerRefetch;
  final MyHomePageState homePageState;
  final String importedType;
  ImportScreen({
    this.triggerRefetch,
    this.homePageState,
    this.importedType,
    Key key,
  }) : super(key: key) {}

  @override
  _ImportScreen createState() => _ImportScreen();
}

class _ImportScreen extends State<ImportScreen> with TickerProviderStateMixin {
  NotesModel currentNote;
  TextEditingController searchController = TextEditingController();
  NoteCardComponent currentDisplayedCard;

  List<NotesModel> importedNotes = [];

  @override
  void initState() {
    currentNote = null;
    super.initState();
    NotesDatabaseService.db.init();

    switch (this.widget.importedType) {
      case "FrekDB":
        handleImportFrekDB();
        break;
      case "FrekCard":
        handleImportFrekCard();
        break;
      case "FrekCollecion":
        handleImportFrekCollection();
        break;

      default:
        print("Type ${this.widget.importedType} not recognized in import.dart");
    }
  }

  void handleImportFrekDB() {}

  void handleImportFrekCard() {}

  void handleImportFrekCollection() {}

  Widget buildImportFrekDB() {}

  Widget buildImportFrekCard() {}

  Widget buildImportFrekCollection() {}

  @override
  Widget build(BuildContext context) {
    Widget res;
    switch (this.widget.importedType) {
      case "FrekDB":
        res = buildImportFrekDB();
        break;
      case "FrekCard":
        res = buildImportFrekCard();
        break;
      case "FrekCollecion":
        res = buildImportFrekCollection();
        break;

      default:
        print("Type ${this.widget.importedType} not recognized in import.dart");
    }

//    return Scaffold(body: res);
    return Scaffold(
      body: Text(this.widget.importedType + "\n \n -------------- \n " + this.widget.homePageState.importedFileContent),
    );
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
