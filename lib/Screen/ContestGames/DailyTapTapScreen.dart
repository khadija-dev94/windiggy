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
import 'package:win_diggy/Models/ColorSet.dart';
import 'package:win_diggy/Models/GlobalTranslations.dart';
import 'package:win_diggy/Models/Player.dart';
import 'package:win_diggy/Models/URLS.dart';
import 'package:win_diggy/Widgets/CurrentPlayers.dart';
import 'package:win_diggy/Globals.dart' as globals;
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:soundpool/soundpool.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> fetchCountry(http.Client client) async {
  print('DAILY TAP SERVICE CALLED');

  DataSnapshot data = null;
  data = await FirebaseDatabase.instance
      .reference()
      .child('daily-list')
      .child(globals.dailyContestGameID)
      .once();

  return compute(parseData, data);
}

// A function that will convert a response body into a List<Country>
Map<String, dynamic> parseData(DataSnapshot dbData) {
  print('TAP DATA: $dbData');
  Map<String, dynamic> parsedData;

  parsedData = {
    'colors': dbData.value['game-data']['details']['number_of_colors'],
    'taps': dbData.value['game-data']['details']['number_of_tabs'],
    'prize_eng': dbData.value['prize'],
    'prize_urdu': dbData.value['prize-urdu']
  };
  return parsedData;
}

class DailyTapTapScreen extends StatefulWidget {
  static DailyTapTapScreenState of(BuildContext context) =>
      context.ancestorStateOfType(const TypeMatcher<DailyTapTapScreenState>());
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return DailyTapTapScreenState();
  }
}

class DailyTapTapScreenState extends State<DailyTapTapScreen> {
  ScreenshotController screenshotController = ScreenshotController();
  bool capPop;
  GlobalKey<DailyTapTapInnerViewState> _keyChild1 = GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    capPop = false;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
      child: Scaffold(
        body: SafeArea(
          top: false,
          child: Screenshot(
            controller: screenshotController,
            child: Container(
              color: Colors.black,
              child: new FutureBuilder<Map<String, dynamic>>(
                future: fetchCountry(
                  new http.Client(),
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasError) print(snapshot.error);

                  return snapshot.hasData
                      ? new TapTapInnerView(
                          mapData: snapshot.data,
                          key: _keyChild1,
                        )
                      : new Center(child: new CircularProgressIndicator());
                },
              ),
            ),
          ),
        ),
      ),
      onWillPop: () {
        return closeDialog();
        //return Navigator.popAndPushNamed(context, '/dashboard');
      },
    );
  }

  Future closeDialog() {
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
                                          color: Colors.grey[700],
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      // color: Colors.blue[200],
                                      alignment: Alignment.center,
                                      margin: EdgeInsets.only(top: 10),
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
                                            margin: EdgeInsets.only(top: 20),
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
                                                  Navigator.pop(context);
                                                  Navigator.pop(context);

                                                  Navigator.popAndPushNamed(
                                                      context,
                                                      '/dailyContestScreen');
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

  Future<String> takeScreenShot() async {
    File image = await screenshotController.capture().catchError((error) {
      print('SOMETHING WENT WRON');
      Crashlytics.instance.log(
          'MCQ SCREENSHOT CAPTURE EXCEPTION IN takeScreenShot METHOD: $error');
      Crashlytics.instance.setString('USER ID', globals.userID);
      Crashlytics.instance.setString('USERNAME', globals.username);
    });
    String imgStr = await _upload(image);
    print('SCREENSHOT CAPTURED :$imgStr');
    globals.base64Image = imgStr;
    return imgStr;
  }

  // 4. compress List<int> and get another List<int>.
  Future<List<int>> testComporessList(List<int> list) async {
    var result = await FlutterImageCompress.compressWithList(
      list,
      quality: 30,
    );

    return result;
  }

  Future<String> _upload(File image) async {
    List<int> compress =
        await testComporessList(image.readAsBytesSync()).catchError((error) {
      print('SOMETHING WENT WRON');
      Crashlytics.instance
          .log('MCQ IMAGE COMPRESS EXCEPTION IN takeScreenShot METHOD: $error');
    });
    print('IMAGE COMPRESED');
    String imageStr = base64Encode(compress);
    return imageStr;
  }
}

