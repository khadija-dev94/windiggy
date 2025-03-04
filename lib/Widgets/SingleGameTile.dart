import 'package:auto_direction/auto_direction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:win_diggy/CustomIcons/puzzle_icons_icons.dart';
import 'package:win_diggy/Models/GlobalTranslations.dart';

class SingleGameView extends StatefulWidget {
  String gameTitle;
  String prizeEng;
  String prizeUrd;
  String time;
  bool next;
  String winner;
  String status;
  ValueNotifier<String> langNotifier;
  bool bonusGame;
  int index;
  bool showGame;

  SingleGameView({
    this.gameTitle,
    this.prizeEng,
    this.prizeUrd,
    this.time,
    this.next,
    this.winner,
    this.status,
    this.langNotifier,
    this.bonusGame,
    this.index,
    this.showGame,
  });

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SingleGameViewState();
  }
}

class SingleGameViewState extends State<SingleGameView>
    with SingleTickerProviderStateMixin {
  String gameTitle;
  String prizeEng;
  String prizeUrd;

  String time;
  bool next;
  Animation<double> textAnimation;
  AnimationController animationController;
  String language = allTranslations.currentLanguage;
  String winnerName;
  String status;
  ValueNotifier<String> langNotifier;
  bool bonusGame;
  int index;
  bool showGame;

  @override
  void didUpdateWidget(SingleGameView oldWidget) {
    if (oldWidget.gameTitle != widget.gameTitle ||
        oldWidget.prizeEng != widget.prizeEng ||
        oldWidget.prizeUrd != widget.prizeUrd ||
        oldWidget.time != widget.time ||
        oldWidget.next != widget.next ||
        oldWidget.winner != widget.winner ||
        oldWidget.status != widget.status ||
        oldWidget.bonusGame != widget.bonusGame ||
        oldWidget.index != widget.index ||
        oldWidget.showGame != widget.showGame) {
      setState(() {
        gameTitle = widget.gameTitle;
        prizeEng = widget.prizeEng;
        prizeUrd = widget.prizeUrd;
        time = widget.time;
        next = widget.next;
        winnerName = widget.winner;
        status = widget.status;
        bonusGame = widget.bonusGame;
        index = widget.index;
        showGame = widget.showGame;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    this.gameTitle = widget.gameTitle;
    this.prizeEng = widget.prizeEng;
    this.prizeUrd = widget.prizeUrd;
    this.langNotifier = widget.langNotifier;
    this.time = widget.time;
    this.next = widget.next;
    winnerName = widget.winner;
    status = widget.status;
    bonusGame = widget.bonusGame;
    index = widget.index;
    showGame = widget.showGame;

    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    textAnimation = Tween(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
    );

    animationController.forward();
    textAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed)
        animationController.reverse();
      else if (status == AnimationStatus.dismissed)
        animationController.forward();
    });
  }

  Future winnerDialog(
      String title,
      String priceEng,
      String prizeUrd,
      String time,
      String winner,
      BuildContext context,
      ValueNotifier<String> lang) async {
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
              child: Stack(
                children: <Widget>[
                  Container(
                    child: Container(
                      padding: EdgeInsets.only(top: 45),
                      // color: Colors.blue[100],
                      child: Material(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                        child: Container(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.08,
                              left: 30,
                              right: 30,
                              bottom: 15),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            // crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                alignment: Alignment.topCenter,
                                //color: Colors.blue[200],
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      alignment: Alignment.center,
                                      child: Icon(
                                        PuzzleIcons.alarm_clock,
                                        color: Theme.of(context).accentColor,
                                        size:
                                            MediaQuery.of(context).size.height *
                                                0.035,
                                      ),
                                    ),
                                    Container(
                                      //  color: Colors.blue[300],

                                      alignment: Alignment.centerLeft,
                                      margin: EdgeInsets.only(left: 15),
                                      padding: EdgeInsets.only(top: 5),
                                      child: Text(
                                        time,
                                        style: TextStyle(
                                          color: Theme.of(context).accentColor,
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Futura',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                //color: Colors.blue[100],
                                alignment: Alignment.center,
                                margin: EdgeInsets.only(top: 20),
                                child: Text(
                                  winner,
                                  textAlign: TextAlign.center,
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
                                margin: EdgeInsets.only(top: 15),
                                alignment: Alignment.center,
                                child: AutoDirection(
                                  text:
                                      lang.value == 'ur' ? prizeUrd : prizeEng,
                                  child: Text(
                                    lang.value == 'ur' ? prizeUrd : prizeEng,
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
                            height: MediaQuery.of(context).size.height * 0.08,
                            width: MediaQuery.of(context).size.height * 0.08,
                            child: SvgPicture.asset(
                              'assets/cup.svg',
                              color: Theme.of(context).accentColor,
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
      },
      transitionDuration: Duration(milliseconds: 150),
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      pageBuilder: (context, animation1, animation2) {},
    );
  }

  Future gameDialog(
      String time, String title, ValueNotifier<String> lang) async {
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
              child: Stack(
                children: <Widget>[
                  Container(
                    //color: Colors.white,
                    //padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Container(
                      padding: EdgeInsets.only(top: 45),
                      child: Material(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                        child: Container(
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.08,
                            left: 30,
                            right: 30,
                            bottom: 30,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.only(top: 10, bottom: 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      //color: Colors.blue[100],
                                      alignment: Alignment.center,
                                      child: Text(
                                        allTranslations.text('will_start'),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.grey[800],
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Futura',
                                        ),
                                      ),
                                    ),
                                    Container(
                                      //color: Colors.blue[100],
                                      alignment: Alignment.center,
                                      margin: EdgeInsets.only(top: 10),
                                      child: Text(
                                        time,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Theme.of(context).accentColor,
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Futura',
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
                              //color: Color(0xffe69c21),
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
      },
      transitionDuration: Duration(milliseconds: 150),
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      pageBuilder: (context, animation1, animation2) {},
    );
  }

  Future gameCanceledDialog(
      String time, String title, ValueNotifier<String> lang) async {
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
              child: Stack(
                children: <Widget>[
                  Container(
                    //color: Colors.white,
                    //padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Container(
                      padding: EdgeInsets.only(top: 45),
                      child: Material(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                        child: Container(
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.08,
                            left: 30,
                            right: 30,
                            bottom: 30,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.only(top: 10, bottom: 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      //color: Colors.blue[100],
                                      alignment: Alignment.center,
                                      child: Text(
                                        allTranslations.text('canceled'),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.grey[800],
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Futura',
                                        ),
                                      ),
                                    ),
                                    Container(
                                      //color: Colors.blue[100],
                                      alignment: Alignment.center,
                                      margin: EdgeInsets.only(top: 10),
                                      child: Text(
                                        time,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Theme.of(context).accentColor,
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Futura',
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
                              //color: Color(0xffe69c21),
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
      },
      transitionDuration: Duration(milliseconds: 150),
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      pageBuilder: (context, animation1, animation2) {},
    );
  }

  Future gameDisqualifyDialog(
      String time, String title, ValueNotifier<String> lang) async {
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
              child: Stack(
                children: <Widget>[
                  Container(
                    //color: Colors.white,
                    //padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Container(
                      padding: EdgeInsets.only(top: 45),
                      child: Material(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                        child: Container(
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.08,
                            left: 30,
                            right: 30,
                            bottom: 30,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.only(top: 10, bottom: 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      //color: Colors.blue[100],
                                      alignment: Alignment.center,
                                      child: Text(
                                        allTranslations.text('disqualify'),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.grey[800],
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Futura',
                                        ),
                                      ),
                                    ),
                                    Container(
                                      //color: Colors.blue[100],
                                      alignment: Alignment.center,
                                      margin: EdgeInsets.only(top: 10),
                                      child: Text(
                                        time,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Theme.of(context).accentColor,
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Futura',
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
                              //color: Color(0xffe69c21),
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
      },
      transitionDuration: Duration(milliseconds: 150),
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      pageBuilder: (context, animation1, animation2) {},
    );
  }

  Widget statusWidget() {
    if (status == 'new')
      return Text(
        time,
        textAlign: TextAlign.left,
        style: TextStyle(
          color: Colors.black,
          fontSize: 14,
          fontFamily: 'Futura',
        ),
      );
    else if (status == 'complete')
      return SizedBox(
        child: AutoDirection(
          text: langNotifier.value == 'ur'
              ? winnerName + allTranslations.text('won_by')
              : allTranslations.text('won_by') + winnerName,
          child: Text(
            langNotifier.value == 'ur'
                ? winnerName + ' ' + allTranslations.text('won_by')
                : allTranslations.text('won_by') + winnerName,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontFamily: 'Futura',
              height: 1.2,
            ),
          ),
        ),
      );
    else if (status == 'Canceled')
      return AutoDirection(
        text: allTranslations.text('canceled'),
        child: Text(
          allTranslations.text('canceled'),
          textAlign: TextAlign.left,
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontFamily: 'Futura',
          ),
        ),
      );
    else
      return AutoDirection(
        text: allTranslations.text('disqualify'),
        child: Text(
          allTranslations.text('disqualify'),
          textAlign: TextAlign.left,
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontFamily: 'Futura',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    Widget titleWidget() {
      return Container(
        // color: Colors.blue[100],
        padding: EdgeInsets.symmetric(horizontal: 8),
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
            child: Container(
              padding:
                  EdgeInsets.only(left: 20, right: 13, top: 13, bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    // color: Colors.blue[200],
                    width: MediaQuery.of(context).size.width * 0.15,
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      child: bonusGame
                          ? AutoDirection(
                              text: language == 'ur'
                                  ? allTranslations.text('bonusGame')
                                  : allTranslations.text('bonusGame'),
                              child: Text(
                                language == 'ur'
                                    ? allTranslations.text('bonusGame')
                                    : allTranslations.text('bonusGame'),
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontFamily: 'Futura',
                                ),
                              ),
                            )
                          : AutoDirection(
                              text: language == 'ur'
                                  ? index.toString() +
                                      ' ' +
                                      allTranslations.text('game')
                                  : allTranslations.text('game') +
                                      ' ' +
                                      index.toString(),
                              child: Text(
                                language == 'ur'
                                    ? index.toString() +
                                        ' ' +
                                        allTranslations.text('game')
                                    : allTranslations.text('game') +
                                        ' ' +
                                        index.toString(),
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontFamily: 'Futura',
                                ),
                              ),
                            ),
                    ),
                  ),
                  Container(
                    //color: Colors.blue[100],
                    width: MediaQuery.of(context).size.width * 0.25,
                    margin: EdgeInsets.only(left: 15),
                    alignment: Alignment.center,
                    child: AutoDirection(
                      text: langNotifier.value == 'ur' ? prizeUrd : prizeEng,
                      child: Text(
                        langNotifier.value == 'ur' ? prizeUrd : prizeEng,
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
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.only(left: 15),
                      child: statusWidget(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // TODO: implement build
    return showGame
        ? Padding(
            padding: EdgeInsets.only(top: 8),
            child: GestureDetector(
              onTap: () async {
                if (status == 'new')
                  gameDialog(time, gameTitle, widget.langNotifier);
                else if (status == "complete")
                  winnerDialog(gameTitle, prizeEng, prizeUrd, time, winnerName,
                      context, widget.langNotifier);
                else if (status == 'Canceled')
                  gameCanceledDialog(time, gameTitle, widget.langNotifier);
                else if (status == 'disqualified')
                  gameDisqualifyDialog(time, gameTitle, widget.langNotifier);
                /*Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizScreen(),
            ),
          );*/
              },
              child: next
                  ? ScaleTransition(
                      scale: textAnimation,
                      child: titleWidget(),
                    )
                  : titleWidget(),
            ),
          )
        : SizedBox();
  }
}
