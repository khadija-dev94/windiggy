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

import 'package:win_diggy/Screen/ContestGames/DailyTapTapScreen.dart';
import 'ContestGames/BalloonContestGame.dart';
import 'ContestGames/ScratchCardContestGame.dart';
import 'ContestGames/ShadowContestGame.dart';
import 'ContestGames/TissueBoxContestGame.dart';
import 'DashBoard.dart';

Future<Map<String, dynamic>> fetchCountry(http.Client client) async {
  print('CURRENT GAME ID: ${globals.dailyContestGameID}');
  List<Player> players = new List();
  int myCount = 0;
  DataSnapshot playerData = await FirebaseDatabase.instance
      .reference()
      .child('daily-list')
      .child(globals.dailyContestGameID)
      .once();
  print('GAME: ${playerData.value}');

  if (playerData.value != null) {
    if (playerData.value['players'] != null)
      players = await compute(parseData, playerData);

    if (playerData.value['players_visit'] != null) {
      Map<dynamic, dynamic> map = playerData.value['players_visit'];
      print(map);
      map.forEach((key, values) {
        if (values['userID'] == globals.userID) {
          myCount = values['count'];
        }
      });
    }
    if (players.length >= 2) {
      print('${players[0].timeStampinMilli}');
      print('${players[1].timeStampinMilli}');

      if (players[0].timeStampinMilli == players[1].timeStampinMilli) {
        await FirebaseDatabase.instance
            .reference()
            .child('daily-gameresult')
            .update({
          'winner': players[0].playerName + ' and ' + players[1].playerName,
          'winner_id': players[0].playerID + ' and ' + players[1].playerID
        });
      } else
        await FirebaseDatabase.instance
            .reference()
            .child('daily-gameresult')
            .update({
          'winner': players[0].playerName,
          'winner_id': players[0].playerID
        });
    }

    return {
      'chances': playerData.value['chances'],
      'status': playerData.value['status'],
      'players': players,
      'gameID': playerData.value['daily-game-id'].toString(),
      'prize_urdu': playerData.value['prize-urdu'],
      'prize_eng': playerData.value['prize'],
      'text_urdu': playerData.value['text-urdu'],
      'text_eng': playerData.value['text'],
      'count': myCount.toString(),
      'gameType': playerData.value['gametype'],
    };
  } else
    return {};
}

// A function that will convert a response body into a List<Country>
List<Player> parseData(DataSnapshot dbData) {
  Map<dynamic, dynamic> map = dbData.value['players'];

  List<dynamic> playersList = new List();
  map.forEach((key, values) {
    playersList.add(values);
  });

  playersList
      .sort((a, b) => a['timeStampInMilli'].compareTo(b['timeStampInMilli']));

  List<Player> players = new List();
  //////////////////////////////////////////IF ONLY I PLAYED THE GAME
  if (playersList.length == 1) {
    players.add(Player.name2(
      playerID: playersList[0]['userID'],
      playerName: playersList[0]['username'],
      timeStamp: playersList[0]['timeStamp'],
      timeStampinMilli: playersList[0]['timeStampInMilli'],
    ));
  }
  ///////////////////////////////////////////////////IF OTHERS ALSO PLAYED THE GAME
  else if (playersList.length == 2) {
    players.add(Player.name2(
      playerID: playersList[0]['userID'],
      playerName: playersList[0]['username'],
      timeStamp: playersList[0]['timeStamp'],
      timeStampinMilli: playersList[0]['timeStampInMilli'],
    ));

    players.add(Player.name2(
      playerID: playersList[1]['userID'],
      playerName: playersList[1]['username'],
      timeStamp: playersList[1]['timeStamp'],
      timeStampinMilli: playersList[1]['timeStampInMilli'],
    ));
  } else {
    players.add(Player.name2(
      playerID: playersList[0]['userID'],
      playerName: playersList[0]['username'],
      timeStamp: playersList[0]['timeStamp'],
      timeStampinMilli: playersList[0]['timeStampInMilli'],
    ));

    players.add(Player.name2(
      playerID: playersList[1]['userID'],
      playerName: playersList[1]['username'],
      timeStamp: playersList[1]['timeStamp'],
      timeStampinMilli: playersList[1]['timeStampInMilli'],
    ));
    players.add(Player.name2(
      playerID: playersList[2]['userID'],
      playerName: playersList[2]['username'],
      timeStamp: playersList[2]['timeStamp'],
      timeStampinMilli: playersList[2]['timeStampInMilli'],
    ));
  }
  return players;
}

class DailyContestSingleGameScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return LeaderBoardScreenState();
  }
}

class LeaderBoardScreenState extends State<DailyContestSingleGameScreen> {
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
            allTranslations.text('dailyContest'),
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
    globals.dailyContestTissueEnabled = false;
    Navigator.of(context).pop();
    return false;
  }
}

class LeaderUIInner extends StatefulWidget {
  Map<String, dynamic> data;

  LeaderUIInner({
    this.data,
  });

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return LeaderUIInnerState();
  }
}

class LeaderUIInnerState extends State<LeaderUIInner> {
  List<Player> players = new List();
  bool canPlay;
  int attempts;
  int totalChances;
  String gameStatus;
  String language = allTranslations.currentLanguage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    players = widget.data['players'];
    totalChances = int.parse(widget.data['chances']);
    gameStatus = widget.data['status'];
    attempts = 0;
    canPlay = false;
    globals.myDailyCount = widget.data['count'];
    checkPlayStatus();
  }

  Future checkPlayStatus() async {
    print('MY CURRENT GAME COUNT:${globals.myDailyCount}');

    if (gameStatus == 'new') {
      if (widget.data['count'] == '' || widget.data['count'] == null) {
        setState(() {
          attempts = totalChances;
          canPlay = true;
        });
      } else {
        setState(() {
          attempts = totalChances - int.parse(widget.data['count']);
        });
        if (attempts != 0) {
          setState(() {
            canPlay = true;
          });
        } else
          setState(() {
            canPlay = false;
          });
      }
    } else {
      setState(() {
        canPlay = false;
        attempts = totalChances - int.parse(widget.data['count']);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            // color: Colors.blue[100],
            padding: EdgeInsets.symmetric(horizontal: 15),
            height: MediaQuery.of(context).size.height * 0.35,
            alignment: Alignment.center,
            child: Stack(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        //color: Colors.blue[100],
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              alignment: Alignment.center,
                              child: CircleAvatar(
                                backgroundColor: Colors.white.withOpacity(0.9),
                                radius:
                                    MediaQuery.of(context).size.height * 0.04,
                                child: Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Text(
                                    '2',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 10),
                              child: Text(
                                players.length == 2 || players.length == 3
                                    ? players[1].playerName
                                    : 'None',
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: TextStyle(
                                  color: Theme.of(context).accentColor,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 5),
                              alignment: Alignment.center,
                              child: Material(
                                color: Theme.of(context).accentColor,
                                borderRadius: BorderRadius.circular(30),
                                child: Container(
                                  //width: MediaQuery.of(context).size.width * 0.22,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 0,
                                    vertical: 6,
                                  ),
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Container(
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Icon(
                                              Icons.access_time,
                                              color: Colors.black,
                                              size: 10,
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(left: 3),
                                              child: Text(
                                                players.length == 2 ||
                                                        players.length == 3
                                                    ? players[1].timeStamp
                                                    : 'None',
                                                maxLines: 1,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 8,
                                                  fontWeight: FontWeight.w700,
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
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              alignment: Alignment.center,
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                radius:
                                    MediaQuery.of(context).size.height * 0.09,
                                child: Padding(
                                  padding: EdgeInsets.all(5),
                                  child: SvgPicture.asset(
                                    'assets/cup2.svg',
                                    color: Theme.of(context).accentColor,
                                    height: MediaQuery.of(context).size.height *
                                        0.09,
                                    width: MediaQuery.of(context).size.height *
                                        0.09,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 10),
                              child: Text(
                                players.length != 0
                                    ? players[0].playerName
                                    : 'None',
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: TextStyle(
                                  color: Theme.of(context).accentColor,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 5),
                              alignment: Alignment.center,
                              margin: EdgeInsets.only(left: 30, right: 30),
                              child: Material(
                                color: Theme.of(context).accentColor,
                                borderRadius: BorderRadius.circular(30),
                                child: Container(
                                  // width: MediaQuery.of(context).size.width * 0.22,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 0, vertical: 6),
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Container(
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Icon(
                                              Icons.access_time,
                                              color: Colors.black,
                                              size: 10,
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(left: 3),
                                              child: Text(
                                                players.length != 0
                                                    ? players[0].timeStamp
                                                    : 'None',
                                                maxLines: 1,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 8,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 3),
                                        child: Text(
                                          allTranslations.text('time_to_beat'),
                                          maxLines: 1,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                              fontStyle: FontStyle.italic),
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
                        //color: Colors.blue[100],
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              alignment: Alignment.center,
                              child: CircleAvatar(
                                backgroundColor: Colors.white.withOpacity(0.9),
                                radius:
                                    MediaQuery.of(context).size.height * 0.04,
                                child: Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Text(
                                    '3',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 10),
                              child: Text(
                                players.length == 3
                                    ? players[2].playerName
                                    : 'None',
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: TextStyle(
                                  color: Theme.of(context).accentColor,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(
                                top: 5,
                              ),
                              alignment: Alignment.center,
                              child: Material(
                                color: Theme.of(context).accentColor,
                                borderRadius: BorderRadius.circular(30),
                                child: Container(
                                  // width: MediaQuery.of(context).size.width * 0.22,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 0, vertical: 6),
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Container(
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Icon(
                                              Icons.access_time,
                                              color: Colors.black,
                                              size: 10,
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(left: 3),
                                              child: Text(
                                                players.length == 3
                                                    ? players[2].timeStamp
                                                    : 'None',
                                                maxLines: 1,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 8,
                                                  fontWeight: FontWeight.w700,
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
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(top: 20),
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Column(
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      language == 'ur'
                          ? widget.data['prize_urdu']
                          : widget.data['prize_eng'],
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).accentColor,
                        fontSize: 25,
                        // fontWeight: FontWeight.bold,
                        fontFamily: 'Noteworthy',
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    alignment: Alignment.topCenter,
                    padding: EdgeInsets.only(top: 10),
                    // color: Colors.blue[100],
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      //crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(left: 5),
                            child: GestureDetector(
                              onTap: canPlay
                                  ? () {
                                      if (widget.data['gameType'] ==
                                          'scratch') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ScratchCardContestScreen(),
                                          ),
                                        );
                                      } else if (widget.data['gameType'] ==
                                          'tab') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                DailyTapTapScreen(),
                                          ),
                                        );
                                      } else if (widget.data['gameType'] ==
                                          'shadow') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ShadowContestGameScreen(),
                                          ),
                                        );
                                      } else if (widget.data['gameType'] ==
                                          'tissue') {
                                        globals.dailyContestTissueEnabled =
                                            true;
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                TissueBoxContestScreen(),
                                          ),
                                        );
                                      } else if (widget.data['gameType'] ==
                                          'balloon') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                BalloonsContestGameScreen(),
                                          ),
                                        );
                                      }
                                    }
                                  : null,
                              child: canPlay
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment(0.08, -2.8),
                                            end: Alignment(0.0, 2.8),
                                            colors: [
                                              Color(0xff5c4710),
                                              Color(0xffeccb58),
                                              Color(0xff5c4710),
                                            ],
                                          ),
                                        ),
                                        child: Container(
                                          padding: EdgeInsets.only(
                                            left: 15,
                                            right: 15,
                                            top: 8.5,
                                            bottom: 8.5,
                                          ),
                                          alignment: Alignment.center,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Container(
                                                child: Icon(
                                                  Icons.play_circle_filled,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(left: 10),
                                                child: Text(
                                                  allTranslations
                                                      .text('play_NOW'),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        color: Colors.grey,
                                        child: Container(
                                          padding: EdgeInsets.only(
                                            left: 15,
                                            right: 15,
                                            top: 8.5,
                                            bottom: 8.5,
                                          ),
                                          alignment: Alignment.center,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Container(
                                                child: Icon(
                                                  Icons.play_circle_filled,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(left: 10),
                                                child: Text(
                                                  allTranslations
                                                      .text('play_NOW'),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.grey[700],
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 5),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment(0.08, -2.8),
                                  end: Alignment(0.0, 2.8),
                                  colors: [
                                    Color(0xff5c4710),
                                    Color(0xffeccb58),
                                    Color(0xff5c4710),
                                  ],
                                ),
                              ),
                              child: Container(
                                padding: EdgeInsets.only(
                                  left: 15,
                                  right: 15,
                                  top: 13,
                                  bottom: 13,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(
                                      allTranslations.text('chances'),
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 5),
                                      child: Text(
                                        attempts.toString(),
                                        maxLines: 1,
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          //fontWeight: FontWeight.w600,
                                        ),
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
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: AutoDirection(
                      text: language == 'ur'
                          ? widget.data['text_urdu']
                          : widget.data['text_eng'],
                      child: Text(
                        language == 'ur'
                            ? widget.data['text_urdu']
                            : widget.data['text_eng'],
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: 14,
                          height: 1.3,
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
    );
  }
}
