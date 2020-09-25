import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes/components/cards.dart';
import '../data/models.dart';
import '../data/theme.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import '../components/cards.dart';
import 'package:notes/services/database.dart';



class ReviewScreen extends StatefulWidget {
  ReviewScreen({Key key,}) : super(key: key) {
  }

  @override
  _ReviewScreen createState() => _ReviewScreen();
}
        


class _ReviewScreen extends State<ReviewScreen> {


  NotesModel currentNote;
  TextEditingController searchController = TextEditingController();
  NoteCardComponent currentDisplayedCard;

  bool isSearchEmpty = true;

  @override
  void initState() {
    currentNote = null;
    super.initState();
    NotesDatabaseService.db.init();
    loadMostDueNoteFromDB();
  }

  void loadMostDueNoteFromDB() async {
    NotesModel fetchedNote = await NotesDatabaseService.db.getMostDueNoteFromDB();
    setState(() {
      currentNote = fetchedNote;
    });
  }




  Widget buildCardWidget(Widget child) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).dialogBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                offset: Offset(0, 8),
                color: Colors.black.withAlpha(20),
                blurRadius: 16)
          ]),
      margin: EdgeInsets.all(24),
      padding: EdgeInsets.all(16),
      child: child,
    );
  }


  @override
  Widget build (BuildContext context) {

      if (currentNote == null) {
        return Container();
      }

      currentDisplayedCard = NoteCardComponent(
      noteData: currentNote,
      onHoldAction: (currentNote) {},
      onTapAction: (currentNote) {},
      isVisible: 1,
    );


    return  Scaffold(
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          Container(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                    padding:
                        const EdgeInsets.only(top: 24, left: 24, right: 24),
                    child: Icon(OMIcons.arrowBack)),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 36, right: 24),
                child: buildHeaderWidget(context),
              ),
              currentDisplayedCard.getNonExpandedCard(1, context) // Card
              ,
                  Container(
                    height: 30,
                  ),
                  
                ],
              ))
            ],
          ),
          );
  }

  Widget buildHeaderWidget(BuildContext context) {
    return Container();
  }




}
