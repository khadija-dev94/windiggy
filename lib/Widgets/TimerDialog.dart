import 'dart:async';
import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:win_diggy/Models/GlobalMethods.dart';
import 'package:win_diggy/Models/GlobalTranslations.dart';
import 'package:win_diggy/Screen/DailyGames/BalloonsGame.dart';
import 'package:win_diggy/Screen/DailyGames/FlipGameScreen.dart';
import 'package:win_diggy/Screen/DailyGames/JigsawPuzzleGame.dart';
import 'package:win_diggy/Screen/DailyGames/PickOddGameScreen.dart';
import 'package:win_diggy/Screen/DailyGames/ScratchCardGame.dart';
import 'package:win_diggy/Screen/DailyGames/ShadowGame.dart';
import 'package:win_diggy/Screen/DailyGames/TapTapScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:win_diggy/CustomIcons/puzzle_icons_icons.dart';
import 'package:win_diggy/Screen/DailyGames/ImageDiffScreen.dart';
import 'package:win_diggy/Screen/DailyGames/QuizScreen.dart';
import 'package:win_diggy/Screen/DailyGames/TissueBoxGame.dart';
import 'package:win_diggy/Screen/DailyGames/WSGamePlayScreen.dart';
import 'package:win_diggy/Globals.dart' as globals;
import 'package:win_diggy/Widgets/CountDownTimer.dart';

import '../main.dart';

class CustomDialog extends StatefulWidget {
  Map<String, dynamic> timer;

  CustomDialog({this.timer});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return DialogState();
  }
}

