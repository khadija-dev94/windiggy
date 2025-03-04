import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:win_diggy/Models/GlobalTranslations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'FBMessagesScreen.dart';
import 'package:win_diggy/Globals.dart' as globals;

class ContactUsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ContactUsScreenState();
  }
}

class ContactUsScreenState extends State<ContactUsScreen> {
  final String number = "+92 308 7130163";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future<bool> closeScreen(context) async {
    globals.HOMEONFRONT = true;
    globals.onceInserted = false;
    //Navigator.of(context).pop();
    globals.resumeCalledOnce=false;
    Navigator.popAndPushNamed(context, '/dashboard');
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement buil

    ///////////////////////////////////////////////////////////////MAIN WIDGET TREE
    return WillPopScope(
      onWillPop: () {
        return closeScreen(context);
      },
      child: Scaffold(
        // resizeToAvoidBottomPadding: false,
        backgroundColor: Colors.white,

        appBar: AppBar(
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
              top: 10,
              left: 30,
              right: 30,
              bottom: 20,
            ),
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Text(
                    allTranslations.text('need_help'),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10),
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 20,
                  ),
                  child: Text(
                    allTranslations.text('help_desc'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[200],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 15),
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 20,
                  ),
                  child: Text(
                    allTranslations.text('click_chat_icon'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.15,
                    width: MediaQuery.of(context).size.height * 0.15,
                    child: GestureDetector(
                      onTap: () async {
                        //await launch('sms:$number');

                        Navigator.popAndPushNamed(context, '/messagescreen');
                      },
                      child: CircleAvatar(
                        backgroundColor: Theme.of(context).accentColor,
                        child: Icon(
                          Icons.message,
                          color: Colors.white,
                          size: MediaQuery.of(context).size.height * 0.06,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: 10,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            child: Text(
                              allTranslations.text('social_icon'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[200],
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 15),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 3),
                                  child: SvgPicture.asset(
                                    'assets/instagram.svg',
                                    //color: Colors.white,
                                    height: 35, width: 35,
                                    semanticsLabel: 'A red up arrow',
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    const url =
                                        'https://www.facebook.com/Money-Gali-105238564318974/';
                                    if (await canLaunch(url)) {
                                      await launch(url);
                                    } else {
                                      throw 'Could not launch $url';
                                    }
                                  },
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 3),
                                    child: SvgPicture.asset(
                                      'assets/facebook.svg',
                                      //color: Colors.white,
                                      height: 35, width: 35,
                                      semanticsLabel: 'A red up arrow',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    //color: Colors.blue[100],
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          child: Text(
                            'support@windiggy.com',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          constraints: BoxConstraints(
                            maxHeight:
                                MediaQuery.of(context).size.height * 0.07,
                            minHeight:
                                MediaQuery.of(context).size.height * 0.06,
                          ),
                          //width: MediaQuery.of(context).size.width * 0.60,
                          width: MediaQuery.of(context).size.width * 0.50,
                          child: RaisedButton(
                            padding: const EdgeInsets.all(0.0),
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            // color: Theme.of(context).primaryColor,
                            onPressed: () async {
                              await launch('mailto:support@windiggy.com');
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                width: double.infinity,
                                height: double.infinity,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment(0.8, -2.0),
                                    end: Alignment(0.0, 2.8),
                                    colors: [
                                      // Colors are easy thanks to Flutter's Colors class.
                                      Color(0xff5c4710),
                                      Color(0xffeccb58),
                                      Color(0xff5c4710),

                                      // Color(0xff5c4710),
                                    ],
                                  ),
                                ),
                                child: Text(
                                  allTranslations.text('call_us'),
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
