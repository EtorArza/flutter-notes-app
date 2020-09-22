import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes/components/cards.dart';
import '../data/models.dart';
import '../data/theme.dart';
import 'package:outline_material_icons/outline_material_icons.dart';




class ReviewScreen extends StatefulWidget {
  Function(Brightness brightness) changeTheme;
  ReviewScreen({Key key, })
      : super(key: key);
  @override
  _ReviewScreen createState() => _ReviewScreen();
}
        


class _ReviewScreen extends State<ReviewScreen> {


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
              buildCardWidget(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('App Theme',
                      style: TextStyle(fontFamily: 'ZillaSlab', fontSize: 24)),
                  Container(
                    height: 20,
                  ),
                ],
              )),
                  Container(
                    height: 30,
                  ),
                  Center(
                    child: Text('Made With'.toUpperCase(),
                        style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          FlutterLogo(
                            size: 40,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Flutter',
                              style: TextStyle(
                                  fontFamily: 'ZillaSlab', fontSize: 24),
                            ),
                          )
                        ],
                      ),
                    ),
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
