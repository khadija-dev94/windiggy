import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:auto_direction/auto_direction.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:network_image_to_byte/network_image_to_byte.dart';
import 'package:soundpool/soundpool.dart';
import 'package:win_diggy/Models/GlobalMethods.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:win_diggy/Globals.dart' as globals;
import 'package:win_diggy/Models/Box.dart';
import 'package:win_diggy/Models/GlobalTranslations.dart';
import 'package:win_diggy/CustomIcons/puzzle_icons_icons.dart';
import 'package:win_diggy/Models/ShadowLevel.dart';
import 'package:win_diggy/Models/URLS.dart';
import 'package:win_diggy/Widgets/CurrentPlayers.dart';
import 'package:win_diggy/Globals.dart' as globals;
import 'package:win_diggy/Widgets/CurrentWinners.dart';
import 'dart:ui' as ui;

import 'package:win_diggy/Widgets/NetworkWidget.dart';
import 'package:win_diggy/Widgets/Tissue.dart';

bool gameLoaded = false;

Future<Map<String, dynamic>> fetchCountry(http.Client client) async {
  print('IMAGE DIFFERENCE GAME');

  DataSnapshot data = null;
  data = await FirebaseDatabase.instance
      .reference()
      .child('daily-list')
      .child(globals.dailyContestGameID)
      .once();
  return {'image': data.value['game-data']['details']['image']};
}

class ScratchCardContestScreen extends StatefulWidget {
  static ScratchCardScreenState of(BuildContext context) =>
      context.ancestorStateOfType(const TypeMatcher<ScratchCardScreenState>());
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ScratchCardScreenState();
  }
}

bool matched = false;

class ScratchCardScreenState extends State<ScratchCardContestScreen> {
  bool capPop;
  ScreenshotController screenshotController = ScreenshotController();

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
                child: NetworkSensitive(
                  child: FutureBuilder<Map<String, dynamic>>(
                    future: fetchCountry(new http.Client()),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) print(snapshot.error);

                      return snapshot.hasData
                          ? new ScratchCardView(
                              data: snapshot.data,
                            )
                          : new Center(child: new CircularProgressIndicator());
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        onWillPop: () {
          return closeDialog();
        });
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
                                          color: Colors.grey[800],
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
          'IMG DIFF SCREENSHOT CAPTURE EXCEPTION IN takeScreenShot METHOD: $error');
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
          .log('IMG DIFF IMAGE COMPRESS EXCEPTION IN _upload METHOD: $error');
    });
    print('IMAGE COMPRESED');
    String imageStr = base64Encode(compress);
    return imageStr;
  }
}

class ScratchCardView extends StatefulWidget {
  Map<String, dynamic> data;

  ScratchCardView({
    this.data,
  });
  static ScratchCardViewState of(BuildContext context) =>
      context.ancestorStateOfType(const TypeMatcher<ScratchCardViewState>());

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ScratchCardViewState();
  }
}

typedef MultiTapButtonCallback = void Function(bool correctNumberOfTouches);
typedef MultiFingerUpButtonCallback = void Function(
    TapUpDetails correctNumberOfTouches);
typedef MultiFingerUpdateButtonCallback = void Function(
    TapDownDetails correctNumberOfTouches);

