import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:auto_direction/auto_direction.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:win_diggy/CustomIcons/puzzle_icons_icons.dart';
import 'package:win_diggy/Models/GlobalMethods.dart';
import 'package:win_diggy/Models/GlobalTranslations.dart';
import 'package:win_diggy/Widgets/CurrentPlayers.dart';
import 'package:win_diggy/Globals.dart' as globals;
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:soundpool/soundpool.dart';
import 'package:http/http.dart' as http;
import '../Globals.dart';

class TapTapInnerView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return TapTapInnerViewState();
  }
}

class TapTapInnerViewState extends State<TapTapInnerView>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  Animation<double> _contentAnimation;
  Animation<double> textAnimation;

  AnimationController _controller;
  ValueNotifier<int> playersCountNotifier = new ValueNotifier<int>(0);
  double contHeight;
  double screenHeight;
  Color tapColor;
  Color selectedColor;
  final random = Random();
  Stopwatch watch = new Stopwatch();
  Timer timer1;
  Timer timer2;

  List<Color> colors = new List();
  bool capPop;
  double barHeight;
  List<Duration> durations = new List();
  List<int> tapCount = new List();
  int targetTapCount;
  int currentTapCount;
  String hours, minutes, seconds, milliseconds;
  Stopwatch gameWatch = new Stopwatch();
  Timer gameTimer;
  Timer gameTimer2;
  Duration durationd;
  Duration duration2;
  Soundpool pool;
  int soundId1;
  int soundId2;

  String gameID;
  int totalTapCount;
  double percIncrement;
  int currentFillTapCount;
  bool decrease;
  List<int> colorTapCount = new List();
  List<int> colorTapCountCurrent = new List();
  int blueCount;
  int greenCount;
  int redCount;
  int purpleCount;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    decrease = false;
    capPop = false;
    contHeight = 0;

    selectedColor = Colors.transparent;
    hours = globals.hours;
    minutes = globals.min;
    seconds = globals.sec;
    milliseconds = '00';
    totalTapCount = 50;
    currentFillTapCount = 0;

    blueCount = 0;
    greenCount = 0;
    redCount = 0;
    purpleCount = 0;

    colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.purple,
    ];
    tapCount = [2, 4, 6, 8];
    colorTapCount = [2, 4, 6, 2];
    colorTapCountCurrent = [blueCount, redCount, greenCount, purpleCount];

    tapColor = colors[0];

    targetTapCount = 2;
    currentTapCount = 0;
    pool = Soundpool(streamType: StreamType.notification);

    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _controller.forward();
    _contentAnimation = Tween(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    calculatePercentInc();
    watch.start();
    startStopWatch();

    startTimer1();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
    watch.stop();
    gameWatch.stop();
    if (timer1 != null) timer1.cancel();
    if (timer2 != null) timer2.cancel();
    if (gameTimer != null) gameTimer.cancel();
    if (gameTimer2 != null) gameTimer2.cancel();
  }

  Future calculatePercentInc() async {
    double per = 100 / totalTapCount;
    percIncrement = per / 100;
  }

  Future startTimer1() async {
    /////////////////////////////////////////////////////////////////////TIMER FOR HOURS, MINUTES AND SECONDS
    timer2 = new Timer.periodic(Duration(seconds: 3), forwardTimeCallback);
  }

  Future forwardTimeCallback(Timer timer) async {
    if (watch.isRunning) {
      int boxPos = random.nextInt(5);

      int tapCnt = random.nextInt(5);
      if (tapCnt == 4)
        targetTapCount = tapCount[0];
      else
        targetTapCount = tapCount[tapCnt];
      currentTapCount = 0;
      //print('TARGET TAP COUNT: $targetTapCount');
      setState(() {
        if (boxPos == 4)
          tapColor = colors[0];
        else
          tapColor = colors[boxPos];
      });
    }
  }

  Future startStopWatch() async {
    soundId1 =
        await rootBundle.load("assets/add.mp3").then((ByteData soundData) {
      return pool.load(soundData);
    });
    soundId2 =
        await rootBundle.load("assets/pop.mp3").then((ByteData soundData) {
      return pool.load(soundData);
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var target = prefs.getString('targetTime');
    gameID = prefs.getString('gameID');

    DateTime targetdateTime = globals.dateFormat.parse(target);

    await GlobalsMethods.getCurrentTime().then((value) async {
      String currentDate = globals.dateFormat.format(globals.currentTimeZone);
      DateTime datetimeFormatted = DateTime.parse(currentDate);
      durationd = targetdateTime.difference(datetimeFormatted);
      duration2 = targetdateTime.difference(datetimeFormatted);
      durationd = -durationd;
      duration2 = -duration2;
      print('DURATIONS');
      print(duration2);
      print(durationd);
      await startTimer();
    });
  }

  Future startTimer() async {
    gameWatch.start();
    /////////////////////////////////////////////////////////////////////TIMER FOR HOURS, MINUTES AND SECONDS
    gameTimer = new Timer.periodic(new Duration(seconds: 1), forwardTime);
    ///////////////////////////////////////////////////////////TIMER FOR MILLISECONDS
    gameTimer2 =
        new Timer.periodic(new Duration(milliseconds: 10), forwardTimeMilisec);
  }

  Future forwardTime(Timer timer) async {
    if (gameWatch.isRunning) {
      durationd = durationd + Duration(seconds: 1);
      setState(() {
        hours = durationd.inHours.toString().padLeft(2, '0');
        minutes = durationd.inMinutes.remainder(60).toString().padLeft(2, '0');
        seconds =
            (durationd.inSeconds.remainder(60)).toString().padLeft(2, '0');
      });
    }
  }

  Future forwardTimeMilisec(Timer timer) async {
    if (gameWatch.isRunning) {
      if (timer.isActive) {
        duration2 = duration2 + Duration(milliseconds: 10);
        //print('FORWARD TIMER: $durationd');

        // finishDateTime = duration2.inMilliseconds;

        setState(() {
          if (duration2.inMilliseconds.remainder(1000).toString().length >= 2)
            milliseconds = (duration2.inMilliseconds.remainder(1000))
                .toString()
                .substring(0, 2);
          else if (duration2.inMilliseconds.remainder(1000).toString().length <
              2)
            milliseconds = (duration2.inMilliseconds.remainder(1000))
                .toString()
                .padLeft(2, '0');
        });
        /*finishTime = '$hours:'
            '$minutes:'
            '$seconds:'
            '$milliseconds';*/
      }
    }
  }

  Future pauseTimer() async {
    watch.stop();
    gameWatch.stop();
  }

  Future resumeTimer() async {
    watch.start();
    gameWatch.start();
  }

  Widget timerWidget() {
    return Container(
      alignment: Alignment.center,
      //  color: Colors.blue[100],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            //color: Colors.blue[200],
            alignment: Alignment.center,
            child: Icon(
              PuzzleIcons.alarm_clock,
              color: Theme.of(context).accentColor,
              size: MediaQuery.of(context).size.height * 0.02,
            ),
          ),
          Container(
            // color: Colors.blue[300],
            alignment: Alignment.centerLeft,
            // width: 150,
            margin: EdgeInsets.only(left: 5),
            child: Row(
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  //  color: Colors.blue[100],
                  width: 25,
                  child: Text(
                    hours,
                    style: TextStyle(
                      color: Theme.of(context).accentColor,
                      fontSize: 18,
                      //fontWeight: FontWeight.w500,
                      fontFamily: 'Pacifico',
                    ),
                  ),
                ),
                Text(
                  ':',
                  style: TextStyle(
                    color: Theme.of(context).accentColor,
                    fontSize: 18,
                    //fontWeight: FontWeight.w600,
                    fontFamily: 'Pacifico',
                  ),
                ),
                Container(
                  //  color: Colors.blue[200],
                  alignment: Alignment.center,
                  width: 25,
                  child: Text(
                    minutes,
                    style: TextStyle(
                      color: Theme.of(context).accentColor,
                      fontSize: 18,
                      // fontWeight: FontWeight.bold,
                      fontFamily: 'Pacifico',
                    ),
                  ),
                ),
                Text(
                  ':',
                  style: TextStyle(
                    color: Theme.of(context).accentColor,
                    fontSize: 18,
                    //fontWeight: FontWeight.bold,
                    fontFamily: 'Pacifico',
                  ),
                ),
                Container(
                  //  color: Colors.blue[300],
                  alignment: Alignment.center,
                  width: 25,
                  child: Text(
                    seconds,
                    style: TextStyle(
                      color: Theme.of(context).accentColor,
                      fontSize: 18,
                      //  fontWeight: FontWeight.bold,
                      fontFamily: 'Pacifico',
                    ),
                  ),
                ),
                Text(
                  ':',
                  style: TextStyle(
                    color: Theme.of(context).accentColor,
                    fontSize: 18,
                    // fontWeight: FontWeight.bold,
                    fontFamily: 'Pacifico',
                  ),
                ),
                Container(
                  //   color: Colors.blue[400],
                  alignment: Alignment.center,
                  width: 25,
                  child: Text(
                    milliseconds,
                    style: TextStyle(
                      color: Theme.of(context).accentColor,
                      fontSize: 18,
                      //  fontWeight: FontWeight.bold,
                      fontFamily: 'Pacifico',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /* Future checkTap(index) async {
    if (tapColor == colors[index]) {
      await pool.play(soundId1);

      currentTapCount++;
      if (currentTapCount == targetTapCount) {
        await pool.play(soundId2);
        setState(() {
          decrease = false;
          contHeight = contHeight + (barHeight * percIncrement);
          currentFillTapCount++;
          int boxPos = random.nextInt(4);
          print('COLOR POS: $boxPos');
          setState(() {
            if (boxPos == 3)
              tapColor = colors[0];
            else
              tapColor = colors[boxPos];
          });
        });
        currentTapCount = 0;

        if (currentFillTapCount == totalTapCount)
          giffyDialog(
            allTranslations.text('you_win'),
          );
      }
    } else {
      setState(() {
        decrease = true;

        contHeight = contHeight - (barHeight * percIncrement);
      });
    }
  }*/

  Future checkTap(index) async {
    if (tapColor == colors[index]) {
      setState(() {
        currentFillTapCount++;

        decrease = false;
        contHeight = contHeight + (barHeight * percIncrement);
      });

      print('TOTAL BAR HEIGHT: $barHeight');
      print('CURRENT BAR HEIGHT: $contHeight');
      await pool.play(soundId1);
      await pool.play(soundId2);

      if (contHeight.truncate() == barHeight.truncate())
        giffyDialog(
          allTranslations.text('you_win'),
        );

      if (tapColor == Colors.blue) {
        setState(() {
          blueCount++;
          colorTapCountCurrent[0] = blueCount;
          // print('BLUE COUNT IN LIST: ${colorTapCountCurrent[0]}');
          if (colorTapCount[0] == colorTapCountCurrent[0]) {
            blueCount = 0;
            ///////////////////////////////SET RANDOM TAP COUNT
            int tapCnt = random.nextInt(5);
            if (tapCnt == 4)
              targetTapCount = tapCount[0];
            else
              targetTapCount = tapCount[tapCnt];
            colorTapCount[0] = targetTapCount;
            /////////////////////////////SET RANDOM TAP COLOR
            // print('BLUE COUNT COMPLETE:');
            int boxPos = random.nextInt(4);
            if (boxPos == 3)
              tapColor = colors[0];
            else
              tapColor = colors[boxPos];
          }
        });
      } else if (tapColor == Colors.red) {
        setState(() {
          redCount++;
          colorTapCountCurrent[1] = redCount;
          //print('RED COUNT IN LIST: ${colorTapCountCurrent[1]}');
          if (colorTapCount[1] == colorTapCountCurrent[1]) {
            redCount = 0;
            ///////////////////////////////SET RANDOM TAP COUNT
            int tapCnt = random.nextInt(5);
            if (tapCnt == 4)
              targetTapCount = tapCount[0];
            else
              targetTapCount = tapCount[tapCnt];
            colorTapCount[1] = targetTapCount;
            /////////////////////////////SET RANDOM TAP COLOR
            //print('RED COUNT COMPLETE:');

            int boxPos = random.nextInt(4);
            if (boxPos == 3)
              tapColor = colors[0];
            else
              tapColor = colors[boxPos];
          }
        });
      } else if (tapColor == Colors.green) {
        setState(() {
          greenCount++;
          colorTapCountCurrent[2] = greenCount;
          // print('GREEN COUNT IN LIST: ${colorTapCountCurrent[2]}');
          if (colorTapCount[2] == colorTapCountCurrent[2]) {
            greenCount = 0;
            ///////////////////////////////SET RANDOM TAP COUNT
            int tapCnt = random.nextInt(5);
            if (tapCnt == 4)
              targetTapCount = tapCount[0];
            else
              targetTapCount = tapCount[tapCnt];
            colorTapCount[2] = targetTapCount;
            /////////////////////////////SET RANDOM TAP COLOR
            //print('GREEN COUNT COMPLETE:');

            int boxPos = random.nextInt(4);
            if (boxPos == 3)
              tapColor = colors[0];
            else
              tapColor = colors[boxPos];
          }
        });
      } else {
        setState(() {
          purpleCount++;
          colorTapCountCurrent[3] = greenCount;
          // print('GREEN COUNT IN LIST: ${colorTapCountCurrent[2]}');
          if (colorTapCount[3] == colorTapCountCurrent[3]) {
            purpleCount = 0;
            ///////////////////////////////SET RANDOM TAP COUNT
            int tapCnt = random.nextInt(5);
            if (tapCnt == 4)
              targetTapCount = tapCount[0];
            else
              targetTapCount = tapCount[tapCnt];
            colorTapCount[3] = targetTapCount;
            /////////////////////////////SET RANDOM TAP COLOR
            //print('GREEN COUNT COMPLETE:');

            int boxPos = random.nextInt(4);
            if (boxPos == 3)
              tapColor = colors[0];
            else
              tapColor = colors[boxPos];
          }
        });
      }
    } else {
      setState(() {
        decrease = true;
        contHeight = contHeight - (barHeight * percIncrement);
      });
    }
  }

  List<Widget> buttons() {
    List<Widget> buttons = new List();
    for (int i = 0; i < 4; i++) {
      buttons.add(
        Container(
          padding: EdgeInsets.all(5),
          height: 70,
          width: 70,
          child: MaterialButton(
            elevation: 6,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            onPressed: () {
              checkTap(i);
            },
            color: colors[i],
            child: Text(
              'TAP',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      );
    }
    return buttons;
  }

  Future gameEndDialog(message) async {
    print('GAME END DIALOG CALLED');

    watch.stop();
    gameWatch.stop();
    if (timer1 != null) timer1.cancel();
    if (timer2 != null) timer2.cancel();
    if (gameTimer != null) gameTimer.cancel();
    if (gameTimer2 != null) gameTimer2.cancel();

    globals.gameCompleted = true;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('targetTime', '');
    prefs.setBool('timerStarted', false);
    prefs.setString('puzzleID', '');
    prefs.setString('gamePlayed', 'yes');

    return showGeneralDialog(
      barrierColor: Colors.black.withOpacity(0.5),
      transitionBuilder: (context, a1, a2, widget) {
        return WillPopScope(
          child: Transform.scale(
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
                              top: MediaQuery.of(context).size.height * 0.10,
                              left: 30,
                              right: 30,
                              bottom: 20,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              // crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  //color: Colors.blue[100],
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.only(top: 0),
                                  child: Text(
                                    allTranslations.text('you_loose'),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Theme.of(context).accentColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  //color: Colors.blue[100],
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.only(top: 15),

                                  child: AutoDirection(
                                    text: message,
                                    child: Text(
                                      message,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 13,
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 20),
                                  child: MaterialButton(
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    color: Theme.of(context).primaryColor,
                                    minWidth:
                                        MediaQuery.of(context).size.width *
                                            0.50,
                                    onPressed: () async {
                                      //sub.cancel();
                                      watch.stop();
                                      gameWatch.stop();
                                      if (timer1 != null) timer1.cancel();
                                      if (timer2 != null) timer2.cancel();
                                      if (gameTimer != null) gameTimer.cancel();
                                      if (gameTimer2 != null)
                                        gameTimer2.cancel();
                                      globals.HOMEONFRONT = true;
                                      globals.onceInserted = false;

                                      if (Navigator.of(context).canPop()) {
                                        Navigator.pop(context);

                                        Navigator.popAndPushNamed(
                                            context, '/dashboard');
                                      } else {
                                        Navigator.pop(context);

                                        Navigator.of(context)
                                            .pushNamedAndRemoveUntil(
                                                '/dashboard',
                                                (Route<dynamic> route) =>
                                                    false);
                                      }
                                    },
                                    child: Padding(
                                      padding:
                                          EdgeInsets.only(left: 20, right: 20),
                                      child: Text(
                                        allTranslations.text('exit'),
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600),
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
          ),
          onWillPop: () {},
        );
      },
      transitionDuration: Duration(milliseconds: 150),
      barrierDismissible: false,
      barrierLabel: '',
      context: context,
      pageBuilder: (context, animation1, animation2) {},
    );
  }

  Future closeDialog() {
    pauseTimer();
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
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Container(
                      padding: EdgeInsets.only(top: 35),
                      child: Material(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                        child: Container(
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.10,
                            left: 40,
                            right: 40,
                            bottom: 30,
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
                                        allTranslations.text('exit_game'),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.grey[800],
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      // color: Colors.blue[200],
                                      alignment: Alignment.center,
                                      margin: EdgeInsets.only(top: 20),
                                      child: Text(
                                        allTranslations.text('exit_desc'),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      //margin: EdgeInsets.only(top: 20),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Container(
                                            margin: EdgeInsets.only(top: 50),
                                            child: Container(
                                              constraints: BoxConstraints(
                                                maxHeight:
                                                    MediaQuery.of(context)
                                                            .size
                                                            .height *
                                                        0.06,
                                              ),
                                              child: MaterialButton(
                                                elevation: 3,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30)),
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                minWidth: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.65,
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  resumeTimer();
                                                },
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                    left: 25,
                                                    right: 25,
                                                  ),
                                                  child: Text(
                                                    allTranslations
                                                        .text('keep_play'),
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(top: 10),
                                            child: Container(
                                              constraints: BoxConstraints(
                                                maxHeight:
                                                    MediaQuery.of(context)
                                                            .size
                                                            .height *
                                                        0.06,
                                              ),
                                              child: MaterialButton(
                                                elevation: 3,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30)),
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                minWidth: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.65,
                                                onPressed: () {
                                                  //globals.launchApp = false;
                                                  globals.HOMEONFRONT = true;
                                                  globals.onceInserted = false;

                                                  if (capPop) {
                                                    print('CAN POP');
                                                    Navigator.pop(context);
                                                    Navigator.popAndPushNamed(
                                                        context, '/dashboard');
                                                  } else {
                                                    print('CANNOT POP');
                                                    Navigator.pop(context);

                                                    Navigator.of(context)
                                                        .pushReplacementNamed(
                                                            '/dashboard');
                                                  }
                                                },
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                    left: 25,
                                                    right: 25,
                                                  ),
                                                  child: Text(
                                                    allTranslations
                                                        .text('exit'),
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
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
      },
      transitionDuration: Duration(milliseconds: 150),
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      pageBuilder: (context, animation1, animation2) {},
    );
  }

  Future giffyDialog(String message) async {
    watch.stop();
    gameWatch.stop();
    if (timer1 != null) timer1.cancel();
    if (timer2 != null) timer2.cancel();
    if (gameTimer != null) gameTimer.cancel();
    if (gameTimer2 != null) gameTimer2.cancel();

    ////////////////////////////LOCK VALUE IS FALSE
    await FirebaseDatabase.instance
        .reference()
        .child('game-' + gameID)
        .update({'lock': true, 'status': "Complete"});
    await FirebaseDatabase.instance
        .reference()
        .child('next-game')
        .update({'status': 'Complete'});

    globals.gameCompleted = true;

    print('GIFFY DIALOG CALLED');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    ///////////////////////////////////RESET PREFERENCES
    prefs.setString('targetTime', '');
    prefs.setBool('timerStarted', false);
    prefs.setString('puzzleID', '');
    // prefs.setString('gameID', '');
    prefs.setString('gamePlayed', 'yes');

    return showGeneralDialog(
      barrierColor: Colors.black.withOpacity(0.5),
      transitionBuilder: (context, a1, a2, widget) {
        return WillPopScope(
          child: Transform.scale(
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
                              top: MediaQuery.of(context).size.height * 0.10,
                              left: 30,
                              right: 30,
                              bottom: 20,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              // crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  //color: Colors.blue[100],
                                  alignment: Alignment.center,
                                  child: Text(
                                    allTranslations.text('good_job'),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Theme.of(context).accentColor,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 15),
                                  alignment: Alignment.center,
                                  child: AutoDirection(
                                    text: allTranslations.text('you_win'),
                                    child: Text(
                                      allTranslations.text('you_win'),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FontStyle.italic,
                                        fontSize: 13,
                                        fontFamily: 'Futura',
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 20),
                                  child: MaterialButton(
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    color: Theme.of(context).primaryColor,
                                    minWidth:
                                        MediaQuery.of(context).size.width *
                                            0.50,
                                    onPressed: () {
                                      watch.stop();
                                      if (timer1 != null) timer1.cancel();
                                      if (timer2 != null) timer2.cancel();

                                      globals.HOMEONFRONT = true;
                                      globals.onceInserted = false;

                                      if (Navigator.of(context).canPop()) {
                                        Navigator.pop(context);

                                        Navigator.popAndPushNamed(
                                            context, '/dashboard');
                                      } else {
                                        Navigator.pop(context);

                                        Navigator.of(context)
                                            .pushNamedAndRemoveUntil(
                                                '/dashboard',
                                                (Route<dynamic> route) =>
                                                    false);
                                      }
                                    },
                                    child: Padding(
                                      padding:
                                          EdgeInsets.only(left: 20, right: 20),
                                      child: Text(
                                        allTranslations.text('exit'),
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ),
                                )
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
          ),
          onWillPop: () {},
        );
      },
      transitionDuration: Duration(milliseconds: 150),
      barrierDismissible: false,
      barrierLabel: '',
      context: context,
      pageBuilder: (context, animation1, animation2) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    barHeight = MediaQuery.of(context).size.height * 0.57;

    return WillPopScope(
      child: Scaffold(
        body: SafeArea(
          top: false,
          child: Container(
            color: Colors.black,
            child: FadeTransition(
              opacity: _contentAnimation,
              child: ModalProgressHUD(
                child: Container(
                  height: double.infinity,
                  width: double.infinity,
                  padding:
                      EdgeInsets.only(top: 40, bottom: 5, left: 0, right: 0),
                  child: Column(
                    children: <Widget>[
                      Container(
                        //height: MediaQuery.of(context).size.height * 0.08,
                        padding: EdgeInsets.only(left: 8, right: 8),
                        child: Row(
                          // mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                //margin: EdgeInsets.only(left: 8),
                                padding: EdgeInsets.only(top: 5, right: 15),
                                alignment: Alignment.bottomCenter,
                                child: Text(
                                  'Rs. 500',
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Theme.of(context).accentColor,
                                    fontWeight: FontWeight.w700,
                                    //fontStyle: FontStyle.italic,
                                    fontSize: 11,
                                    fontFamily: 'Noteworthy',
                                  ),
                                ),
                              ),
                            ),
                            timerWidget(),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.only(left: 15, top: 5),
                                // color: Colors.blue[200],
                                alignment: Alignment.bottomCenter,
                                child: SizedBox(
                                  child: Text(
                                    'USERNAME',
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Theme.of(context).accentColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(top: 10),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                alignment: Alignment.center,
                                child: Text(
                                  'TAP THE BELOW COLOR',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 10),
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  height: 40,
                                  width:
                                      MediaQuery.of(context).size.width * 0.40,
                                  //duration: Duration(milliseconds: 700),
                                  curve: Curves.linear,
                                  color: tapColor,
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(top: 5),
                                  alignment: Alignment.bottomCenter,
                                  child: Stack(
                                    children: <Widget>[
                                      Container(
                                        color: Colors.white,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.57,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.40,
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        child: Container(
                                          // color: Colors.white,

                                          child: AnimatedContainer(
                                            duration:
                                                Duration(milliseconds: 400),
                                            curve: decrease
                                                ? Curves.linear
                                                : Curves.elasticOut,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.40,
                                            constraints:
                                                BoxConstraints(minHeight: 10),
                                            height: contHeight,
                                            color:
                                                Theme.of(context).accentColor,
                                            child: Container(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                //color: Colors.blue[100],
                                alignment: Alignment.bottomCenter,
                                margin: EdgeInsets.only(top: 10),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: buttons(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                inAsyncCall: false,
              ),
            ),
          ),
        ),
      ),
      onWillPop: Navigator.of(context).canPop()
          ? () {
              setState(() {
                capPop = true;
              });
              return closeDialog();
              //return Navigator.popAndPushNamed(context, '/dashboard');
            }
          : () {
              setState(() {
                capPop = false;
              });
              return closeDialog();
              //return Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (Route<dynamic> route) => false);
            },
    );
  }
}
