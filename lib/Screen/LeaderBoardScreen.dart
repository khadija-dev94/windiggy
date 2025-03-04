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
import 'DashBoard.dart';

Future<List<Player>> fetchCountry(http.Client client) async {
  print('TAP SERVICE CALLED');
  List<Player> players = new List();
  DataSnapshot playerData =
      await FirebaseDatabase.instance.reference().child('leaderboard').once();
  if (playerData.value != null) {
    players = await compute(parseData, playerData);
    return players;
  } else
    return players;
}

// A function that will convert a response body into a List<Country>
List<Player> parseData(DataSnapshot dbData) {
  List<Player> players = new List();
  Map<dynamic, dynamic> map = dbData.value;
  List<dynamic> playersList = new List();
  map.forEach((key, values) {
    playersList.add(values);
  });

  for (var player in playersList) {
    players.add(Player.name3(
      player['user_id'],
      player['UserName'],
      player['score'],
      int.parse(player['position']),
    ));
  }
  players.sort((a, b) => a.position.compareTo(b.position));

  return players;
}

class ScoreBoardScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ScoreBoardScreenState();
  }
}

class ScoreBoardScreenState extends State<ScoreBoardScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

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
            allTranslations.text('leaderboard'),
            style: TextStyle(color: Theme.of(context).accentColor),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          top: false,
          child: Container(
            color: Colors.black,
            child: new FutureBuilder<List<Player>>(
              future: fetchCountry(new http.Client()),
              builder: (context, snapshot) {
                if (snapshot.hasError) print(snapshot.error);

                return snapshot.hasData
                    ? new ScoreBoardUI(
                        snapshot.data,
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
    // Navigator.of(context).pop();
    globals.resumeCalledOnce = false;
    Navigator.popAndPushNamed(context, '/dashboard');
    return false;
  }
}

class ScoreBoardUI extends StatefulWidget {
  List<Player> playerList;

  ScoreBoardUI(this.playerList);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ScoreBoardUIState();
  }
}

class ScoreBoardUIState extends State<ScoreBoardUI> {
  List<Player> playerList = new List();
  List<Player> secPlayerList = new List();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    playerList = widget.playerList;
    if (playerList.length > 3) secPlayerList = playerList.sublist(3);
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
                                    allTranslations.text('no_winners'),
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
    return playerList.length != 0
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
                                      backgroundColor:
                                          Colors.white.withOpacity(0.9),
                                      radius:
                                          MediaQuery.of(context).size.height *
                                              0.04,
                                      child: Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Text(
                                          playerList.length >= 2
                                              ? playerList[1]
                                                  .position
                                                  .toString()
                                              : 'None',
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
                                      playerList.length >= 2
                                          ? playerList[1].playerName
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
                                                  Container(
                                                    child: SvgPicture.asset(
                                                      'assets/star.svg',
                                                      height: 12,
                                                      width: 12,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 3),
                                                    child: Text(
                                                      playerList.length >= 2
                                                          ? playerList[1].points
                                                          : '0',
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w700,
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
                                          MediaQuery.of(context).size.height *
                                              0.09,
                                      child: Padding(
                                        padding: EdgeInsets.all(5),
                                        child: SvgPicture.asset(
                                          'assets/cup2.svg',
                                          color: Theme.of(context).accentColor,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.09,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.09,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 10),
                                    child: Text(
                                      playerList.length >= 1
                                          ? playerList[0].playerName
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
                                    margin:
                                        EdgeInsets.only(left: 30, right: 30),
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
                                                  Container(
                                                    child: SvgPicture.asset(
                                                      'assets/star.svg',
                                                      height: 12,
                                                      width: 12,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 3),
                                                    child: Text(
                                                      playerList.length >= 1
                                                          ? playerList[0].points
                                                          : '0',
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w700,
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
                            child: Container(
                              //color: Colors.blue[100],
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Container(
                                    alignment: Alignment.center,
                                    child: CircleAvatar(
                                      backgroundColor:
                                          Colors.white.withOpacity(0.9),
                                      radius:
                                          MediaQuery.of(context).size.height *
                                              0.04,
                                      child: Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Text(
                                          playerList.length >= 3
                                              ? playerList[2]
                                                  .position
                                                  .toString()
                                              : 'None',
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
                                      playerList.length >= 3
                                          ? playerList[2].playerName
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
                                                  Container(
                                                    child: SvgPicture.asset(
                                                      'assets/star.svg',
                                                      height: 12,
                                                      width: 12,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 5),
                                                    child: Text(
                                                      playerList.length >= 3
                                                          ? playerList[2].points
                                                          : '0',
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w700,
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
                    child: ListView.builder(
                      //physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: secPlayerList.length,
                      itemBuilder: (context, index) {
                        return singleCell(secPlayerList[index]);
                      },
                    ),
                  ),
                ),
              ],
            ),
          )
        : noGameAvailableDialog();
  }

  Widget singleCell(Player player) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 3),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
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
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(right: 20),
                child: Text(
                  '#' + player.position.toString(),
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 10),
                alignment: Alignment.centerLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        player.playerName,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.centerRight,
                  child: Container(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          child: SvgPicture.asset(
                            'assets/star.svg',
                            height: 17,
                            width: 17,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 10),
                          child: Text(
                            player.points,
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
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
    );
  }
}
