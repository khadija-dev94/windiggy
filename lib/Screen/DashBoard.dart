import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:win_diggy/Globals.dart' as globals;

import 'package:win_diggy/Models/Game.dart';
import 'package:win_diggy/Screen/InnerHomeScreen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock/wakelock.dart';

Future<Map<String, dynamic>> fetchCountry(http.Client client) async {
  print('DASHBOARD SERVICE CALLED');

  bool blocked = false;

  DataSnapshot block = await FirebaseDatabase.instance
      .reference()
      .child('blockUser')
      .child('Game')
      .once();
  DataSnapshot userRank = await FirebaseDatabase.instance
      .reference()
      .child('leaderboard')
      .child(globals.userID)
      .once();
  DataSnapshot userScore = await FirebaseDatabase(databaseURL: globals.fdbUrl2)
      .reference()
      .child('users')
      .child('user-' + globals.userID)
      .once();
  if (userRank.value != null) {
    globals.userPosition = userRank.value['position'].toString();
  }
  globals.userScore = userScore.value['score'].toString();

  if (block.value != null) {
    List<String> list = new List();
    print('${block.value}');
    Map<dynamic, dynamic> values = block.value;
    values.forEach((key, values) {
      list.add(key);
    });
    print('BLOCK USERS:$list');
    print('MY ID:${globals.userID}');

    if (list.contains(globals.userID)) {
      {
        print('YOU ARE BLOCKED');
        blocked = true;
      }
    } else {
      blocked = false;
    }
  }

  return {
    'blocked': blocked,
  };
}

class DashBoard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return DashBoardState();
  }
}

class DashBoardState extends State<DashBoard> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    globals.HOMEONFRONT = true;
    globals.onceInserted = false;
    globals.updateCalledOnce = false;
    globals.resumeCalledOnce = false;
    Wakelock.enable();
  }

  Future _showVersionDialog(context) async {
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String title = "New Update Available";
        String message =
            "There is a newer version of app available please update it now.";
        String btnLabel = "Update Now";
        return WillPopScope(
          child: Platform.isIOS
              ? new CupertinoAlertDialog(
                  title: Text(title),
                  content: Text(message),
                  actions: <Widget>[
                    FlatButton(
                      child: Text(btnLabel),
                      onPressed: () => _launchURL(globals.APP_STORE_URL),
                    ),
                  ],
                )
              : new AlertDialog(
                  title: Text(title),
                  content: Text(message),
                  actions: <Widget>[
                    FlatButton(
                      child: Text(btnLabel),
                      onPressed: () => _launchURL(globals.PLAY_STORE_URL),
                    ),
                  ],
                ),
          onWillPop: () {},
        );
      },
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: SafeArea(
        top: false,
        child: Stack(
          children: <Widget>[
            Container(
              color: Colors.black,
            ),
            Container(
              child: new FutureBuilder<Map<String, dynamic>>(
                future: fetchCountry(new http.Client()),
                builder: (context, snapshot) {
                  if (snapshot.hasError) print(snapshot.error);

                  return snapshot.hasData
                      ? new HomePage(
                          serverData: snapshot.data,
                        )
                      : new Center(child: new CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
