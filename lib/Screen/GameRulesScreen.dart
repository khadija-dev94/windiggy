import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:win_diggy/Globals.dart' as globals;
import 'package:win_diggy/Models/GlobalTranslations.dart';
import 'package:url_launcher/url_launcher.dart';

class GameRules extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    ///////////////////////////////////////////////////////////////MAIN WIDGET TREE
    return WillPopScope(
      onWillPop: () {
        return closeScreen(context);
      },
      child: Scaffold(
        // resizeToAvoidBottomPadding: false,
        backgroundColor: Colors.white,

        appBar: AppBar(
          centerTitle: true,
          title: new Text(
            allTranslations.text('game_rules'),
            style: TextStyle(color: Theme.of(context).accentColor),
          ),
          elevation: 0,
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(
            color: Theme.of(context).accentColor,
          ),
        ),
        body: SafeArea(
          top: false,
          bottom: false,
          child: Container(
            alignment: Alignment.topCenter,
            color: Colors.black,
            padding: EdgeInsets.only(
              //top: 50,
              //bottom: 50,
              top: 20,
              left: 20,
              right: 20,
              bottom: 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      allTranslations.text('terms_p85'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      allTranslations.text('terms_p109'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      allTranslations.text('terms_p134'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      allTranslations.text('terms_p135'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      allTranslations.text('terms_p136'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      allTranslations.text('terms_p86'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      allTranslations.text('terms_p87'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 30),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      allTranslations.text('terms_p88'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      allTranslations.text('terms_p89'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      allTranslations.text('terms_p90'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      allTranslations.text('terms_p91'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      allTranslations.text('terms_p92'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      allTranslations.text('terms_p93'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      allTranslations.text('terms_p94'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      allTranslations.text('terms_p95'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> closeScreen(context) async {
    globals.HOMEONFRONT = true;
    globals.onceInserted = false;
    //Navigator.of(context).pop();
    globals.resumeCalledOnce=false;
    Navigator.popAndPushNamed(context, '/dashboard');
    return false;
  }
}
