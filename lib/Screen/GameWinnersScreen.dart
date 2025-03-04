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

class GameWinnersScreen extends StatefulWidget {
  List<Winner> winnerList;

  GameWinnersScreen(this.winnerList);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return WinnersScreenState();
  }
}

class WinnersScreenState extends State<GameWinnersScreen> {
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
            allTranslations.text('winners'),
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
                child: new InnerWinnersView(
              winnerList: widget.winnerList,
            )),
          ),
        ),
      ),
      onWillPop: () {
        return closeScreen(context);
      },
    );
  }

  Future<bool> closeScreen(context) async {
    Navigator.of(context).pop();
    return false;
  }
}

class InnerWinnersView extends StatefulWidget {
  List<Winner> winnerList = new List();
  InnerWinnersView({this.winnerList});
  String language = allTranslations.currentLanguage;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return InnerWinnersViewState();
  }
}

class InnerWinnersViewState extends State<InnerWinnersView> {
  List<Winner> winners = new List();
  String language = allTranslations.currentLanguage;
  String parsedTime;
  bool noWinner;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    this.winners = widget.winnerList;
    if (winners.length == 0)
      noWinner = true;
    else
      noWinner = false;
  }

  Widget singleTile(Winner winner, int index) {


    return Padding(
      padding: EdgeInsets.only(top: 8),
      child: GestureDetector(
        onTap: () {
          winnerDialog(
              '',
              winner.prizeMoneyEng,
              winner.prizeMoneyUrd,
              winner.finishTime,
              winner.screenshot,
              winner.winnerName,
              winner.winEngMsg,
              winner.winUrduMsg,
              context);
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
                    EdgeInsets.only(left: 20, right: 13, top: 13, bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      // color: Colors.blue[200],
                      width: MediaQuery.of(context).size.width * 0.10,
                      alignment: Alignment.centerLeft,
                      child: AutoDirection(
                        text: language == 'ur'
                            ? winner.position
                            : winner.position,
                        child: Text(
                          language == 'ur' ? winner.position : winner.position,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            fontFamily: 'Futura',
                          ),
                        ),
                      ),
                    ),
                    Container(
                      // color: Colors.blue[100],
                      width: MediaQuery.of(context).size.width * 0.30,
                      margin: EdgeInsets.only(left: 15),
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        child: AutoDirection(
                          text: language == 'ur'
                              ? winner.winnerName
                              : winner.winnerName,
                          child: Text(
                            language == 'ur'
                                ? winner.winnerName
                                : winner.winnerName,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontFamily: 'Futura',
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.centerRight,
                        //  color: Colors.blue[200],
                        child: Container(
                          //  color: Colors.blue[300],

                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.only(left: 15),

                          child: Text(
                            winner.finishTime,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontFamily: 'Futura',
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

  Future winnerDialog(
      String title,
      String price,
      String prizeUrdu,
      String finishTime,
      String image,
      String winner,
      String enMsg,
      String urdMsg,
      BuildContext context) {
    return showGeneralDialog(
      barrierColor: Colors.black.withOpacity(0.5),
      transitionBuilder: (context, a1, a2, widget) {
        return Transform.scale(
          scale: a1.value,
          child: Opacity(
            opacity: a1.value,
            child: Dialog(
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
                  fit: StackFit.expand,
                  children: <Widget>[
                    Container(
                      child: Container(
                        padding: EdgeInsets.only(top: 45, left: 5, right: 5),
                        // color: Colors.blue[100],
                        child: Material(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                          child: Container(
                            padding: EdgeInsets.only(bottom: 15),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              // crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(right: 0),
                                  alignment: Alignment.topRight,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.transparent,
                                    child: FittedBox(
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.cancel,
                                          color: Theme.of(context).primaryColor,
                                          size: 30,
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(
                                      top: 15,
                                    ),
                                    padding: EdgeInsets.only(
                                      left: 30,
                                      right: 30,
                                    ),
                                    child: SizedBox(
                                      //height: MediaQuery.of(context).size.height * 0.57,
                                      width: MediaQuery.of(context).size.width *
                                          0.65,
                                      child: CachedNetworkImage(
                                        fit: BoxFit.fill,
                                        imageUrl: image,
                                        placeholder: (context, url) => Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  //color: Colors.blue[100],
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.only(top: 10),
                                  child: Text(
                                    winner,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: Colors.grey[800],
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Futura',
                                    ),
                                  ),
                                ),
                                Container(
                                  //color: Colors.blue[100],
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.only(top: 5),
                                  child: Text(
                                    allTranslations.text('won_game'),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Futura',
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 5),
                                  alignment: Alignment.center,
                                  child: AutoDirection(
                                    text: language == 'ur' ? prizeUrdu : price,
                                    child: Text(
                                      language == 'ur' ? prizeUrdu : price,
                                      maxLines: 1,
                                      style: TextStyle(
                                        color: Theme.of(context).accentColor,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 18,
                                        fontFamily: 'Noteworthy',
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
                              height: 55,
                              width: 55,
                              child: SvgPicture.asset(
                                'assets/cup.svg',
                                color: Theme.of(context).accentColor,
                                semanticsLabel: 'A red up arrow',
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
        );
      },
      transitionDuration: Duration(milliseconds: 150),
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      pageBuilder: (context, animation1, animation2) {},
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
