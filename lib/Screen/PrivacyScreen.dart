import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:win_diggy/Globals.dart' as globals;
import 'package:win_diggy/Models/GlobalTranslations.dart';
import 'package:url_launcher/url_launcher.dart';

class Privacy extends StatelessWidget {



  Future<bool> closeScreen(context) async {
    if (globals.LoggedIn) {
      globals.HOMEONFRONT = true;
      globals.onceInserted = false;
     // Navigator.of(context).pop();
      globals.resumeCalledOnce=false;
      Navigator.popAndPushNamed(context, '/dashboard');
    }
    else
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
            allTranslations.text('privacy'),
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
                  ////////////////////////////////////////////////////////PRIVACY POLICY
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      allTranslations.text('privacy_policy_p1'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(top: 8),
                    child: Text(
                      allTranslations.text('privacy_policy_p2'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(top: 8),
                    child: Text(
                      allTranslations.text('privacy_policy_p3'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(top: 8),
                    child: Text(
                      allTranslations.text('privacy_policy_p4'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        color: Theme.of(context).accentColor,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                  //////////////////////////////////////////////////////////////INFOR COLLECTION AND USE
                  Container(
                    margin: EdgeInsets.only(top: 30),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      allTranslations.text('privacy_policy_h1'),
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
                      allTranslations.text('privacy_policy_p5'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(top: 8),
                    child: Text(
                      allTranslations.text('privacy_policy_p6'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(top: 8),
                    child: Text(
                      allTranslations.text('privacy_policy_p7'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(top: 30),
                    child: Linkify(
                      onOpen: (link) async {
                        if (await canLaunch(
                            allTranslations.text('privacy_policy_lnk1'))) {
                          await launch(
                              allTranslations.text('privacy_policy_lnk1'));
                        } else {
                          throw 'Could not launch ${allTranslations.text('privacy_policy_lnk1')}';
                        }
                      },
                      text: "https://policies.google.com/privacy",
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                      linkStyle: TextStyle(
                          color: Colors.white, fontSize: 14, height: 1.4),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(top: 8),
                    child: Linkify(
                      onOpen: (link) async {
                        if (await canLaunch(
                            allTranslations.text('privacy_policy_lnk2'))) {
                          await launch(
                              allTranslations.text('privacy_policy_lnk2'));
                        } else {
                          throw 'Could not launch ${allTranslations.text('privacy_policy_lnk2')}';
                        }
                      },
                      text: allTranslations.text('privacy_policy_lnk2'),
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                      linkStyle: TextStyle(
                          color: Colors.white, fontSize: 14, height: 1.4),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(top: 8),
                    child: Linkify(
                      onOpen: (link) async {
                        if (await canLaunch(
                            allTranslations.text('privacy_policy_lnk3'))) {
                          await launch(
                              allTranslations.text('privacy_policy_lnk3'));
                        } else {
                          throw 'Could not launch ${allTranslations.text('privacy_policy_lnk3')}';
                        }
                      },
                      text: allTranslations.text('privacy_policy_lnk3'),
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                      linkStyle: TextStyle(
                          color: Colors.white, fontSize: 14, height: 1.4),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(top: 8),
                    child: Linkify(
                      onOpen: (link) async {
                        if (await canLaunch(
                            allTranslations.text('privacy_policy_lnk4'))) {
                          await launch(
                              allTranslations.text('privacy_policy_lnk4'));
                        } else {
                          throw 'Could not launch ${allTranslations.text('privacy_policy_lnk4')}';
                        }
                      },
                      text: allTranslations.text('privacy_policy_lnk4'),
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                      linkStyle: TextStyle(
                          color: Colors.white, fontSize: 14, height: 1.4),
                    ),
                  ),

                  ///////////////////////////////////////////////////////////////LOG DATA
                  Container(
                    margin: EdgeInsets.only(top: 30),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      allTranslations.text('provacy_policy_h2'),
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
                      allTranslations.text('privacy_policy_p8'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  ),
                  ///////////////////////////////////////////////////////////////COOKIES
                  Container(
                    margin: EdgeInsets.only(top: 30),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      allTranslations.text('privacy_policy_h3'),
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
                      allTranslations.text('privacy_policy_p9'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(top: 8),
                    child: Text(
                      allTranslations.text('privacy_policy_p10'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  ),
                  ///////////////////////////////////////////////////////////////////SERVICE PROVIDERS
                  Container(
                    margin: EdgeInsets.only(top: 30),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      allTranslations.text('privacy_policy_h4'),
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
                    margin: EdgeInsets.only(top: 10),
                    child: Text(
                      allTranslations.text('privacy_polocy_p11'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(top: 30),
                    child: Text(
                      allTranslations.text('privacy_policy_p12'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          height: 1.4),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(top: 5),
                    child: Text(
                      allTranslations.text('privacy_policy_p13'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(top: 5),
                    child: Text(
                      allTranslations.text('privacy_policy_p14'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,

                          height: 1.4),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(top: 5),
                    child: Text(
                      allTranslations.text('privacy_policy_p15'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,

                          height: 1.4),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(top: 30),
                    child: Text(
                      allTranslations.text('privacy_policy_p16'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  ),
                  //////////////////////////////////////////////////////SECURITY
                  Container(
                    margin: EdgeInsets.only(top: 30),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      allTranslations.text('privacy_policy_h5'),
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
                      allTranslations.text('privacy_policy_p17'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  ),
                  ///////////////////////////////////////////////////////////LINK TO OTHER SITES
                  Container(
                    margin: EdgeInsets.only(top: 30),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      allTranslations.text('privacy_policy_h6'),
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
                      allTranslations.text('privacy_policy_p18'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  ),
                  ////////////////////////////////////////////////////////////////CHILDREN PRIVACY
                  Container(
                    margin: EdgeInsets.only(top: 30),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      allTranslations.text('privacy_policy_h7'),
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
                      allTranslations.text('privacy_policy_p19'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  ),
                  //////////////////////////////////////////////////CHANGES TO PP
                  Container(
                    margin: EdgeInsets.only(top: 30),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      allTranslations.text('privacy_policy_h8'),
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
                      allTranslations.text('privacy_policy_p20'),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.4),
                    ),
                  ),
                  ///////////////////////////////////////////////////////////CONTACT US
                  Container(
                    margin: EdgeInsets.only(top: 30),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      allTranslations.text('privacy_policy_h9'),
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
                      allTranslations.text('privacy_policy_p21'),
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