class TapTapInnerView extends StatefulWidget {
  Map<String, dynamic> mapData;
  GlobalKey key;

  TapTapInnerView({this.mapData, this.key});

  static DailyTapTapInnerViewState of(BuildContext context) => context
      .ancestorStateOfType(const TypeMatcher<DailyTapTapInnerViewState>());

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return DailyTapTapInnerViewState();
  }
}

class DailyTapTapInnerViewState extends State<TapTapInnerView>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  Animation<double> _contentAnimation;
  Animation<double> textAnimation;

  AnimationController _controller;
  double contHeight;
  double screenHeight;
  Color tapColor;
  final random = Random();
  Stopwatch colorWatch = new Stopwatch();
  Timer colorTimer;

  bool capPop;
  double barHeight;
  double barHeight2;

  String hours, minutes, seconds, milliseconds;
  Stopwatch gameWatch = new Stopwatch();
  Timer gameTimer;
  Timer gameTimer2;
  Duration durationd;
  Duration duration2;
  Soundpool pool;
  int soundId1;
  int soundId2;

  int totalTapCount;
  double percIncrement;
  int currentFillTapCount;
  bool decrease;
  int blueCount;
  int greenCount;
  int redCount;
  var finishTime;
  bool calledOneTime;
  bool isLoading;
  bool meWinner;
  String userName;
  int finishDateTime;
  String prizeTxt;
  bool gameLocked;
  bool popupShown;
  bool gameEndAlreadyShown;
  bool gameCompletedCalledOnce;
  int totalColors;
  int targetTapCount;
  List<Color> tapColors = new List();
  List<int> colorCounts = new List();
  List<int> colorTapCountCurrent = new List();
  List<int> tapCount = new List();
  String language = allTranslations.currentLanguage;

  String gameID;
  int count;
  bool barCmplete;
  bool singleColorSet;

  @override
  void initState() {
    super.initState();
    hours = '00';
    minutes = '00';
    seconds = '00';
    milliseconds = '00';
    finishDateTime = 0;
    finishTime = '$hours:'
        '$minutes:'
        '$seconds:'
        '$milliseconds';

    gameID = '';
    WidgetsBinding.instance.addObserver(this);
    totalColors = int.parse(widget.mapData['colors']);
    decrease = false;
    barCmplete = false;
    singleColorSet = false;
    capPop = false;
    contHeight = 0;
    barHeight = 0;
    totalTapCount = int.parse(widget.mapData['taps']);
    currentFillTapCount = 0;
    tapCount = [2, 3, 4, 5, 6];

    pool = Soundpool(streamType: StreamType.notification);
    prizeTxt = '';
    gameLocked = false;
    calledOneTime = false;
    isLoading = false;
    meWinner = false;
    popupShown = false;
    gameCompletedCalledOnce = false;
    gameEndAlreadyShown = false;
    userName = '';

    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _controller.forward();
    _contentAnimation = Tween(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    setcolors();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    if (_controller != null) _controller.dispose();
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();

    colorWatch.stop();
    gameWatch.stop();
    if (colorTimer != null) colorTimer.cancel();
    if (gameTimer != null) gameTimer.cancel();
    if (gameTimer2 != null) gameTimer2.cancel();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      print('QUIZ SCREEN WIDGET RESUMED');
    }
  }

  Future setcolors() async {
    if (totalColors == 5) {
      print(totalColors);
      setState(() {
        tapColors = ColorSet.colorsSet1;
        tapColor = tapColors[0];
        tapColors.shuffle();
        tapColors.shuffle();
        colorCounts = tapCount.getRange(0, totalColors).toList();
      });
      for (int i = 0; i < tapColors.length; i++) {
        colorTapCountCurrent.add(0);
        print('VALUE: ${colorTapCountCurrent[i]}');
      }
    } else if (totalColors == 3) {
      print(totalColors);
      setState(() {
        tapColors = ColorSet.colorsSet2;
        tapColor = tapColors[0];
        tapColors.shuffle();
        tapColors.shuffle();
        colorCounts = tapCount.getRange(0, totalColors).toList();
      });
      for (int i = 0; i < tapColors.length; i++) {
        colorTapCountCurrent.add(0);
        print('VALUE: ${colorTapCountCurrent[i]}');
      }
    } else if (totalColors == 4) {
      print(totalColors);
      setState(() {
        tapColors = ColorSet.colorsSet3;

        tapColor = tapColors[0];
        tapColors.shuffle();
        tapColors.shuffle();
        colorCounts = tapCount.getRange(0, totalColors).toList();
      });
      for (int i = 0; i < tapColors.length; i++) {
        colorTapCountCurrent.add(0);
        print('VALUE: ${colorTapCountCurrent[i]}');
      }
    } else if (totalColors == 2) {
      print(totalColors);
      setState(() {
        tapColors = ColorSet.colorsSet5;
        tapColor = tapColors[0];
        tapColors.shuffle();
        tapColors.shuffle();
        colorCounts = tapCount.getRange(0, totalColors).toList();
      });
      for (int i = 0; i < tapColors.length; i++) {
        colorTapCountCurrent.add(0);
        print('VALUE: ${colorTapCountCurrent[i]}');
      }
    } else {
      singleColorSet = true;
      setState(() {
        tapColors = ColorSet.colorsSet4;
      });
    }
    calculatePercentInc();
  }

  ////////////////////////////////////////////////////////////////ADD USER TO CURRENT PLAYERS OF THE GAME
  Future addUserToGame() async {
    if (globals.myDailyCount == '')
      count = 0;
    else
      count = int.parse(globals.myDailyCount);
    count++;
    print('MY CURRENT COUNT: $count');

    DataSnapshot snapshot;

    snapshot = await FirebaseDatabase.instance
        .reference()
        .child('daily-list')
        .child(globals.dailyContestGameID)
        .child('players_visit')
        .once();
    if (snapshot.value != null) {
      await FirebaseDatabase.instance
          .reference()
          .child('daily-list')
          .child(globals.dailyContestGameID)
          .child('players_visit')
          .push();
      await FirebaseDatabase.instance
          .reference()
          .child('daily-list')
          .child(globals.dailyContestGameID)
          .child('players_visit')
        ..child(globals.userID).push();
      await FirebaseDatabase.instance
          .reference()
          .child('daily-list')
          .child(globals.dailyContestGameID)
          .child('players_visit')
          .child(globals.userID)
          .set({
        'userID': globals.userID.toString(),
        'username': userName,
        'count': count,
        'appVer': globals.currentAppVersion
      });
    } else {
      await FirebaseDatabase.instance
          .reference()
          .child('daily-list')
          .child(globals.dailyContestGameID)
          .child('players_visit')
          .push();
      await FirebaseDatabase.instance
          .reference()
          .child('daily-list')
          .child(globals.dailyContestGameID)
          .child('players_visit')
        ..child(globals.userID).push();
      await FirebaseDatabase.instance
          .reference()
          .child('daily-list')
          .child(globals.dailyContestGameID)
          .child('players_visit')
          .child(globals.userID)
          .set({
        'userID': globals.userID.toString(),
        'username': userName,
        'count': count,
        'appVer': globals.currentAppVersion
      });
    }
  }

  //////////////////////////////////////////////////////////////////GET USERNAME AND CHECK FB FOR FIRST LOAD
  Future getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userName = prefs.getString('username');
    ///////////////////////////WINNER NODE EXIST OR NOT
    DataSnapshot data = await FirebaseDatabase.instance
        .reference()
        .child('daily-list')
        .child(globals.dailyContestGameID)
        .once();
    gameID = data.value['daily-game-id'].toString();

    if (data.value != null) {
      print('FIREBASE DATA RECEIVED FIRST TIME');
      if (data.value['env'] == 'test') {
        if (data.value['status'] == 'new') {
          await addUserToGame().catchError((error) {
            print('SOMETHING WENT WRON');
            Crashlytics.instance.log(
                'MCQ ADD USER TO FB EXCEPTION IN checkFBForFirstTime METHOD: $error');
            Crashlytics.instance.setString('USER ID', globals.userID);
            Crashlytics.instance.setString('USERNAME', globals.username);
          }).then((value) async {
            if (!singleColorSet) await startColorTimer();
            startStopWatch();
          });
        }
      }
    } else
      print('NO NEXT-GAME NODE EXIST');

    setState(() {
      if (allTranslations.currentLanguage == 'ur')
        prizeTxt = data.value['prize-urdu'];
      else
        prizeTxt = data.value['prize'];
    });

    soundId1 =
        await rootBundle.load("assets/add.mp3").then((ByteData soundData) {
      return pool.load(soundData);
    });
    soundId2 =
        await rootBundle.load("assets/pop.mp3").then((ByteData soundData) {
      return pool.load(soundData);
    });
  }

  Future calculatePercentInc() async {
    double per = 100 / totalTapCount;
    percIncrement = per / 100;

    setState(() {
      isLoading = true;
    });

    await getUsername();
  }

  Future startStopWatch() async {
    durationd = Duration(minutes: 0, seconds: 0, hours: 0);
    duration2 = Duration(minutes: 0, seconds: 0, hours: 0);
    print('DURATIONS');
    print(duration2);
    print(durationd);
    await startTimer().then((value) {
      setState(() {
        isLoading = false;
      });
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

  Future startColorTimer() async {
    colorWatch.start();
    colorTimer = new Timer.periodic(Duration(seconds: 4), colorCallback);
  }

  Future colorCallback(Timer timer) async {
    if (colorWatch.isRunning) {
      int boxPos = random.nextInt(totalColors);

      print('COLOR POSITION: $boxPos');
      setState(() {
        tapColor = tapColors[boxPos];
      });
    }
  }

  Future forwardTime(Timer timer) async {
    if (gameWatch.isRunning) {
      durationd = durationd + Duration(seconds: 1);
      //print('FORWARD TIMER: $durationd');

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
      if (gameTimer.isActive) {
        duration2 = duration2 + Duration(milliseconds: 10);
        int milli = 0;
        setState(() {
          if (duration2.inMilliseconds.remainder(1000).toString().length >= 2) {
            milliseconds = (duration2.inMilliseconds.remainder(1000))
                .toString()
                .substring(0, 2);
            milli = int.parse(milliseconds);
          } else if (duration2.inMilliseconds
                  .remainder(1000)
                  .toString()
                  .length <
              2) {
            milliseconds = (duration2.inMilliseconds.remainder(1000))
                .toString()
                .padLeft(2, '0');
            milli = int.parse(milliseconds);
          }
        });
        finishTime = '$hours:'
            '$minutes:'
            '$seconds:'
            '$milliseconds';
        finishDateTime = (durationd.inMilliseconds + milli);
      }
    }
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
                  width: 28,
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
                  width: 28,
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
                  width: 28,
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
                  width: 28,
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

  Future giffyDialog() async {
    colorWatch.stop();
    gameWatch.stop();
    if (colorTimer != null) colorTimer.cancel();
    if (gameTimer != null) gameTimer.cancel();
    if (gameTimer2 != null) gameTimer2.cancel();

    globals.gameCompleted = true;

    setState(() {
      calledOneTime = true;
    });

    print('GIFFY DIALOG CALLED');

    setState(() {
      isLoading = false;
    });

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
                                    text: allTranslations.text('you_top'),
                                    child: Text(
                                      allTranslations.text('you_top'),
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
                                      Navigator.pop(context);
                                      Navigator.pop(context);

                                      Navigator.popAndPushNamed(
                                          context, '/dailyContestScreen');
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

  Future singleButtonTap() async {
    await pool.play(soundId2);
    setState(() {
      decrease = false;
      contHeight = contHeight + (barHeight2 * percIncrement);
    });

    print('BAR HEIGHT: $contHeight');
    print('TOTAL HEIGHT: $barHeight2');
    if (contHeight.round() >= barHeight2.round()) {
      setState(() {
        barCmplete = true;
      });
      colorWatch.stop();
      gameWatch.stop();
      if (colorTimer != null) colorTimer.cancel();
      if (gameTimer != null) gameTimer.cancel();
      if (gameTimer2 != null) gameTimer2.cancel();

      await Future.delayed(Duration(seconds: 1));
      await Future.wait([DailyTapTapScreen.of(context).takeScreenShot()])
          .then((value) async {
        setState(() {
          isLoading = true;
        });

        ////////////////////////////////////////////////////////////////////WAIT FOR FOLLOWING COMPLETIONS
        await Future.wait([
          setWinnerDetails(),
        ], eagerError: true, cleanUp: (value) {
          print('processed $value');
        }).catchError((error) {
          print('SOMETHING WENT WRON');
          Crashlytics.instance.log(
              'MCQ INSERT WINNER DETAILS TO FB EXCEPTION IN checkNextState METHOD: $error');
          Crashlytics.instance.setString('USER ID', globals.userID);
          Crashlytics.instance.setString('USERNAME', globals.username);
        });
      }).catchError((error) {
        print('SOMETHING WENT WRON');
        Crashlytics.instance
            .log('SCREENSHOT EXCEPTION IN checkNextState METHOD: $error');
        Crashlytics.instance.setString('USER ID', globals.userID);
        Crashlytics.instance.setString('USERNAME', globals.username);
      });
      return;
    }
  }

  Future checkButonTap(index) async {
    await pool.play(soundId1);
    if (tapColor == tapColors[index]) {
      await pool.play(soundId2);
      setState(() {
        decrease = false;
        currentFillTapCount++;
        contHeight = contHeight + (barHeight * percIncrement);
      });

      if (contHeight.round() >= barHeight.round()) {
        setState(() {
          barCmplete = true;
        });
        colorWatch.stop();
        gameWatch.stop();
        if (colorTimer != null) colorTimer.cancel();
        if (gameTimer != null) gameTimer.cancel();
        if (gameTimer2 != null) gameTimer2.cancel();

        await Future.delayed(Duration(seconds: 1));
        await Future.wait([DailyTapTapScreen.of(context).takeScreenShot()])
            .then((value) async {
          setState(() {
            isLoading = true;
          });

          ////////////////////////////////////////////////////////////////////WAIT FOR FOLLOWING COMPLETIONS
          await Future.wait([
            setWinnerDetails(),
          ], eagerError: true, cleanUp: (value) {
            print('processed $value');
          }).catchError((error) {
            print('SOMETHING WENT WRON');
            Crashlytics.instance.log(
                'MCQ INSERT WINNER DETAILS TO FB EXCEPTION IN checkNextState METHOD: $error');
            Crashlytics.instance.setString('USER ID', globals.userID);
            Crashlytics.instance.setString('USERNAME', globals.username);
          });
        }).catchError((error) {
          print('SOMETHING WENT WRON');
          Crashlytics.instance
              .log('SCREENSHOT EXCEPTION IN checkNextState METHOD: $error');
          Crashlytics.instance.setString('USER ID', globals.userID);
          Crashlytics.instance.setString('USERNAME', globals.username);
        });

        return;
      }
      int count;
      print('TAP VALUE FOR THIS COLOR: ${colorTapCountCurrent[index]}');

      count = colorTapCountCurrent[index];
      count++;
      setState(() {
        colorTapCountCurrent[index] = count;
      });
      print('TAP VALUE FOR THIS COLOR: ${colorTapCountCurrent[index]}');

      if (colorCounts[index] == colorTapCountCurrent[index]) {
        ///////////////////////////////SET RANDOM TAP COUNT
        int tapCnt = random.nextInt(totalColors);
        colorCounts[index] = colorCounts[tapCnt];
        colorTapCountCurrent[index] = 0;
        /////////////////////////////SET RANDOM TAP COLOR
        int boxPos = random.nextInt(totalColors);

        setState(() {
          tapColor = tapColors[boxPos];
        });
      }
    } else {
      if (contHeight > barHeight * percIncrement) {
        setState(() {
          decrease = true;
          contHeight = contHeight - (barHeight * percIncrement);
        });
      } else
        print('REACH MIN HEIGHT');
    }
  }

  Future sendNotificationToServer(
      String gameID, String finishTime, String imageStr) async {
    print('NOTIFY SERVER');
    Map userdata = {
      "game_id": gameID,
      "userid": globals.userID,
      'screenshoot': imageStr,
      'game_time': finishTime
    };
    http.Response response =
        await http.post(URLS.dailyPracticeURL, body: json.encode(userdata));

    setState(() {
      isLoading = false;
    });
    print(response.body);
    if (response.statusCode == 200) {
      giffyDialog();

      print(response.body);
    } else {
      print('response code not 200');
      giffyDialog();
    }
  }

  Future setWinnerDetails() async {
    ///////////////////////////WINNER NODE EXIST OR NOT
    DataSnapshot data;

    data = await FirebaseDatabase.instance
        .reference()
        .child('daily-list')
        .child(globals.dailyContestGameID)
        .child('players')
        .once();
    //////////////////////////////PUSH NODE
    if (data.value == null) {
      FirebaseDatabase.instance
          .reference()
          .child('daily-list')
          .child(globals.dailyContestGameID)
          .child('players')
          .push();
      FirebaseDatabase.instance
          .reference()
          .child('daily-list')
          .child(globals.dailyContestGameID)
          .child('players')
          .child(globals.userID)
          .push();
      await FirebaseDatabase.instance
          .reference()
          .child('daily-list')
          .child(globals.dailyContestGameID)
          .child('players')
          .child(globals.userID)
          .set({
        'userID': globals.userID.toString(),
        'username': userName,
        'timeStampInMilli': finishDateTime,
        'timeStamp': finishTime,
        'count': count,
        'appVer': globals.currentAppVersion
      });
    } else {
      FirebaseDatabase.instance
          .reference()
          .child('daily-list')
          .child(globals.dailyContestGameID)
          .child('players')
          .child(globals.userID)
          .push();
      await FirebaseDatabase.instance
          .reference()
          .child('daily-list')
          .child(globals.dailyContestGameID)
          .child('players')
          .child(globals.userID)
          .set({
        'userID': globals.userID.toString(),
        'username': userName,
        'timeStampInMilli': finishDateTime,
        'timeStamp': finishTime,
        'count': count,
        'appVer': globals.currentAppVersion
      });
    }
    await Future.delayed(Duration(seconds: 1));

    DataSnapshot playerData = await FirebaseDatabase.instance
        .reference()
        .child('daily-list')
        .child(globals.dailyContestGameID)
        .child('players')
        .once();

    //////////////////////////////////////GET TIMESTAMP LIST

    Map<dynamic, dynamic> map = playerData.value;
    List<dynamic> playersList = new List();
    map.forEach((key, values) {
      playersList.add(values);
    });
    playersList
        .sort((a, b) => a['timeStampInMilli'].compareTo(b['timeStampInMilli']));
    print('SORTED PLAYER LIST: $playersList');

    //////////////////////////////////////////IF ONLY I PLAYED THE GAME
    if (playersList[0]['userID'] == globals.userID) {
      try {
        await Future.wait([DailyTapTapScreen.of(context).takeScreenShot()])
            .then((value) async {
          try {
            await FirebaseDatabase.instance
                .reference()
                .child('daily-list')
                .child(globals.dailyContestGameID)
                .update({'winner': userName, 'winner_id': globals.userID}).then(
                    (value) {
              Future.wait([
                sendNotificationToServer(
                    gameID, finishTime, globals.base64Image)
              ]).catchError((error) {
                print('SOMETHING WENT WRON');
                Crashlytics.instance.log(
                    'MCQ IMAGE SENT TO SERVER EXCEPTION IN setWinnerDetails METHOD: $error');
                Crashlytics.instance.setString('USER ID', globals.userID);
                Crashlytics.instance.setString('USERNAME', globals.username);
              });
            });
          } catch (e, s) {
            Crashlytics.instance.recordError(e, s, context: 'as an example');
          }
        });
      } catch (e, s) {
        Crashlytics.instance.recordError(e, s, context: 'as an example');
      }
    } else {
      setState(() {
        meWinner = false;
        isLoading = false;
      });
      gameEndDialog(playersList[0]['timeStamp']);
    }
  }

  List<Widget> buttons() {
    List<Widget> buttons = new List();
    for (int i = 0; i < tapColors.length; i++) {
      buttons.add(
        Container(
          padding: EdgeInsets.all(5),
          child: GestureDetector(
            onTap: barCmplete
                ? null
                : () {
                    if (singleColorSet)
                      singleButtonTap();
                    else
                      checkButonTap(i);
                  },
            child: Container(
              decoration: BoxDecoration(
                color: tapColors[i],
                shape: BoxShape.circle,
              ),
              height: 52,
              width: 52,
              alignment: Alignment.center,
              child: Text(
                'TAP',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
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

    colorWatch.stop();
    gameWatch.stop();
    if (colorTimer != null) colorTimer.cancel();
    if (gameTimer != null) gameTimer.cancel();
    if (gameTimer2 != null) gameTimer2.cancel();

    if (popupShown) Navigator.pop(context);

    setState(() {
      popupShown = true;
      gameEndAlreadyShown = true;
    });

    globals.gameCompleted = true;

    setState(() {
      isLoading = false;
    });

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
                                    allTranslations.text('betterLuck'),
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
                                    text: allTranslations.text('time_to_beat'),
                                    child: Text(
                                      allTranslations.text('time_to_beat'),
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
                                  //color: Colors.blue[100],
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.only(top: 5),

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
                                      Navigator.pop(context);
                                      Navigator.pop(context);

                                      Navigator.popAndPushNamed(
                                          context, '/dailyContestScreen');
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

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    barHeight = MediaQuery.of(context).size.height * 0.60;
    barHeight2 = MediaQuery.of(context).size.height * 0.70;

    return FadeTransition(
      opacity: _contentAnimation,
      child: ModalProgressHUD(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          padding: EdgeInsets.only(top: 30, bottom: 5, left: 0, right: 0),
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
                          language == 'ur'
                              ? widget.mapData['prize_urdu']
                              : widget.mapData['prize_eng'],
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
                            userName,
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
                      singleColorSet
                          ? SizedBox()
                          : Container(
                              alignment: Alignment.center,
                              child: Text(
                                allTranslations.text('tap_color'),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                      singleColorSet
                          ? SizedBox()
                          : Container(
                              margin: EdgeInsets.only(top: 10),
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                height: 40,
                                width: MediaQuery.of(context).size.width * 0.40,
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
                                height: singleColorSet
                                    ? MediaQuery.of(context).size.height * 0.70
                                    : MediaQuery.of(context).size.height * 0.60,
                                width: MediaQuery.of(context).size.width * 0.45,
                              ),
                              Positioned(
                                bottom: 0,
                                child: Container(
                                  // color: Colors.white,

                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 400),
                                    curve: decrease
                                        ? Curves.linear
                                        : Curves.elasticOut,
                                    width: MediaQuery.of(context).size.width *
                                        0.45,
                                    constraints: BoxConstraints(minHeight: 10),
                                    height: contHeight,
                                    color: Theme.of(context).accentColor,
                                    child: Container(),
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
              Container(
                //color: Colors.blue[100],
                margin: EdgeInsets.only(top: 10),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  direction: Axis.horizontal,
                  children: buttons(),
                ),
              ),
            ],
          ),
        ),
        inAsyncCall: isLoading,
      ),
    );
  }
}
