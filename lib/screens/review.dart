import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes/components/cards.dart';
import '../data/models.dart';
import '../data/theme.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import '../components/cards.dart';
import 'package:notes/services/database.dart';
import 'home.dart';
import 'package:notes/screens/edit.dart';

class ReviewScreen extends StatefulWidget {
  final Function() triggerRefetch;
  final MyHomePageState homePageState;
  ReviewScreen({
    this.triggerRefetch,
    this.homePageState,
    Key key,
  }) : super(key: key) {}

  @override
  _ReviewScreen createState() => _ReviewScreen();
}

class _ReviewScreen extends State<ReviewScreen> with TickerProviderStateMixin {
  NotesModel currentNote;
  TextEditingController searchController = TextEditingController();
  NoteCardComponent currentDisplayedCard;

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
          boxShadow: [BoxShadow(offset: Offset(0, 8), color: Colors.black.withAlpha(20), blurRadius: 16)]),
      margin: EdgeInsets.all(24),
      padding: EdgeInsets.all(16),
      child: child,
    );
  }

  void gotoEditNoteFromReview() {
    Navigator.push(
        context, CupertinoPageRoute(builder: (context) => EditNotePage(triggerRefetch: this.widget.triggerRefetch, existingNote: currentNote)));
  }

  @override
  Widget build(BuildContext context) {
    if (currentNote == null) {
      return Container();
    }

    NoteCardComponent noteCard = NoteCardComponent(
      noteData: currentNote,
      onHoldAction: (currentNote) {
        gotoEditNoteFromReview();
      },
      onTapAction: expandNoteCard,
      isVisible: this.widget.homePageState.visibilityIndex,
      refreshView: loadMostDueNoteFromDB,
    );

    MediaQueryData queryData;
    queryData = MediaQuery.of(context);

    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 25,
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              this.widget.triggerRefetch();
              Navigator.pop(context);
            },
            child: Container(padding: const EdgeInsets.only(top: 24, left: 24, right: 24), child: Icon(OMIcons.arrowBack)),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 8, right: 24),
            child: buildHeaderWidget(context),
          ),
          Row(children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: this.widget.homePageState.buildHeaderWidget(context),
            ),
            //Expanded(child: Container()),
            buildButtonRowReview(),
          ]),
          Container(height: 8),
          Expanded(
            //height: MediaQuery.of(context).size.height - 140,
            child: ListView(
              shrinkWrap: true,
              reverse: this.widget.homePageState.widget.settings.cardPositionInReview == 'top'
                  ? false
                  : true, // this should be the parameter changed in settings
              physics: BouncingScrollPhysics(),
              // crossAxisAlignment: CrossAxisAlignment.start,
              // mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[noteCard],
            ),
          )
        ],
      ),
    );
  }

  Widget buildHeaderWidget(BuildContext context) {
    return Container();
  }

  expandNoteCard(NotesModel noteData) async {
    setState(() {
      noteData.toggleExpand();
    });
  }

  Widget buildButtonRowReview() {
    return Builder(builder: (BuildContext innerContext) {
      return Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Row(
          children: <Widget>[
            Container(
              width: 8.0,
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  this.widget.homePageState.visibilityIndex = (this.widget.homePageState.visibilityIndex + 1) % 3;
                });
              },
              child: getVisibilityButton(this.widget.homePageState.visibilityIndex),
            ),
          ],
        ),
      );
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
