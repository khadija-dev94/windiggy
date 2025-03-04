import 'dart:convert';

import 'package:auto_direction/auto_direction.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:win_diggy/Globals.dart' as globals;
import 'package:win_diggy/Models/GlobalTranslations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:win_diggy/Models/Player.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:win_diggy/Models/URLS.dart';

import 'package:win_diggy/Screen/ContestGames/DailyTapTapScreen.dart';
import 'DashBoard.dart';

Future<Map<String, dynamic>> fetchCountry(http.Client client) async {
  Map<String, dynamic> userData;
  try {
    var url = URLS.scoreBoardURL + globals.userID;
    final response = await client.get(url);

    if (response.statusCode == 200) {
      Map mapobject = (json.decode(response.body));
      var succes = mapobject['success'];
      print("WINNERS RESPONSE");
      print(response.body);
      if (succes) {
        if (mapobject['list'].length != 0) {
          userData = {
            'dailyContestScore': mapobject['list'][0]['score'],
            'dailyContestPosition': mapobject['list'][0]['position'],
            'bonusGameScore': mapobject['list'][1]['score'],
            'bonusGamePosition': mapobject['list'][1]['position'],
            'dailyGamePosition': mapobject['list'][2]['position'],
            'dailyGameScore': mapobject['list'][2]['score'],
            'noData': false,
          };
          return userData;
        } else
          return {'noData': true};
      } else {
        print("success false");
        return {'noData': true};
      }
    } else {
      // If that call was not successful, throw an error.
      print("response code not 200");
      return {'noData': true};
    }
  } finally {
    client.close();
    print("CONNECTION CLOSED");
  }
}

class MyScoreBoardScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return LeaderBoardScreenState();
  }
}

class LeaderBoardScreenState extends State<MyScoreBoardScreen> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(color: Theme.of(context).accentColor),
          title: Text(
            allTranslations.text('scoreboard'),
            style: TextStyle(color: Theme.of(context).accentColor),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          top: false,
          child: Container(
            color: Colors.black,
            child: new FutureBuilder<Map<String, dynamic>>(
              future: fetchCountry(new http.Client()),
              builder: (context, snapshot) {
                if (snapshot.hasError) print(snapshot.error);

                return snapshot.hasData
                    ? new LeaderUIInner(
                        data: snapshot.data,
                      )
                    : new Center(child: new CircularProgressIndicator());
              },
            ),
          ),
        ),
      ),
      onWillPop: () {
        return closeScreen(context);
      },
    );
  }

  Future<bool> closeScreen(context) async {
    globals.HOMEONFRONT = true;
    globals.onceInserted = false;
    globals.resumeCalledOnce = false;
    globals.dailyContestGameID = '';
    Navigator.popAndPushNamed(context, '/dashboard');
    return false;
  }
}

class LeaderUIInner extends StatefulWidget {
  Map<String, dynamic> data;

  LeaderUIInner({this.data});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return LeaderUIInnerState();
  }
}

class LeaderUIInnerState extends State<LeaderUIInner> {
  String language = allTranslations.currentLanguage;
  bool showDialog;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.data['noData'])
      showDialog = true;
    else
      showDialog = false;
  }

  Widget noGameAvailableDialog() {
    return Container(
      child: Dialog(
        insetAnimationDuration: Duration(seconds: 1),
        insetAnimationCurve: Curves.elasticInOut,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * 0.02,
          ),
          child: Stack(
            children: <Widget>[
              Container(
                child: Container(
                  padding: EdgeInsets.only(top: 45),
                  child: Material(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    child: Container(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.10,
                        left: 30,
                        right: 30,
                        bottom: 50,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(top: 5, bottom: 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  //color: Colors.blue[100],
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.only(top: 0),
                                  child: Text(
                                    allTranslations.text('no_score'),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
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
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: MediaQuery.of(context).size.height * 0.07,
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.12,
                        width: MediaQuery.of(context).size.height * 0.12,
                        child: Image.asset(
                          'assets/logo.png',
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
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return !showDialog
        ? Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  // color: Colors.blue[100],
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  height: MediaQuery.of(context).size.height * 0.35,
                  alignment: Alignment.center,
                  child: Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.center,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: MediaQuery.of(context).size.height * 0.09,
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: SvgPicture.asset(
                                'assets/rank.svg',
                                height:
                                    MediaQuery.of(context).size.height * 0.09,
                                width:
                                    MediaQuery.of(context).size.height * 0.09,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          child: Text(
                            globals.username,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(
                              color: Theme.of(context).accentColor,
                              fontSize: 25,
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(top: 5),
                          child: Material(
                            color: Theme.of(context).accentColor,
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 30),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    allTranslations.text('position'),
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 8),
                                    child: Text(
                                      widget.data['dailyGamePosition'],
                                      maxLines: 1,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(top: 20),
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: ListView(
                      children: <Widget>[
                        Container(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Container(
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
                              padding: EdgeInsets.only(
                                  left: 20, right: 20, top: 5, bottom: 5),
                              child: Row(
                                //crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  Container(
                                    child: Text(
                                      allTranslations.text('bonusGame'),
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      alignment: Alignment.centerLeft,
                                      padding: EdgeInsets.only(
                                          left: 30, top: 7, bottom: 5),
                                      //color: Colors.blue[500],
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            padding: EdgeInsets.only(right: 5),
                                            child: Text(
                                              allTranslations.text('rank'),
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(top: 5),
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              widget.data['bonusGamePosition'],
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      alignment: Alignment.centerLeft,
                                      padding: EdgeInsets.only(
                                          left: 30, top: 7, bottom: 5),
                                      //color: Colors.blue[500],
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            padding: EdgeInsets.only(right: 5),
                                            child: Text(
                                              allTranslations.text('score'),
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(top: 5),
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              widget.data['bonusGameScore'],
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12,
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
                        Container(
                          margin: EdgeInsets.only(top: 5),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Container(
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
                              padding: EdgeInsets.only(
                                  left: 20, right: 20, top: 5, bottom: 5),
                              child: Row(
                                //crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  Container(
                                    child: Text(
                                      allTranslations.text('dailyContest'),
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      alignment: Alignment.centerLeft,
                                      padding: EdgeInsets.only(
                                          left: 30, top: 7, bottom: 5),
                                      //color: Colors.blue[500],
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            padding: EdgeInsets.only(right: 5),
                                            child: Text(
                                              allTranslations.text('rank'),
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(top: 5),
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              widget
                                                  .data['dailyContestPosition'],
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      alignment: Alignment.centerLeft,
                                      padding: EdgeInsets.only(
                                          left: 30, top: 7, bottom: 5),
                                      //color: Colors.blue[500],
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            padding: EdgeInsets.only(right: 5),
                                            child: Text(
                                              allTranslations.text('score'),
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(top: 5),
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              widget.data['dailyContestScore'],
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12,
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        : noGameAvailableDialog();
  }
}
