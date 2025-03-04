import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/zoomable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:win_diggy/Models/Game.dart';
import 'package:win_diggy/Models/GlobalTranslations.dart';
import 'package:win_diggy/Models/URLS.dart';
import 'package:win_diggy/Models/Winner.dart';
import 'package:win_diggy/Globals.dart' as globals;
import 'package:auto_direction/auto_direction.dart';

import 'DailyContestSingleGameScreen.dart';
import 'GameWinnersScreen.dart';

Future<List<Game>> fetchCountry(http.Client client) async {
  List<Game> games;
  DataSnapshot data =
      await FirebaseDatabase.instance.reference().child('daily-list').once();
  games = await compute(parseData, data);
  return games;
}

List<Game> parseData(DataSnapshot data) {
  List<Game> games = new List<Game>();
  int index = 1;
  Map<dynamic, dynamic> map = data.value;

  List<dynamic> gamesList = new List();
  map.forEach((key, values) {
    gamesList.add(values);
  });
  print('DAILY CONTEST GAMES: ${gamesList}');

  for (var game in gamesList) {
    print('GAME: ${game['daily-game-id']}');
    games.add(
      Game(
        gameID: game['daily-game-id'].toString(),
        gamePrizeEng: game['prize'],
        gamePrizeUrd: game['prize-urdu'],
        gameType: '',
        gameStatus: '',
        wonBy: '',
        screenshot: '',
        finishTime: '',
        startTime: '',
        winnerNaame: '',
        next: false,
        status: '',
        winEngMsg: '',
        winUrdMsg: '',
        winners: [],
        bonusGame: false,
        index: index,
        gameName: game['game-name'],
      ),
    );
  }
  return games;
}

// A function that will convert a response body into a List<Country>

class DailyContestScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return WinnersScreenState();
  }
}

class WinnersScreenState extends State<DailyContestScreen> {
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
      child: Scaffold(
        //resizeToAvoidBottomPadding: false,
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(
            allTranslations.text('dailyContest'),
            style: TextStyle(color: Theme.of(context).accentColor),
          ),
          centerTitle: true,
          backgroundColor: Colors.black,
          elevation: 0,
          iconTheme: IconThemeData(
            color: Theme.of(context).accentColor,
          ),
        ),
        body: SafeArea(
          top: false,
          child: Container(
            child: Container(
              child: new FutureBuilder<List<Game>>(
                future: fetchCountry(new http.Client()),
                builder: (context, snapshot) {
                  if (snapshot.hasError) print(snapshot.error);

                  return snapshot.hasData
                      ? new InnerWinnersView(
                          gameList: snapshot.data,
                        )
                      : new Center(child: new CircularProgressIndicator());
                },
              ),
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
    globals.dailyContestGameID = '';
    Navigator.popAndPushNamed(context, '/dashboard');
    return false;
  }
}

class InnerWinnersView extends StatefulWidget {
  List<Game> gameList = new List();
  InnerWinnersView({this.gameList});
  String language = allTranslations.currentLanguage;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return InnerWinnersViewState();
  }
}

class InnerWinnersViewState extends State<InnerWinnersView> {
  List<Game> winners = new List();
  String language = allTranslations.currentLanguage;
  String parsedTime;
  bool noWinner;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    this.winners = widget.gameList;
    if (winners.length == 0)
      noWinner = true;
    else
      noWinner = false;
  }

  Widget singleTile(Game game, int index) {
    return Padding(
      padding: EdgeInsets.only(top: 8),
      child: GestureDetector(
        onTap: () {
          globals.dailyContestGameID = game.gameID;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DailyContestSingleGameScreen(),
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Material(
            //color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(8),
            elevation: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(0.08, -2.8),
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
                padding:
                    EdgeInsets.only(left: 20, right: 20, top: 13, bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      // color: Colors.blue[200],

                      alignment: Alignment.centerLeft,
                      child: AutoDirection(
                        text: language == 'ur' ? game.gameName : game.gameName,
                        child: Text(
                          language == 'ur' ? game.gameName : game.gameName,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            fontFamily: 'Futura',
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        // color: Colors.blue[100],
                        margin: EdgeInsets.only(left: 15),
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          child: AutoDirection(
                            text: language == 'ur'
                                ? game.gamePrizeUrd
                                : game.gamePrizeEng,
                            child: Text(
                              language == 'ur'
                                  ? game.gamePrizeUrd
                                  : game.gamePrizeEng,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                fontFamily: 'Noteworthy',
                                height: 1.2,
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
          ),
        ),
      ),
    );
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
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        bottom: 10,
      ),
      child: noWinner
          ? noGameAvailableDialog()
          : ListView.builder(
              //physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: winners.length,
              itemBuilder: (context, index) {
                return singleTile(winners[index], index);
              },
            ),
    );
  }
}
