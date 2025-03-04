import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:win_diggy/Globals.dart' as globals;
import 'package:win_diggy/Models/GlobalTranslations.dart';
import 'package:url_launcher/url_launcher.dart';

class Terms extends StatelessWidget {
  Future<bool> closeScreen(context) async {
    if (globals.LoggedIn) {
      globals.HOMEONFRONT = true;
      globals.onceInserted = false;
      // Navigator.of(context).pop();
      globals.resumeCalledOnce = false;
      Navigator.popAndPushNamed(context, '/dashboard');
    } else
      Navigator.of(context).pop();
    return false;
  }

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
            allTranslations.text('terms_cond'),
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
                  //////////////////////////////////////////////////////////////INTERPRETTION AND DEFINITION
                  Container(
                    //margin: EdgeInsets.only(top: 30),
                    alignment: Alignment.center,
                    child: Text(
                      allTranslations.text('terms_h1'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.4),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(top: 20),
                    child: Text(
                      allTranslations.text('terms_sh1'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        color: Theme.of(context).accentColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      allTranslations.text('terms_p1'),
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
                      allTranslations.text('terms_p2'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(top: 20),
                    child: Text(
                      allTranslations.text('terms_sb2'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        color: Theme.of(context).accentColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      allTranslations.text('terms_p3'),
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
                    child: RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(
                        text: allTranslations.text('terms_p4'),
                        style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            height: 1.4),
                        children: <TextSpan>[
                          TextSpan(
                            text: allTranslations.text('terms_p5'),
                            style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontSize: 14,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.normal,
                                height: 1.4),
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    alignment: Alignment.centerLeft,
                    child: RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(
                        text: allTranslations.text('terms_p6'),
                        style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            height: 1.4),
                        children: <TextSpan>[
                          TextSpan(
                            text: allTranslations.text('terms_p7'),
                            style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontSize: 14,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.normal,
                                height: 1.4),
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    alignment: Alignment.centerLeft,
                    child: RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(
                        text: allTranslations.text('terms_p8'),
                        style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            height: 1.4),
                        children: <TextSpan>[
                          TextSpan(
                            text: allTranslations.text('terms_p9'),
                            style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontSize: 14,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.normal,
                                height: 1.4),
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    alignment: Alignment.centerLeft,
                    child: RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(
                        text: allTranslations.text('terms_p10'),
                        style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            height: 1.4),
                        children: <TextSpan>[
                          TextSpan(
                            text: allTranslations.text('terms_p11'),
                            style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontSize: 14,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.normal,
                                height: 1.4),
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    alignment: Alignment.centerLeft,
                    child: RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(
                        text: allTranslations.text('terms_p12'),
                        style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            height: 1.4),
                        children: <TextSpan>[
                          TextSpan(
                            text: allTranslations.text('terms_p13'),
                            style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontSize: 14,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.normal,
                                height: 1.4),
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    alignment: Alignment.centerLeft,
                    child: RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(
                        text: allTranslations.text('terms_p14'),
                        style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            height: 1.4),
                        children: <TextSpan>[
                          TextSpan(
                            text: allTranslations.text('terms_p15'),
                            style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontSize: 14,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.normal,
                                height: 1.4),
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    alignment: Alignment.centerLeft,
                    child: RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(
                        text: allTranslations.text('terms_p16'),
                        style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            height: 1.4),
                        children: <TextSpan>[
                          TextSpan(
                            text: allTranslations.text('terms_p17'),
                            style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontSize: 14,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.normal,
                                height: 1.4),
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    alignment: Alignment.centerLeft,
                    child: RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(
                        text: allTranslations.text('terms_p18'),
                        style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            height: 1.4),
                        children: <TextSpan>[
                          TextSpan(
                            text: allTranslations.text('terms_p19'),
                            style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontSize: 14,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.normal,
                                height: 1.4),
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    alignment: Alignment.centerLeft,
                    child: RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(
                        text: allTranslations.text('terms_p20'),
                        style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            height: 1.4),
                        children: <TextSpan>[
                          TextSpan(
                            text: allTranslations.text('terms_p21'),
                            style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontSize: 14,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.normal,
                                height: 1.4),
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    alignment: Alignment.centerLeft,
                    child: RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(
                        text: allTranslations.text('terms_p22'),
                        style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            height: 1.4),
                        children: <TextSpan>[
                          TextSpan(
                            text: allTranslations.text('terms_p23'),
                            style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontSize: 14,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.normal,
                                height: 1.4),
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    alignment: Alignment.centerLeft,
                    child: RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(
                        text: allTranslations.text('terms_p24'),
                        style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            height: 1.4),
                        children: <TextSpan>[
                          TextSpan(
                            text: allTranslations.text('terms_p25'),
                            style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontSize: 14,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.normal,
                                height: 1.4),
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    alignment: Alignment.centerLeft,
                    child: RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(
                        text: allTranslations.text('terms_p26'),
                        style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            height: 1.4),
                        children: <TextSpan>[
                          TextSpan(
                            text: allTranslations.text('terms_p27'),
                            style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontSize: 14,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.normal,
                                height: 1.4),
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    alignment: Alignment.centerLeft,
                    child: RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(
                        text: allTranslations.text('terms_p28'),
                        style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            height: 1.4),
                        children: <TextSpan>[
                          TextSpan(
                            text: allTranslations.text('terms_p29'),
                            style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontSize: 14,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.normal,
                                height: 1.4),
                          )
                        ],
                      ),
                    ),
                  ),
                  //////////////////////////////////////////////////////////////ACKNOWLEDGMENT
                  Container(
                    margin: EdgeInsets.only(top: 30),
                    alignment: Alignment.center,
                    child: Text(
                      allTranslations.text('terms_h2'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.4),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      allTranslations.text('terms_p30'),
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
                      allTranslations.text('terms_p31'),
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
                      allTranslations.text('terms_p32'),
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
                      allTranslations.text('terms_p33'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  ),
                  //////////////////////////////////////////////////////////////PROMOTION
                  Container(
                    margin: EdgeInsets.only(top: 30),
                    alignment: Alignment.center,
                    child: Text(
                      allTranslations.text('terms_h3'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.4),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      allTranslations.text('terms_p34'),
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
                      allTranslations.text('terms_p35'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  ),
                  //////////////////////////////////////////////////////////////USER ACCOUNTS
                  Container(
                    margin: EdgeInsets.only(top: 30),
                    alignment: Alignment.center,
                    child: Text(
                      allTranslations.text('terms_h4'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.4),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      allTranslations.text('terms_p36'),
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
                      allTranslations.text('terms_p37'),
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
                      allTranslations.text('terms_p38'),
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
                      allTranslations.text('terms_p39'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  ),
                  //////////////////////////////////////////////////////////////CONTENT
                  Container(
                    margin: EdgeInsets.only(top: 30),
                    alignment: Alignment.center,
                    child: Text(
                      allTranslations.text('terms_h5'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.4),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(top: 20),
                    child: Text(
                      allTranslations.text('terms_sh3'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        color: Theme.of(context).accentColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      allTranslations.text('terms_p40'),
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
                      allTranslations.text('terms_p41'),
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
                      allTranslations.text('terms_p42'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(top: 20),
                    child: Text(
                      allTranslations.text('terms_sh4'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        color: Theme.of(context).accentColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      allTranslations.text('terms_p43'),
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
                      allTranslations.text('terms_p44'),
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
                      allTranslations.text('terms_p45'),
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
                      allTranslations.text('terms_p46'),
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
                      allTranslations.text('terms_p47'),
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
                      allTranslations.text('terms_p48'),
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
                      allTranslations.text('terms_p49'),
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
                      allTranslations.text('terms_p50'),
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
                      allTranslations.text('terms_p51'),
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
                      allTranslations.text('terms_p52'),
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
                      allTranslations.text('terms_p53'),
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
                      allTranslations.text('terms_p54'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  ),

                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(top: 20),
                    child: Text(
                      allTranslations.text('terms_sb5'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        color: Theme.of(context).accentColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      allTranslations.text('terms_p55'),
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
                      allTranslations.text('terms_p56'),
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
                      allTranslations.text('terms_p57'),
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
                      allTranslations.text('terms_p58'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  ),
                  //////////////////////////////////////////////////////////////COPYRIGHT
                  Container(
                    margin: EdgeInsets.only(top: 30),
                    alignment: Alignment.center,
                    child: Text(
                      allTranslations.text('terms_h6'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 1.4),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(top: 20),
                    child: Text(
                      allTranslations.text('terms_sh6'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        color: Theme.of(context).accentColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      allTranslations.text('terms_p59'),
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
                      allTranslations.text('terms_p60'),
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
                      allTranslations.text('terms_p61'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(top: 20),
                    child: Text(
                      allTranslations.text('terms_sh7'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        color: Theme.of(context).accentColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      allTranslations.text('terms_p62'),
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
                      allTranslations.text('terms_p63'),
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
                      allTranslations.text('terms_p64'),
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
                      allTranslations.text('terms_p65'),
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
                      allTranslations.text('terms_p66'),
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
                      allTranslations.text('terms_p67'),
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
                      allTranslations.text('terms_p68'),
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
                      allTranslations.text('terms_p69'),
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
                      allTranslations.text('terms_p70'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  ),
                  //////////////////////////////////////////////////////////////INTELLECCTUAL COPYRIGHT
                  Container(
                    margin: EdgeInsets.only(top: 30),
                    alignment: Alignment.center,
                    child: Text(
                      allTranslations.text('terms_h7'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 1.4),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      allTranslations.text('terms_p71'),
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
                      allTranslations.text('terms_p72'),
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
                      allTranslations.text('terms_p73'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  ),
                  //////////////////////////////////////////////////////////////LINK TO OTHER SITES
                  Container(
                    margin: EdgeInsets.only(top: 30),
                    alignment: Alignment.center,
                    child: Text(
                      allTranslations.text('terms_h8'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 1.4),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      allTranslations.text('terms_p74'),
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
                      allTranslations.text('terms_p75'),
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
                      allTranslations.text('terms_p76'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  ),
                  //////////////////////////////////////////////////////////////TERMINATION
                  Container(
                    margin: EdgeInsets.only(top: 30),
                    alignment: Alignment.center,
                    child: Text(
                      allTranslations.text('terms_h9'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 1.4),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      allTranslations.text('terms_p77'),
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
                      allTranslations.text('terms_p78'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  ),
                  //////////////////////////////////////////////////////////////LIMITATIONOF LIABILITY
                  Container(
                    margin: EdgeInsets.only(top: 30),
                    alignment: Alignment.center,
                    child: Text(
                      allTranslations.text('terms_h10'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 1.4),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      allTranslations.text('terms_p79'),
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
                      allTranslations.text('terms_p80'),
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
                      allTranslations.text('terms_p81'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  ),

                  //////////////////////////////////////////////////////////////DISCLAIMER
                  Container(
                    margin: EdgeInsets.only(top: 30),
                    alignment: Alignment.center,
                    child: Text(
                      allTranslations.text('terms_h11'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 1.4),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      allTranslations.text('terms_p82'),
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
                      allTranslations.text('terms_p83'),
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
                      allTranslations.text('terms_p84'),
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
                      allTranslations.text('terms_p110'),
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
                      allTranslations.text('terms_p111'),
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
                      allTranslations.text('terms_p112'),
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
                      allTranslations.text('terms_p113'),
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
                      allTranslations.text('terms_p114'),
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
                      allTranslations.text('terms_p115'),
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
                      allTranslations.text('terms_p116'),
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
                      allTranslations.text('terms_p117'),
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
                      allTranslations.text('terms_p118'),
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
                      allTranslations.text('terms_p119'),
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
                      allTranslations.text('terms_p120'),
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
                      allTranslations.text('terms_p121'),
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
                      allTranslations.text('terms_p122'),
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
                      allTranslations.text('terms_p123'),
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
                      allTranslations.text('terms_p124'),
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
                      allTranslations.text('terms_p125'),
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
                      allTranslations.text('terms_p126'),
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
                      allTranslations.text('terms_p127'),
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
                      allTranslations.text('terms_p128'),
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
                      allTranslations.text('terms_p129'),
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
                      allTranslations.text('terms_p130'),
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
                      allTranslations.text('terms_p131'),
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
                      allTranslations.text('terms_p132'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  ),
                  //////////////////////////////////////////////////////////////GAME RULES
                  Container(
                    margin: EdgeInsets.only(top: 30),
                    alignment: Alignment.center,
                    child: Text(
                      allTranslations.text('terms_h12'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 1.4),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
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
                  //////////////////////////////////////////////////////////////GOVERNING LAW
                  Container(
                    margin: EdgeInsets.only(top: 30),
                    alignment: Alignment.center,
                    child: Text(
                      allTranslations.text('terms_h13'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 1.4),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      allTranslations.text('terms_p96'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  ),
                  //////////////////////////////////////////////////////////////DISPUTES RESOLUTION
                  Container(
                    margin: EdgeInsets.only(top: 30),
                    alignment: Alignment.center,
                    child: Text(
                      allTranslations.text('terms_h14'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 1.4),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      allTranslations.text('terms_p97'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  ),
                  //////////////////////////////////////////////////////////////EUROPIEN USERS
                  Container(
                    margin: EdgeInsets.only(top: 30),
                    alignment: Alignment.center,
                    child: Text(
                      allTranslations.text('terms_h15'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 1.4),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      allTranslations.text('terms_p98'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  ),
                  //////////////////////////////////////////////////////////////LEGAL COMPLIANCE
                  Container(
                    margin: EdgeInsets.only(top: 30),
                    alignment: Alignment.center,
                    child: Text(
                      allTranslations.text('terms_h16'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 1.4),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      allTranslations.text('terms_p99'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  ),
                  //////////////////////////////////////////////////////////////SEVERABILITY
                  Container(
                    margin: EdgeInsets.only(top: 30),
                    alignment: Alignment.center,
                    child: Text(
                      allTranslations.text('terms_h17'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 1.4),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(top: 20),
                    child: Text(
                      allTranslations.text('terms_sh8'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        color: Theme.of(context).accentColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      allTranslations.text('terms_p100'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(top: 20),
                    child: Text(
                      allTranslations.text('terms_sh9'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        color: Theme.of(context).accentColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      allTranslations.text('terms_p101'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  ),
                  //////////////////////////////////////////////////////////////TRANSLATION
                  Container(
                    margin: EdgeInsets.only(top: 30),
                    alignment: Alignment.center,
                    child: Text(
                      allTranslations.text('terms_h18'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 1.4),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      allTranslations.text('terms_p102'),
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
                      allTranslations.text('terms_p103'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  ),
                  //////////////////////////////////////////////////////////////CHANGES TO TTERMS AND CONT
                  Container(
                    margin: EdgeInsets.only(top: 30),
                    alignment: Alignment.center,
                    child: Text(
                      allTranslations.text('terms_h19'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 1.4),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      allTranslations.text('terms_p104'),
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
                      allTranslations.text('terms_p105'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  ),
                  //////////////////////////////////////////////////////////////CONTACT US
                  Container(
                    margin: EdgeInsets.only(top: 30),
                    alignment: Alignment.center,
                    child: Text(
                      allTranslations.text('terms_h20'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 1.4),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      allTranslations.text('terms_p106'),
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
                      allTranslations.text('terms_p107'),
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
                      allTranslations.text('terms_p108'),
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
}
