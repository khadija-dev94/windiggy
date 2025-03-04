import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:win_diggy/Screen/SlideScreen.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:win_diggy/Models/GlobalTranslations.dart';
import 'package:win_diggy/Screen/DashBoard.dart';
import 'package:win_diggy/Screen/PhoneNoScreen.dart';
import 'package:win_diggy/Globals.dart' as globals;
import 'package:url_launcher/url_launcher.dart';
import 'package:win_diggy/Screen/TermsCondScreen.dart';

class SrartupScreen extends StatefulWidget {
  @override
  SrartupScreenState createState() => new SrartupScreenState();
}

class SrartupScreenState extends State<SrartupScreen>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation<double> tweenanimation;
  Animation<double> _contentAnimation;
  String language = allTranslations.currentLanguage;
  String lang;

  @override
  void initState() {
    super.initState();

    allTranslations.onLocaleChangedCallback = _onLocaleChanged;
    if (language == 'ur')
      lang = 'English';
    else
      lang = 'اردو';
    animationController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 1500,
      ),
    );
    animationController.forward();

    tweenanimation = CurvedAnimation(
      parent: animationController,
      curve: Interval(
        0.05,
        0.40,
        curve: Curves.easeInOut,
      ),
    );
    _contentAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Interval(0.45, 0.90, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  _onLocaleChanged() async {
    // do anything you need to do if the language changes
    print('Language has been changed to: ${allTranslations.currentLanguage}');
    setState(() {
      if (allTranslations.currentLanguage == 'ur') {
        lang = 'English';
        language = 'ur';
      } else {
        lang = 'اردو';
        language = 'en';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: SafeArea(
        top: false,
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: Colors.black,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                child: Container(
                  alignment: Alignment.bottomCenter,
                  child: ScaleTransition(
                    scale: tweenanimation,
                    child: Image.asset(
                      'assets/logo_text.png',
                      height: MediaQuery.of(context).size.height * 0.25,
                      width: MediaQuery.of(context).size.height * 0.25,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  child: FadeTransition(
                    opacity: _contentAnimation,
                    child: SizedBox(
                      child: Column(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(top: 30),
                            child: Container(
                              constraints: BoxConstraints(
                                maxHeight:
                                    MediaQuery.of(context).size.height * 0.07,
                              ),
                              //width: MediaQuery.of(context).size.width * 0.60,
                              width: MediaQuery.of(context).size.width * 0.60,
                              child: RaisedButton(
                                padding: const EdgeInsets.all(0.0),
                                elevation: 6,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                                // color: Theme.of(context).primaryColor,
                                onPressed: () async {
                                  checkLoginStatus();
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment(0.08, -2.8),
                                        end: Alignment(0.0, 2.8),
                                        //stops: [0.0, 0.6, 1.0],
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
                                      allTranslations.text('let_started'),
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        fontFamily: 'Futura',
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 10),
                            child: SizedBox(
                              child: FlatButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SlideScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  allTranslations.text('how_it_works'),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Theme.of(context).accentColor,
                                    fontSize: 23,
                                    fontFamily: 'Futura',
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              alignment: Alignment.bottomCenter,
                              child: DateTime.now().timeZoneName == 'PKT'
                                  ? Container(
                                      margin: EdgeInsets.only(top: 0),
                                      child: SizedBox(
                                        child: FlatButton(
                                          onPressed: () async {
                                            await allTranslations
                                                .setNewLanguage(language == 'ur'
                                                    ? 'en'
                                                    : 'ur');
                                            setState(() {});
                                          },
                                          child: Text(
                                            lang,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color:
                                                  Theme.of(context).accentColor,
                                              fontSize: 15,
                                              fontFamily: 'Futura',
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : SizedBox(),
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool status = prefs.getBool('loggedIn');
    print('LOGIN STATUS: $status');
    if (status != null && status) {
      globals.userID = prefs.getString('id');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DashBoard(),
        ),
      );
    } else
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PhoneNoScreen()),
      );
  }
}