class ScratchCardViewState extends State<ScratchCardView>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  bool isLoading;

  String hours, minutes, seconds, milliseconds;
  var finishTime;
  bool meWinner;
  bool calledOneTime;
  var diffFound;
  int finishDateTime;
  bool gameLocked;
  bool popupShown;
  String prizeTxt;
  bool gameEndAlreadyShown;
  bool gameCompletedCalledOnce;
  Stopwatch watch = new Stopwatch();
  Timer timer1;
  Timer timer2;
  Duration durationd;
  Duration duration2;
  bool enterBeforeTime;
  bool gamePlayed;
  bool corruptGame;
  Soundpool pool;
  int soundID;
  bool isImageloaded = false;
  String userName;
  AnimationController _controller;
  List<Offset> points = [];
  int totalCheckpoints = 0;
  bool isFinished = false;
  Offset _lastPosition;
  double progress = 0;
  List<Rect> totalPoints = [];
  List<Rect> markedPoints = [];
  double totalWidth = 0;
  double totalHeight = 0;
  var xOffset = 0.0;
  var yOffset = 0.0;
  var totalArea = 0.0;
  var coveredArea = 0.0;
  GlobalKey _keyYellow = GlobalKey();
  GlobalKey _keyRed = GlobalKey();
  RenderBox get renderObject {
    return _keyRed.currentContext.findRenderObject() as RenderBox;
  }

  Animation<double> _animation;
  bool pointerDown = false;
  bool multiTouch = false;
  int minTouches = 1;
  double per = 0.0;
  int count;
  String gameID;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    hours = '00';
    minutes = '00';
    seconds = '00';
    milliseconds = '00';
    finishDateTime = globals.userEnterTime;
    finishTime = '$hours:'
        '$minutes:'
        '$seconds:'
        '$milliseconds';

    WidgetsBinding.instance.addObserver(this);

    enterBeforeTime = false;
    globals.gameCompleted = false;
    corruptGame = false;
    gamePlayed = false;

    prizeTxt = '';
    gameLocked = false;
    popupShown = false;
    meWinner = false;
    calledOneTime = false;
    gameCompletedCalledOnce = false;
    gameEndAlreadyShown = false;
    userName = '';
    isLoading = false;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    )..addStatusListener(
        (listener) {
          if (listener == AnimationStatus.completed) {
            _controller.reverse();
          }
        },
      );
    _animation = Tween(begin: 1.0, end: 1.10).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticIn,
      ),
    );
    registerListener();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    if (_controller != null) _controller.dispose();
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
    watch.stop();
    if (timer2 != null) timer2.cancel();

    if (timer1 != null) timer1.cancel();
  }

  void onTap(bool correctNumberOfTouches) async {
    print("Tapped with  finger(s): $correctNumberOfTouches");
    if (correctNumberOfTouches)
      multiTouch = false;
    else
      multiTouch = true;
  }

  Future pauseTimer() async {
    //watch.stop();
  }

  Future resumeTimer() async {}

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

  Future registerListener() async {
    setState(() {
      isLoading = true;
    });

    pool = Soundpool(streamType: StreamType.notification);

    soundID = await rootBundle
        .load("assets/flipMatch.mp3")
        .then((ByteData soundData) {
      return pool.load(soundData);
    });

    print('LISTENRER ATTACHED');

    await getUsername();
  }

  //////////////////////////////////////////////////////////////////GET USERNAME AND CHECK FB FOR FIRST LOAD
  Future getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userName = prefs.getString('username');

    DataSnapshot data;

    data = await FirebaseDatabase.instance
        .reference()
        .child('daily-list')
        .child(globals.dailyContestGameID)
        .once();
    gameID = data.value['daily-game-id'].toString();

    setState(() {
      if (allTranslations.currentLanguage == 'ur')
        prizeTxt = data.value['prize-urdu'];
      else
        prizeTxt = data.value['prize'];
    });
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
            startStopWatch();
          });
        }
      }
    } else
      print('NO NEXT-GAME NODE EXIST');
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
    watch.start();
    /////////////////////////////////////////////////////////////////////TIMER FOR HOURS, MINUTES AND SECONDS
    timer1 = new Timer.periodic(new Duration(seconds: 1), forwardTime);
    ///////////////////////////////////////////////////////////TIMER FOR MILLISECONDS
    timer2 =
        new Timer.periodic(new Duration(milliseconds: 10), forwardTimeMilisec);
  }

  Future forwardTime(Timer timer) async {
    if (watch.isRunning) {
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
    if (watch.isRunning) {
      if (timer1.isActive) {
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

  Future gameComplete() async {
    watch.stop();
    if (timer2 != null) timer2.cancel();

    if (timer1 != null) timer1.cancel();
    await Future.delayed(Duration(seconds: 1));
    try {
      await Future.wait([ScratchCardContestScreen.of(context).takeScreenShot()])
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
    } catch (e, s) {
      Crashlytics.instance.recordError(e, s, context: 'as an example');
    }
  }

  Future giffyDialog() async {
    watch.stop();
    if (timer1 != null) timer1.cancel();
    if (timer2 != null) timer2.cancel();

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
        await Future.wait(
                [ScratchCardContestScreen.of(context).takeScreenShot()])
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

  Future gameEndDialog(message) async {
    print('GAME END DIALOG CALLED');
    watch.stop();
    if (timer1 != null) timer1.cancel();
    if (timer2 != null) timer2.cancel();

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
    return ModalProgressHUD(
      child: Container(
        height: double.infinity,
        width: double.infinity,
        padding: EdgeInsets.only(top: 30, bottom: 5, left: 0, right: 0),
        child: Column(
          children: <Widget>[
            Container(
              // height: MediaQuery.of(context).size.height * 0.08,
              padding: EdgeInsets.only(left: 8, right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      //margin: EdgeInsets.only(left: 8),
                      padding: EdgeInsets.only(top: 5, right: 15),
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        prizeTxt,
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
            Container(
              margin: EdgeInsets.only(top: 10),
              alignment: Alignment.center,
              child: Text(
                allTranslations.text('scratch_game_test'),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ),
            Container(
              //height: 50,
              margin: EdgeInsets.only(top: 20),
              alignment: Alignment.center,
              child: Text(
                per.toStringAsFixed(1) + '%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Container(
                child: RawGestureDetector(
                  behavior: HitTestBehavior.opaque,
                  gestures: {
                    MultiTouchGestureRecognizer:
                        GestureRecognizerFactoryWithHandlers<
                            MultiTouchGestureRecognizer>(
                      () => MultiTouchGestureRecognizer(),
                      (MultiTouchGestureRecognizer instance) {
                        instance.minNumberOfTouches = 1;
                        instance.onMultiTap = (correctNumberOfTouches) =>
                            this.onTap(correctNumberOfTouches);
                      },
                    ),
                  },
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanStart: (details) async {
                      await Future.delayed(Duration(milliseconds: 500));
                      if (!multiTouch) {
                        if (!isFinished) {
                          final RenderBox box =
                              _keyRed.currentContext.findRenderObject();
                          final RenderBox boxYellow =
                              _keyYellow.currentContext.findRenderObject();
                          final result = BoxHitTestResult();
                          Offset localRed =
                              box.globalToLocal(details.globalPosition);
                          Offset localYellow =
                              boxYellow.globalToLocal(details.globalPosition);
                          if (box.hitTest(result, position: localRed)) {
                            var total = (markedPoints.length * xOffset) *
                                (markedPoints.length * yOffset);
                            setState(() {
                              per = (total / totalArea) * 100;
                            });
                            if (totalArea == total) {
                              print('YOU WON');
                              setState(() {
                                isFinished = true;
                              });
                              await pool.play(soundID);
                              _controller.forward();
                              gameComplete();
                            } else
                              _addPoint(details.globalPosition);
                          } else if (boxYellow.hitTest(result,
                              position: localYellow)) {
                            print("HIT...RED ");
                          }
                        }
                      }
                    },
                    onPanUpdate: (details) async {
                      if (!multiTouch) {
                        if (!isFinished) {
                          final RenderBox box =
                              _keyRed.currentContext.findRenderObject();
                          final RenderBox boxYellow =
                              _keyYellow.currentContext.findRenderObject();
                          final result = BoxHitTestResult();
                          Offset localRed =
                              box.globalToLocal(details.globalPosition);
                          Offset localYellow =
                              boxYellow.globalToLocal(details.globalPosition);
                          if (box.hitTest(result, position: localRed)) {
                            var total = (markedPoints.length * xOffset) *
                                (markedPoints.length * yOffset);
                            setState(() {
                              per = (total / totalArea) * 100;
                            });
                            if (totalArea == total) {
                              print('YOU WON');
                              setState(() {
                                isFinished = true;
                              });
                              await pool.play(soundID);
                              _controller.forward();
                              gameComplete();
                            } else
                              _addPoint(details.globalPosition);
                          } else if (boxYellow.hitTest(result,
                              position: localYellow)) {
                            print("HIT...RED ");
                          }
                        }
                      }
                    },
                    onPanEnd: (details) => setState(() {
                      points.add(null);
                    }),
                    child: Stack(
                      children: <Widget>[
                        CustomPaint(
                          key: _keyYellow,
                          child: Container(
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 0),
                            child: isFinished
                                ? ScaleTransition(
                                    scale: _animation,
                                    child: Container(
                                      //color: Colors.blue,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.70,
                                      width: MediaQuery.of(context).size.width,
                                      child: CachedNetworkImage(
                                        fit: BoxFit.fill,
                                        imageUrl: widget.data['image'],
                                        placeholder: (context, url) => Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
                                      ),
                                    ),
                                  )
                                : CustomPaint(
                                    key: _keyRed,
                                    foregroundPainter: ScratchCardPainter(
                                      points: points,
                                      brushSize: 20,
                                      color: Colors.grey,
                                      onDraw: (size) {
                                        if (totalCheckpoints == 0) {
                                          _setCheckpoints(size);
                                        }
                                      },
                                      totalPoints: this.totalPoints,
                                      markedPoints: this.markedPoints,
                                      totalArea: this.coveredArea,
                                    ),
                                    child: Container(
                                      color: Colors.blue,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.70,
                                      width: MediaQuery.of(context).size.width,
                                      child: CachedNetworkImage(
                                        fit: BoxFit.fill,
                                        imageUrl: widget.data['image'],
                                        placeholder: (context, url) => Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
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
          ],
        ),
      ),
      inAsyncCall: isLoading,
    );
  }

  Future _addPoint(Offset globalPosition) async {
    // Ignore when same point is reported multiple times in a row
    if (_lastPosition == globalPosition) {
      return;
    }
    _lastPosition = globalPosition;
    var point = renderObject.globalToLocal(globalPosition);
    // Ignore when starting point of new line has been already scratched
    if (points.isNotEmpty && points.contains(point)) {
      if (points.last == null) {
        return;
      } else {
        point = null;
      }
    }
    setState(() {
      points.add(point);
    });
  }

  void _setCheckpoints(Size size) {
    _calculateCheckpoints(size);
    totalCheckpoints = totalPoints.length;
    print('TOTAL POINTS: $totalCheckpoints');
  }

  _calculateCheckpoints(Size size) {
    xOffset = size.width / 10;
    yOffset = size.height / 10;
    for (var x = 0; x < 10; x++) {
      for (var y = 0; y < 10; y++) {
        var point = Offset(
          (xOffset / 2) + x * xOffset,
          (yOffset / 2) + y * yOffset,
        );

        totalPoints.add(
            Rect.fromCenter(center: point, width: xOffset, height: yOffset));
      }
    }
    print(
        'TOTAL AREA: ${(yOffset * totalPoints.length) * (xOffset * totalPoints.length)}');
    totalArea = (yOffset * totalPoints.length) * (xOffset * totalPoints.length);
  }
}

class ShapesPainter extends CustomPainter {
  double height;
  double width;
  @override
  void paint(Canvas canvas, Size size) {
    height = size.height;
    width = size.width;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  @override
  bool hitTest(Offset position) {
    final Offset center = Offset(width / 2, height / 2);
    Path path = Path();
    path.addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: width, height: height),
        Radius.circular(center.dx)));
    path.close();
    return path.contains(position);
  }
}

typedef DrawFunction(Size size);

class ScratchCardPainter extends CustomPainter {
  ScratchCardPainter({
    this.points,
    this.brushSize,
    this.color,
    this.onDraw,
    this.totalPoints,
    this.markedPoints,
    this.totalArea,
  });

  /// List of revealed points from scratcher
  List<Offset> points;
  List<Rect> totalPoints;
  List<Rect> markedPoints;
  double singleWidth;
  double singleHeight;
  double totalArea;
  final double brushSize;

  final Color color;
  final DrawFunction onDraw;
  double totalW;
  double totalH;
  List<Color> colors = [
    Colors.blue,
    Colors.pink,
    Colors.yellow,
    Colors.green,
    Colors.black
  ];

  Paint get mainPaint {
    var paint = Paint()
      ..strokeCap = StrokeCap.round
      ..color = Colors.transparent
      ..strokeWidth = brushSize
      ..blendMode = BlendMode.src
      ..style = PaintingStyle.stroke;

    return paint;
  }

  @override
  void paint(Canvas canvas, Size size) {
    onDraw(size);
    canvas.saveLayer(null, Paint());

    var areaRect = Rect.fromLTRB(0, 0, size.width, size.height);
    canvas.drawRect(areaRect, Paint()..color = color);
    //print('Total offsets; ${areaRect.bottomRight.dx*areaRect.bottomRight.dy}');

    var path = Path();
    var isStarted = false;

    points.forEach((point) {
      if (point == null) {
        canvas.drawPath(path, mainPaint);
        path = Path();
        isStarted = false;
      } else {
        if (!isStarted) {
          isStarted = true;
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
    });

    singleWidth = size.width / 10;
    singleHeight = size.height / 10;
    totalPoints.forEach((point) {
      Paint circle = new Paint()..color = Colors.transparent;
      canvas.drawRect(point, circle);
    });

    canvas
      ..drawPath(path, mainPaint)
      ..restore();
  }

  @override
  bool hitTest(Offset position) {
    Path path;
    totalPoints.forEach((point) async {
      path = Path();
      path.addRect(point);
      path.close();
      if (path.contains(position)) {
        if (!markedPoints.contains(point)) {
          markedPoints.add(point);
          totalW = markedPoints.length * singleWidth;
          totalH = markedPoints.length * singleHeight;
          totalArea = totalW * totalH;

          return true;
        } else {
          //print('ELSE CALLED');
          return false;
        }
      } else {
        //print('point not contain');
        return false;
      }
    });

    return false;
  }

  @override
  bool shouldRepaint(ScratchCardPainter oldDelegate) => true;
}

class MultiTouchGestureRecognizer extends MultiTapGestureRecognizer {
  MultiTouchGestureRecognizerCallback onMultiTap;
  var numberOfTouches = 0;
  int minNumberOfTouches = 0;

  MultiTouchGestureRecognizer() {
    super.onTapDown = (pointer, details) {
      this.addTouch(pointer, details);
    };
    super.onTapUp = (pointer, details) => this.removeTouch(pointer, details);
    super.onTapCancel = (pointer) => this.cancelTouch(pointer);
    super.onTap = (pointer) => this.captureDefaultTap(pointer);
  }

  Future addTouch(int pointer, TapDownDetails details) async {
    this.numberOfTouches++;
    print('FINGER: $numberOfTouches');

    if (this.numberOfTouches == this.minNumberOfTouches) {
      this.onMultiTap(true);
    } else if (this.numberOfTouches != 0) {
      this.onMultiTap(false);
    }
  }

  void removeTouch(int pointer, TapUpDetails details) {
    if (this.numberOfTouches == this.minNumberOfTouches) {
      this.onMultiTap(true);
    } else if (this.numberOfTouches != 0) {
      this.onMultiTap(false);
    }

    this.numberOfTouches = 0;
  }

  void cancelTouch(int pointer) {
    this.numberOfTouches = 0;
  }

  void captureDefaultTap(int pointer) {}

  @override
  set onTapDown(_onTapDown) {}

  @override
  set onTapUp(_onTapUp) {}

  @override
  set onTapCancel(_onTapCancel) {}

  @override
  set onTap(_onTap) {}
}

typedef MultiTouchGestureRecognizerCallback = void Function(
    bool correctNumberOfTouches);