class DialogState extends State<CustomDialog>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  bool timerFinished;
  int duration;
  Duration timerDuration;
  int hrs, min, sec;
  int timerforTimer;
  String title;
  String hours, minutes, seconds, milliseconds;
  AnimationController animationController;
  Animation animation;
  String btnText;
  bool calledOnce;
  Stopwatch watch = new Stopwatch();
  Timer timer1;
  bool statesSet;

  @override
  void dispose() {
    if (animationController != null) animationController.dispose();
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
    watch.stop();
    if (timer1 != null) timer1.cancel();
  }

  @override
  void onDeactivate() {
    super.deactivate();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    hours = '00';
    minutes = '00';
    seconds = '00';
    title = '';
    btnText = allTranslations.text('play');

    hrs = 0;
    min = 0;
    sec = 0;
    timerforTimer = 0;
    timerFinished = false;
    calledOnce = false;
    statesSet = false;
    WidgetsBinding.instance.addObserver(this);

    getNTPTime();
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    animation = ColorTween(
      begin: Color(0xffeccb58),
      end: Color(0xffAB9341),
    ).animate(animationController);

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed)
        animationController.reverse();
      else if (status == AnimationStatus.dismissed)
        animationController.forward();
    });
  }

  Future getNTPTime() async {
    print('TIMER CALLED');
    await Future.wait([getInitialTime()]);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      print('TIMER WIDGET RESUMED');
      ////////////////////////////////////////////////////////RESUME WIDGET ONLY IF DASHBOARD IS ON FOREGROUND
      watch.stop();
      if (timer1 != null) timer1.cancel();
      Future.wait([getInitialTime()]);
    }
  }

  Future getInitialTime() async {
    _cancelAllNotifications();

    await Future.wait([GlobalsMethods.getCurrentTime()]).then((value) async {
      DateTime targetdateTime =
          globals.dateFormat.parse(widget.timer['target']);
      String currentDate = globals.dateFormat.format(globals.currentTimeZone);
      DateTime datetimeFormatted = DateTime.parse(currentDate);

      duration = targetdateTime.difference(datetimeFormatted).inSeconds;
      timerDuration = targetdateTime.difference(datetimeFormatted);
      setState(() {
        title = allTranslations.text('time_left');
      });

      await calculation();
    }).catchError((error) async {
      print('SOMETHING WENT WRON in getInitialTime');
      //await getInitialTime();
      Crashlytics.instance
          .log('TIMER EXCEPTION IN getInitialTime METHOD: $error');
    });
  }

  Future calculation() async {
    if (!duration.isNegative) {
      globals.dialogOnScreen = true;
      globals.dismissable = false;

      ////////////////////////////////////////////////////START REVERSE TIMER
      if (watch.isRunning) {
        watch.stop();
        if (timer1 != null) timer1.cancel();
      }
      watch.start();
      timer1 =
          new Timer.periodic(new Duration(seconds: 1), reverseTimerCallback);
    } else {
      timerDuration = -timerDuration;

      startForwardTimer();
    }
  }

  Future reverseTimerCallback(Timer t) {
    if (watch.isRunning) {
      if (timer1.isActive) {
        timerDuration = timerDuration - Duration(seconds: 1);

        if (!timerDuration.isNegative) {
          setState(() {
            hours = timerDuration.inHours.toString().padLeft(2, '0');
            minutes = timerDuration.inMinutes
                .remainder(60)
                .toString()
                .padLeft(2, '0');
            seconds = (timerDuration.inSeconds.remainder(60))
                .toString()
                .padLeft(2, '0');
          });
        } else {
          watch.stop();
          if (timer1 != null) timer1.cancel();

          timerDuration = Duration(seconds: 0);
          timerDuration = -timerDuration;
          startForwardTimer();
        }
      }
    }
  }

  Future forwardTimeCallback(Timer timer) {
    if (watch.isRunning) {
      if (timer1.isActive) {
        timerDuration = timerDuration + Duration(seconds: 1);

        setState(() {
          hours = timerDuration.inHours.toString().padLeft(2, '0');
          minutes =
              timerDuration.inMinutes.remainder(60).toString().padLeft(2, '0');
          seconds = (timerDuration.inSeconds.remainder(60))
              .toString()
              .padLeft(2, '0');
          if (timerDuration.inMilliseconds.remainder(1000).toString().length >=
              2)
            milliseconds = (timerDuration.inMilliseconds.remainder(1000))
                .toString()
                .substring(0, 2);
          else if (timerDuration.inMilliseconds
                  .remainder(1000)
                  .toString()
                  .length <
              2)
            milliseconds = (timerDuration.inMilliseconds.remainder(1000))
                .toString()
                .padLeft(2, '0');
        });
        globals.hours = hours;
        globals.min = minutes;
        globals.sec = seconds;
        globals.userEnterTime = timerDuration.inMilliseconds;
        if (!statesSet) setWidgetStates();
      }
    }
  }

  Future setWidgetStates() {
    setState(() {
      btnText = allTranslations.text('play_NOW');
    });
    setState(() {
      title = allTranslations.text('game_timer');
    });
    if (!timerFinished) {
      setState(() {
        timerFinished = true;
      });
    }
    globals.dismissable = true;

    animationController.forward();
    statesSet = true;
  }

  Future reverserTimer() {
    if (watch.isRunning) {
      watch.stop();
      if (timer1 != null) timer1.cancel();
    }
    watch.start();
    timer1 = new Timer.periodic(new Duration(seconds: 1), reverseTimerCallback);
  }

  Future startForwardTimer() async {
    if (watch.isRunning) {
      watch.stop();
      if (timer1 != null) timer1.cancel();
    }
    watch.start();
    timer1 = new Timer.periodic(new Duration(seconds: 1), forwardTimeCallback);
  }

  Widget timerWidget() {
    return Container(
      //  color: Colors.blue[100],
      alignment: Alignment.center,
      margin: EdgeInsets.only(top: 0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            // color: Colors.blue[200],
            padding: EdgeInsets.only(top: 10),
            alignment: Alignment.center,
            child: Icon(
              PuzzleIcons.alarm_clock,
              color: Theme.of(context).primaryColor,
              size: MediaQuery.of(context).size.height * 0.045,
            ),
          ),
          Container(
            // color: Colors.blue[300],
            alignment: Alignment.center,
            // width: 150,
            margin: EdgeInsets.only(left: 10),
            child: Row(
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  //  color: Colors.blue[100],
                  width: 53,
                  child: Text(
                    hours.toString(),
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Pacifico',
                    ),
                  ),
                ),
                Text(
                  ':',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Pacifico',
                  ),
                ),
                Container(
                  //  color: Colors.blue[200],
                  alignment: Alignment.center,
                  width: 53,
                  child: Text(
                    minutes.toString(),
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Pacifico',
                    ),
                  ),
                ),
                Text(
                  ':',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Pacifico',
                  ),
                ),
                Container(
                  //  color: Colors.blue[300],
                  alignment: Alignment.center,
                  width: 53,
                  child: Text(
                    seconds.toString(),
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
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

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, child) => Container(
        padding: EdgeInsets.only(bottom: 10),
        child: Column(
          //crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              //color: Colors.blue[100],
              alignment: Alignment.center,
              margin: EdgeInsets.only(top: 0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Source Sans',
                ),
              ),
            ),
            timerWidget(),
            Container(
              margin: EdgeInsets.only(top: 10),
              alignment: Alignment.topCenter,
              child: Column(
                // mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(top: 5),
                    child: Text(
                      allTranslations.text('play_win'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Futura',
                      ),
                    ),
                  ),
                  Container(
                    // color: Colors.blue[200],
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(top: 8),
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        widget.timer['prize'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontWeight: FontWeight.w700,
                          //fontStyle: FontStyle.italic,
                          fontSize: 15,
                          fontFamily: 'Noteworthy',
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 15),
                    alignment: Alignment.center,
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.06,
                      ),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.06,
                        child: RaisedButton(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          color: animation.value,
                          onPressed: timerFinished
                              ? () async {
                                  watch.stop();
                                  if (timer1 != null) timer1.cancel();

                                  if (globals.updateListener != null)
                                    globals.updateListener.cancel();

                                  Navigator.of(context).pop();
                                  globals.HOMEONFRONT = false;
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  globals.timerDialogShowed = false;

                                  if (prefs.getString('game_type') == 'mcq') {
                                    globals.currentGame = 'mcq';
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => QuizScreen()),
                                    );
                                  } else if (prefs.getString('game_type') ==
                                      'puzzle') {
                                    globals.currentGame = 'puzzle';

                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              WSGamePlayPage()),
                                    );
                                  } else if (prefs.getString('game_type') ==
                                      'find_difference') {
                                    globals.currentGame = 'ftd';

                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ImageDiffScreen()),
                                    );
                                  } else if (prefs.getString('game_type') ==
                                      'Odd_one') {
                                    globals.currentGame = 'oddone';

                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              PickOddGameScreen()),
                                    );
                                  } else if (prefs.getString('game_type') ==
                                      'flip') {
                                    globals.currentGame = 'flip';

                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              FlipGameScreen()),
                                    );
                                  } else if (prefs.getString('game_type') ==
                                      'tab') {
                                    globals.currentGame = 'tab';

                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => TapTapScreen()),
                                    );
                                  } else if (prefs.getString('game_type') ==
                                      'jigsaw') {
                                    globals.currentGame = 'jigsaw';

                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              JigsawPuzzleScreen()),
                                    );
                                  } else if (prefs.getString('game_type') ==
                                      'shadow') {
                                    globals.currentGame = 'shadow';

                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ShadowScreen()),
                                    );
                                  } else if (prefs.getString('game_type') ==
                                      'tissue') {
                                    globals.currentGame = 'tissue';

                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              TissueBoxScreen()),
                                    );
                                  } else if (prefs.getString('game_type') ==
                                      'balloon') {
                                    globals.currentGame = 'balloon';

                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              BalloonsGameScreen()),
                                    );
                                  } else if (prefs.getString('game_type') ==
                                      'scratch') {
                                    globals.currentGame = 'scratch';

                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ScratchCardScreen()),
                                    );
                                  }
                                }
                              : null,
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: 25,
                              right: 25,
                            ),
                            child: Text(
                              btnText,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getBannerAdUnitId() {
    if (Platform.isIOS) {
      return 'ca-app-pub-4670716099674884/4870355945';
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-4670716099674884/4291771441';
    }
    return null;
  }

  //////////////////////////////////////////////////////////CANCEL ALL PREVIOUS NOTIFICATION IF NEW GAME ADDED
  Future<void> _cancelAllNotifications() async {
    await globals.flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Schedules a notification that specifies a different icon, sound and vibration pattern
  Future<void> _scheduleNotification(String title, String body,
      DateTime targetTime, int min, int sec, String gameStarted, int i) async {
    var scheduledNotificationDateTime;
    /////////////////////////////////////////CHANNEL DETAILS
    var groupChannelId = 'C_ID_1';
    var groupChannelName = 'GAMES TO START';
    var groupChannelDescription =
        'Contains all scheduled notification for newly added game';

    scheduledNotificationDateTime = targetTime.subtract(Duration(seconds: sec));
    print('SCHEDULED TIME');
    print(scheduledNotificationDateTime);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      groupChannelId,
      groupChannelName,
      groupChannelDescription,
      icon: 'ic_app_icon',
      enableLights: true,
      color: Color(0xff5c4710),
      ledColor: Colors.blue,
      ledOnMs: 1000,
      ledOffMs: 500,
      importance: Importance.Max,
      priority: Priority.High,
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await globals.flutterLocalNotificationsPlugin.schedule(
      i,
      title,
      body,
      scheduledNotificationDateTime,
      platformChannelSpecifics,
      payload: 'NOT STARTED',
    );
  }

  Future<void> _showNotification(String title, String body) async {
    /////////////////////////////////////////CHANNEL DETAILS
    var groupChannelId = 'C_ID_1';
    var groupChannelName = 'GAMES TO START';
    var groupChannelDescription =
        'Contains all scheduled notification for newly added game';

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      groupChannelId,
      groupChannelName,
      groupChannelDescription,
      icon: 'ic_app_icon',
      enableLights: true,
      color: Color(0xff5c4710),
      ledColor: Colors.blue,
      ledOnMs: 1000,
      ledOffMs: 500,
      importance: Importance.Max,
      priority: Priority.High,
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await globals.flutterLocalNotificationsPlugin
        .show(0, title, body, platformChannelSpecifics, payload: 'NOT STARTED');
  }
}
