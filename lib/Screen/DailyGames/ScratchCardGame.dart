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

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String encryptGameID = prefs.getString('gameID');
  DateTime targetdateTime =
      globals.dateFormat.parse(prefs.getString('startTime'));
  String decryptedID = await GlobalsMethods.decryptGameID(
      targetdateTime.hour, targetdateTime.day, encryptGameID);

  print('GAME ID: $decryptedID');
  DataSnapshot gameNode = await FirebaseDatabase.instance
      .reference()
      .child('game-' + decryptedID)
      .once();
  if (gameNode.value != null) {
    DataSnapshot snapshot = await FirebaseDatabase.instance
        .reference()
        .child('game-' + decryptedID)
        .child('game-data')
        .once();
    if (snapshot.value != null) {
      ///////////////////////////WINNER NODE EXIST OR NOT
      await DefaultCacheManager().getFile(snapshot.value['details']['image']);
      DataSnapshot data = await FirebaseDatabase.instance
          .reference()
          .child('game-' + decryptedID)
          .child('players_count')
          .once();

      if (data.value == null) {
        FirebaseDatabase.instance
            .reference()
            .child('game-' + decryptedID)
            .child('players_count')
            .push();
        await FirebaseDatabase.instance
            .reference()
            .child('game-' + decryptedID)
            .child('players_count')
            .set({
          'initial': 0,
        });
        FirebaseDatabase.instance
            .reference()
            .child('game-' + decryptedID)
            .child('players_counter')
            .push();

        await FirebaseDatabase.instance
            .reference()
            .child('game-' + decryptedID)
            .child('players_counter')
            .set({
          'count': 0,
        });
      }

      return {
        'gameID': decryptedID,
        'enterBefore': false,
        'gameID': decryptedID,
        'nodeExist': true,
        'image': snapshot.value['details']['image'],
      };
    } else
      return {'enterBefore': true, 'nodeExist': true};
  } else
    return {'enterBefore': false, 'nodeExist': false};
}

class ScratchCardScreen extends StatefulWidget {
  static ScratchCardScreenState of(BuildContext context) =>
      context.ancestorStateOfType(const TypeMatcher<ScratchCardScreenState>());
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ScratchCardScreenState();
  }
}

bool matched = false;

class ScratchCardScreenState extends State<ScratchCardScreen> {
  bool capPop;
  GlobalKey<ScratchCardViewState> _keyChild1 = GlobalKey();
  ScreenshotController screenshotController = ScreenshotController();
  bool timerFinished;
  Stopwatch watch = new Stopwatch();
  Timer timer1;
  Duration duration = new Duration(seconds: 11);
  String seconds;
  bool gameLoaded;
  Map<String, dynamic> fbData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    capPop = false;
    gameLoaded = false;
    timerFinished = false;
    seconds = '';
    globals.ScratchGlobalKey = _keyChild1;
    gameLoadedorNot();
  }

  Future gameLoadedorNot() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('gameLoaded') == 'yes') {
      gameLoaded = true;
      setState(() {
        timerFinished = true;
        gameLoaded = true;
      });
    } else {
      gameLoaded = false;
      setState(() {
        timerFinished = false;
        gameLoaded = false;
      });
      await startTimer();
      fbData = await fetchCountry(new http.Client());
    }
  }

  Future startTimer() async {
    watch.start();
    timer1 = new Timer.periodic(new Duration(seconds: 1), reverseTimerCallback);
  }

  Future reverseTimerCallback(Timer t) async {
    if (watch.isRunning) {
      if (timer1.isActive) {
        duration = duration - Duration(seconds: 1);

        if (!duration.isNegative) {
          setState(() {
            seconds = (duration.inSeconds.remainder(60)).toString();
          });
        } else {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('gameLoaded', 'yes');
          watch.stop();
          if (timer1 != null) timer1.cancel();
          setState(() {
            timerFinished = true;
          });
        }
      }
    }
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
                child: gameLoaded
                    ? FutureBuilder<Map<String, dynamic>>(
                        future: fetchCountry(new http.Client()),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) print(snapshot.error);

                          return snapshot.hasData
                              ? new ScratchCardView(
                                  data: snapshot.data,
                                  key: _keyChild1,
                                )
                              : new Center(
                                  child: new CircularProgressIndicator());
                        },
                      )
                    : timerFinished
                        ? new ScratchCardView(
                            data: fbData,
                            key: _keyChild1,
                          )
                        : Container(
                            alignment: Alignment.center,
                            child: Text(
                              seconds,
                              style: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontSize: 100,
                              ),
                            ),
                          ),
              ),
            ),
          ),
        ),
      ),
      onWillPop: Navigator.of(context).canPop()
          ? () {
              _keyChild1.currentState.pauseTimer();
              setState(() {
                capPop = true;
              });
              return closeDialog();
            }
          : () {
              _keyChild1.currentState.pauseTimer();

              setState(() {
                capPop = false;
              });
              return closeDialog();
            },
    );
  }

  Future<bool> closeScreen(context) async {
    globals.HOMEONFRONT = true;
    globals.onceInserted = false;
    //Navigator.of(context).pop();

    Navigator.popAndPushNamed(context, '/dashboard');
    return false;
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
  GlobalKey key;

  ScratchCardView({
    this.data,
    this.key,
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
  var updateListener;
  bool gameEndAlreadyShown;
  bool gameCompletedCalledOnce;
  Stopwatch watch = new Stopwatch();
  Timer timer1;
  Timer timer2;
  Duration durationd;
  Duration duration2;
  ValueNotifier<int> playersCountNotifier = new ValueNotifier<int>(0);
  ValueNotifier<int> winnersCountNotifier = new ValueNotifier<int>(0);
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    hours = globals.hours;
    minutes = globals.min;
    seconds = globals.sec;
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

    if (!widget.data['nodeExist'] && !widget.data['enterBefore']) {
      setState(() {
        corruptGame = true;
      });
    } else if (widget.data['nodeExist'] && widget.data['enterBefore']) {
      setState(() {
        enterBeforeTime = true;
      });
    } else {
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
  }

  @override
  void dispose() {
    // TODO: implement dispose
    if (_controller != null) _controller.dispose();
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
    if (updateListener != null) updateListener.cancel();

    watch.stop();
    if (timer2 != null) timer2.cancel();

    if (timer1 != null) timer1.cancel();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      if (updateListener != null) updateListener.cancel();
    }
    if (state == AppLifecycleState.resumed) {
      updateListener = FirebaseDatabase.instance
          .reference()
          .child('game-' + widget.data['gameID'])
          .onChildChanged
          .listen(_onChildUpdated);
      print('QUIZ SCREEN WIDGET RESUMED');
      if (!gameCompletedCalledOnce) {
        if (watch.isRunning) {
          watch.stop();
          if (timer2 != null) timer2.cancel();

          if (timer1 != null) timer1.cancel();
          await startStopWatch().then((value) {
            getData();
          });
        }
      }
    }
  }

  void onTap(bool correctNumberOfTouches) async {
    print("Tapped with  finger(s): $correctNumberOfTouches");
    if (correctNumberOfTouches)
      multiTouch = false;
    else
      multiTouch = true;
  }

  Future pauseTimer() async {
    if (updateListener != null) updateListener.cancel();

    //watch.stop();
  }

  Future resumeTimer() async {
    //watch.start();
    updateListener = FirebaseDatabase.instance
        .reference()
        .child('game-' + widget.data['gameID'])
        .onChildChanged
        .listen(_onChildUpdated);
  }

///////////////////////////////////////////////////////////////CHECK FIREBASE FOR NEW GAME ON WIDGET RESUME
  Future getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      await Future.wait([checkFBOnWidgetResume()]).then((value) {
        setState(() {
          isLoading = false;
        });
      });
    } catch (e, s) {
      Crashlytics.instance.recordError(e, s, context: 'as an example');
    }
  }

  Future checkFBOnWidgetResume() async {
    ///////////////////////////WINNER NODE EXIST OR NOT
    DataSnapshot countData = await FirebaseDatabase.instance
        .reference()
        .child('game-' + widget.data['gameID'])
        .child('players_count')
        .once();

    if (countData.value != null) {
      Map winnerMap = countData.value;
      playersCountNotifier.value = winnerMap.length;
    } else
      playersCountNotifier.value = 0;

    DataSnapshot winners = await FirebaseDatabase.instance
        .reference()
        .child('game-' + widget.data['gameID'])
        .child('players')
        .once();

    if (winners.value != null) {
      Map winnerMap = winners.value;
      winnersCountNotifier.value = winnerMap.length;
    } else
      winnersCountNotifier.value = 0;

    DataSnapshot snapshot =
        await FirebaseDatabase.instance.reference().child('next-game').once();
    if (snapshot.value != null) {
      print('FIREBASE DATA RECEIVED ON QUIZ SCREEN WIDGET RESUMED');
      if (snapshot.value['env'] == 'live') {
        if (snapshot.value['status'] == 'Complete') {
          await gameCompleteDialog();
        } else if (snapshot.value['game-id'].toString() !=
            widget.data['gameID']) {
          print('GAME IDS ARE DIFFERENT ON WIDGET RESUME');

          await gameCancelDialog();
        } else {
          setState(() {
            isLoading = false;
          });
          print('GAME NOT COMPLETED YET');
        }
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future checkFBForFirstTime() async {
    DataSnapshot snapshot =
        await FirebaseDatabase.instance.reference().child('next-game').once();

    if (snapshot.value != null) {
      print('FIREBASE DATA RECEIVED FIRST TIME');
      if (snapshot.value['env'] == 'live') {
        if (snapshot.value['status'] == 'Complete') {
          await gameCompleteDialog();
        }
        /////////////////////////////////////////////////////////////////NEW GAME ADDED
        else if (snapshot.value['game-id'].toString() !=
            widget.data['gameID']) {
          print('GAME IDS ARE DIFFERENT IN FIRST CHECK');
          await gameCancelDialog().catchError((error) {
            print('SOMETHING WENT WRON');
            Crashlytics.instance.log(
                'MCQ GAME CANCELLED EXCEPTION IN checkFBForFirstTime METHOD: $error');
            Crashlytics.instance.setString('USER ID', globals.userID);
            Crashlytics.instance.setString('USERNAME', globals.username);
          });
        }
        ///////////////////////////////////////////////////////////////ADD USER TO GAME
        else {
          DataSnapshot userSnapshot = await FirebaseDatabase.instance
              .reference()
              .child('game-' + widget.data['gameID'])
              .child('players_count')
              .child(globals.userID)
              .once();

          await Future.wait([addUserToGame(userSnapshot)]).then((value) async {

            if (gamePlayed) {
              setState(() {
                isLoading = false;
              });
              alreadyPlayedGameDialog();
            }
            else
              startStopWatch();
          }).catchError((error) {
            print('SOMETHING WENT WRONG IN ADDING USER');
            Crashlytics.instance.log(
                'MCQ ADD USER TO FB EXCEPTION IN checkFBForFirstTime METHOD: $error');
            Crashlytics.instance.setString('USER ID', globals.userID);
            Crashlytics.instance.setString('USERNAME', globals.username);
          });
        }
      }
    } else
      print('NO NEXT-GAME NODE EXIST');
  }

  Future parseData(DataSnapshot userSnapshot) async {
    gamePlayed = userSnapshot.value['gamePlayed'];
  }

  ////////////////////////////////////////////////////////////////ADD USER TO CURRENT PLAYERS OF THE GAME
  Future addUserToGame(DataSnapshot userSnapshot) async {
    if (userSnapshot.value != null) {
      await parseData(userSnapshot);
    } else {
      FirebaseDatabase.instance
          .reference()
          .child('game-' + widget.data['gameID'])
          .child('players_count')
          .child(globals.userID)
          .push();

      print('NODE PUSHED');
      await FirebaseDatabase.instance
          .reference()
          .child('game-' + widget.data['gameID'])
          .child('players_count')
          .child(globals.userID)
          .set({
        'userID': globals.userID,
        'timestamp': finishDateTime,
        'appVer': globals.currentAppVersion,
        'gamePlayed': false
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

    updateListener = FirebaseDatabase.instance
        .reference()
        .child('game-' + widget.data['gameID'])
        .onChildChanged
        .listen(_onChildUpdated);

    DataSnapshot winners = await FirebaseDatabase.instance
        .reference()
        .child('game-' + widget.data['gameID'])
        .child('players')
        .once();

    if (winners.value != null) {
      Map winnerMap = winners.value;
      winnersCountNotifier.value = winnerMap.length;
    } else
      winnersCountNotifier.value = 0;

    await getUsername();
  }

  //////////////////////////////////////////////////////////////////GET USERNAME AND CHECK FB FOR FIRST LOAD
  Future getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userName = prefs.getString('username');

    setState(() {
      if (allTranslations.currentLanguage == 'ur')
        prizeTxt = prefs.getString('gamePrizeUrd');
      else
        prizeTxt = prefs.getString('gamePrizeEng');
    });

    try {
      await Future.wait([checkFBForFirstTime()]);
    } catch (e, s) {
      Crashlytics.instance.recordError(e, s, context: 'as an example');
    }
  }

  Future startStopWatch() async {
    DateTime targetdateTime = globals.dateFormat.parse(globals.targetTime);

    try {
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
        setState(() {
          isLoading = false;
        });
        await startTimer();
      });
    } catch (e, s) {
      Crashlytics.instance.recordError(e, s, context: 'as an example');
    }
  }

  Future startTimer() async {
    watch.start();
    /////////////////////////////////////////////////////////////////////TIMER FOR HOURS, MINUTES AND SECONDS
    timer1 = new Timer.periodic(new Duration(seconds: 1), forwardTimeCallback);
    ///////////////////////////////////////////////////////////TIMER FOR MILLISECONDS
    timer2 = new Timer.periodic(
        new Duration(milliseconds: 10), forwardTimeMilisecCallback);
  }

  Future forwardTimeCallback(Timer timer) async {
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

  Future forwardTimeMilisecCallback(Timer timer) async {
    if (watch.isRunning) {
      if (timer1.isActive) {
        duration2 = duration2 + Duration(milliseconds: 10);
        //print('FORWARD TIMER: $durationd');

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

  Future _onChildUpdated(Event event) async {
    print('UPDATED VALUE :${event.snapshot.value}');
    if (event.snapshot.value is String) {
      ///////////////////////////////////////////////////CHECK IF WINNER NAME IS SET
      if (event.snapshot.key == 'winner') {
        watch.stop();

        if (timer2 != null) timer2.cancel();

        if (timer1 != null) timer1.cancel();

        if (!calledOneTime) {
          setState(() {
            isLoading = true;
          });
          String name = event.snapshot.value.toString();

          if (!meWinner) {
            winnerDialog(name);
          }
        }
      }
    } else if (event.snapshot.value is bool) {
      if (event.snapshot.key == 'lock') {
        watch.stop();
        if (timer2 != null) timer2.cancel();

        if (timer1 != null) timer1.cancel();

        if (!gameLocked) {
          setState(() {
            isLoading = true;
          });
          if (!gameEndAlreadyShown) {
            gameEndDialog();
          }
        }
      }
    } else if (event.snapshot.key == 'players_count') {
      Map map = event.snapshot.value;
      print('PLAYERS: $map');
      int count = map.length - 1;
      await FirebaseDatabase.instance
          .reference()
          .child('game-' + widget.data['gameID'])
          .child('players_counter')
          .set({
        'count': count,
      });
    } else if (event.snapshot.key == 'players_counter') {
    } else if (event.snapshot.key == 'players') {
      //Map map = event.snapshot.value;
      //winnersCountNotifier.value = map.length;
    }
  }

  Future gameComplete() async {
    watch.stop();
    if (timer2 != null) timer2.cancel();

    if (timer1 != null) timer1.cancel();
    await Future.delayed(Duration(seconds: 1));
    try {
      await Future.wait([ScratchCardScreen.of(context).takeScreenShot()])
          .then((value) async {
        setState(() {
          isLoading = true;
        });
        print('CURRENT WINNERS OF THE GAME: ${winnersCountNotifier.value}');
        DataSnapshot data;
        data = await FirebaseDatabase.instance
            .reference()
            .child('game-' + widget.data['gameID'])
            .child('players')
            .once();

        List<dynamic> playersList = new List();
        if (data.value != null) {
          Map<dynamic, dynamic> map = data.value;

          map.forEach((key, values) {
            playersList.add(values);
          });

          if (playersList.length <= 8) {
            try {
              await Future.wait([
                setWinnerDetails(playersList.length),
              ], eagerError: true, cleanUp: (value) {
                print('processed $value');
              });
            } catch (e, s) {
              Crashlytics.instance.recordError(e, s, context: 'as an example');
            }
          } else {
            DataSnapshot data = await FirebaseDatabase.instance
                .reference()
                .child('game-' + widget.data['gameID'])
                .once();
            if (data.value['lock']) {
              gameEndDialog();
            } else {
              setState(() {
                gameLocked = true;
              });

              ////////////////////////////LOCK VALUE IS FALSE
              await FirebaseDatabase.instance
                  .reference()
                  .child('game-' + widget.data['gameID'])
                  .update({'lock': true, 'status': "Complete"});
              await FirebaseDatabase.instance
                  .reference()
                  .child('next-game')
                  .update({'status': 'Complete'});

              ////////////////////////////////////////////////////////////////////WAIT FOR FOLLOWING COMPLETIONS
              try {
                await Future.wait([
                  setWinnerDetails(playersList.length),
                ], eagerError: true, cleanUp: (value) {
                  print('processed $value');
                });
              } catch (e, s) {
                Crashlytics.instance
                    .recordError(e, s, context: 'as an example');
              }
            }
          }
        } else {
          try {
            await Future.wait([
              setWinnerDetails(playersList.length),
            ], eagerError: true, cleanUp: (value) {
              print('processed $value');
            });
          } catch (e, s) {
            Crashlytics.instance.recordError(e, s, context: 'as an example');
          }
        }
      });
    } catch (e, s) {
      Crashlytics.instance.recordError(e, s, context: 'as an example');
    }
  }

  Future gameCompleteDialog() async {
    if (!globals.gameCompleted) {
      watch.stop();
      if (timer2 != null) timer2.cancel();

      if (timer1 != null) timer1.cancel();
      gameCompletedCalledOnce = true;

      if (updateListener != null) updateListener.cancel();

      ////////////////////////////////////////////////////CLOSE PREVIOUS POPUP
      if (popupShown) Navigator.pop(context);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      ///////////////////////////////////RESET PREFERENCES
      // prefs.setString('targetTime', '');
      prefs.setBool('timerStarted', false);
      prefs.setString('puzzleID', '');
      prefs.setString('gamePlayed', 'yes');
      prefs.setInt('attemptsUsed', 0);
      prefs.setDouble('percentNotifier', 0.0);
      prefs.setInt('cluesFound', 0);
      prefs.setString('cluesList', '');
      prefs.setString('gameLoaded', '');

      await DefaultCacheManager().emptyCache();

      await FirebaseDatabase.instance
          .reference()
          .child('game-' + widget.data['gameID'])
          .child('players_count')
          .child(globals.userID)
          .update({'gamePlayed': true});

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
                                    margin: EdgeInsets.only(top: 8),

                                    child: AutoDirection(
                                      text: allTranslations
                                          .text('game_completed'),
                                      child: Text(
                                        allTranslations.text('game_completed'),
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
                                      onPressed: () {
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
                                        padding: EdgeInsets.only(
                                            left: 20, right: 20),
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
                                height:
                                    MediaQuery.of(context).size.height * 0.12,
                                width:
                                    MediaQuery.of(context).size.height * 0.12,
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
  }

  Future alreadyPlayedGameDialog() async {
    watch.stop();
    if (timer2 != null) timer2.cancel();

    if (timer1 != null) timer1.cancel();
    gameCompletedCalledOnce = true;

    if (updateListener != null) updateListener.cancel();

    ////////////////////////////////////////////////////CLOSE PREVIOUS POPUP
    if (popupShown) Navigator.pop(context);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    ///////////////////////////////////RESET PREFERENCES
    // prefs.setString('targetTime', '');
    prefs.setBool('timerStarted', false);
    prefs.setString('puzzleID', '');
    prefs.setString('gamePlayed', 'yes');
    prefs.setInt('attemptsUsed', 0);
    prefs.setDouble('percentNotifier', 0.0);
    prefs.setInt('cluesFound', 0);
    prefs.setString('cluesList', '');
    prefs.setString('gameLoaded', '');

    await DefaultCacheManager().emptyCache();

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
                                  margin: EdgeInsets.only(top: 8),

                                  child: AutoDirection(
                                    text:
                                        allTranslations.text('game_completed'),
                                    child: Text(
                                      allTranslations.text('game_completed'),
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
                                    onPressed: () {
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

  Future giffyDialog(String message) async {
    watch.stop();
    if (timer2 != null) timer2.cancel();

    if (timer1 != null) timer1.cancel();
    if (updateListener != null) updateListener.cancel();

    globals.gameEnded = true;
    globals.gameCompleted = true;
    gameCompletedCalledOnce = true;

    setState(() {
      calledOneTime = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    ///////////////////////////////////RESET PREFERENCES
    //prefs.setString('targetTime', '');
    prefs.setBool('timerStarted', false);
    prefs.setString('puzzleID', '');
    prefs.setString('gamePlayed', 'yes');
    prefs.setInt('attemptsUsed', 0);
    prefs.setDouble('percentNotifier', 0.0);
    prefs.setInt('cluesFound', 0);
    prefs.setString('cluesList', '');
    prefs.setString('gameLoaded', '');

    await DefaultCacheManager().emptyCache();

    await FirebaseDatabase.instance
        .reference()
        .child('game-' + widget.data['gameID'])
        .child('players_count')
        .child(globals.userID)
        .update({'gamePlayed': true});

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

  Future winnerDialog(winner) async {
    watch.stop();
    if (timer2 != null) timer2.cancel();

    if (timer1 != null) timer1.cancel();
    if (updateListener != null) updateListener.cancel();

    globals.gameEnded = true;
    globals.gameCompleted = true;
    ////////////////////////////////////////////////////CLOSE PREVIOUS POPUP
    if (popupShown) Navigator.pop(context);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    ///////////////////////////////////RESET PREFERENCES
    //prefs.setString('targetTime', '');
    prefs.setBool('timerStarted', false);
    prefs.setString('puzzleID', '');
    prefs.setString('gamePlayed', 'yes');
    prefs.setInt('attemptsUsed', 0);
    prefs.setDouble('percentNotifier', 0.0);
    prefs.setInt('cluesFound', 0);
    prefs.setString('cluesList', '');
    prefs.setString('gameLoaded', '');

    await DefaultCacheManager().emptyCache();

    await FirebaseDatabase.instance
        .reference()
        .child('game-' + widget.data['gameID'])
        .child('players_count')
        .child(globals.userID)
        .update({'gamePlayed': true});

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
                                  child: AutoDirection(
                                    text: allTranslations.text('you_loose'),
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
                                ),
                                Container(
                                  //color: Colors.blue[100],
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.only(top: 15),

                                  child: Text(
                                    winner,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  //color: Colors.blue[100],
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.only(top: 8),

                                  child: AutoDirection(
                                    text: allTranslations.text('player_win'),
                                    child: Text(
                                      allTranslations.text('player_win'),
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
                                    onPressed: () {
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

  Future gameEndDialog() async {
    watch.stop();
    if (timer2 != null) timer2.cancel();

    if (timer1 != null) timer1.cancel();

    if (popupShown) Navigator.pop(context);

    globals.gameEnded = true;
    globals.gameCompleted = true;

    setState(() {
      popupShown = true;
      gameEndAlreadyShown = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    ///////////////////////////////////RESET PREFERENCES
    //prefs.setString('targetTime', '');
    prefs.setBool('timerStarted', false);
    prefs.setString('puzzleID', '');
    prefs.setString('gamePlayed', 'yes');
    prefs.setString('gameLoaded', '');

    await DefaultCacheManager().emptyCache();

    await FirebaseDatabase.instance
        .reference()
        .child('game-' + widget.data['gameID'])
        .child('players_count')
        .child(globals.userID)
        .update({'gamePlayed': true});

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
                                    text:
                                        allTranslations.text('wait_for_winner'),
                                    child: Text(
                                      allTranslations.text('wait_for_winner'),
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
                                      if (updateListener != null)
                                        updateListener.cancel();

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

  Future gameCancelDialog() async {
    if (!globals.gameCompleted) {
      print('GAME END DIALOG CALLED');
      watch.stop();
      if (timer2 != null) timer2.cancel();

      if (timer1 != null) timer1.cancel();
      if (updateListener != null) updateListener.cancel();

      globals.gameEnded = true;
      setState(() {
        popupShown = true;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      ///////////////////////////////////RESET PREFERENCES
      prefs.setString('targetTime', '');
      prefs.setBool('timerStarted', false);
      prefs.setString('puzzleID', '');
      prefs.setString('gamePlayed', 'yes');
      prefs.setString('gameLoaded', '');

      await DefaultCacheManager().emptyCache();

      await FirebaseDatabase.instance
          .reference()
          .child('game-' + widget.data['gameID'])
          .child('players_count')
          .child(globals.userID)
          .update({'gamePlayed': true});

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
                                    margin: EdgeInsets.only(top: 15),

                                    child: AutoDirection(
                                      text: allTranslations.text('canceled2'),
                                      child: Text(
                                        allTranslations.text('canceled2'),
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
                                        padding: EdgeInsets.only(
                                            left: 20, right: 20),
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
                                height:
                                    MediaQuery.of(context).size.height * 0.12,
                                width:
                                    MediaQuery.of(context).size.height * 0.12,
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
  }

  Future setWinnerDetails(int length) async {
    length++;
    ///////////////////////////WINNER NODE EXIST OR NOT
    DataSnapshot data = await FirebaseDatabase.instance
        .reference()
        .child('game-' + widget.data['gameID'])
        .child('players')
        .once();
    //////////////////////////////PUSH NODE
    if (data.value == null) {
      FirebaseDatabase.instance
          .reference()
          .child('game-' + widget.data['gameID'])
          .child('players')
          .push();
      FirebaseDatabase.instance
          .reference()
          .child('game-' + widget.data['gameID'])
          .child('players')
          .child(globals.userID)
          .push();
      await FirebaseDatabase.instance
          .reference()
          .child('game-' + widget.data['gameID'])
          .child('players')
          .child(globals.userID)
          .set({
        'userID': globals.userID.toString(),
        'username': userName,
        'timestamp': finishDateTime,
        'pos': '1'
      });
    } else {
      FirebaseDatabase.instance
          .reference()
          .child('game-' + widget.data['gameID'])
          .child('players')
          .child(globals.userID)
          .push();
      await FirebaseDatabase.instance
          .reference()
          .child('game-' + widget.data['gameID'])
          .child('players')
          .child(globals.userID)
          .set({
        'userID': globals.userID.toString(),
        'username': userName,
        'timestamp': finishDateTime,
        'pos': length.toString()
      });
    }
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      meWinner = true;
    });
    globals.iWinGame = true;
    Future.wait([sendNotificationToServer(finishTime, globals.base64Image)]);
  }

  Future sendNotificationToServer(String finishTime, String imageStr) async {
    print('NOTIFY SERVER');
    Map userdata = {
      "game_id": widget.data['gameID'],
      "user_id": globals.userID,
      'screenshoot': imageStr,
      'time_finish': finishTime
    };
    http.Response response =
        await http.post(URLS.notifyServer, body: json.encode(userdata));

    print(userdata);
    print('IMAGE SENDING SERVER RESPONSE');

    print(response.body);
    if (response.statusCode == 200) {
      giffyDialog(
        allTranslations.text('you_win'),
      );
      print(response.body);
    } else {
      print('response code not 200');
    }
  }

  Widget errorGame() {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20),
      alignment: Alignment.center,
      //height: MediaQuery.of(context).size.height * 0.30,
      child: Container(
        alignment: Alignment.center,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
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
            child: Padding(
              padding: EdgeInsets.only(
                top: 5,
                left: 5,
                right: 5,
                bottom: 10,
              ),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.20,
                padding: EdgeInsets.symmetric(horizontal: 15),
                alignment: Alignment.center,
                child: SizedBox(
                  child: AutoDirection(
                    text: allTranslations.text('game_corrupt'),
                    child: Text(
                      allTranslations.text('game_corrupt'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'BreeSerif',
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget outFromGame() {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20),
      alignment: Alignment.center,
      //height: MediaQuery.of(context).size.height * 0.30,
      child: Container(
        alignment: Alignment.center,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
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
            child: Padding(
              padding: EdgeInsets.only(
                top: 5,
                left: 5,
                right: 5,
                bottom: 10,
              ),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.20,
                padding: EdgeInsets.symmetric(horizontal: 15),
                alignment: Alignment.center,
                child: SizedBox(
                  child: AutoDirection(
                    text: allTranslations.text('caught_cheating'),
                    child: Text(
                      allTranslations.text('caught_cheating'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'BreeSerif',
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return corruptGame
        ? errorGame()
        : enterBeforeTime
            ? outFromGame()
            : ModalProgressHUD(
                child: Container(
                  height: double.infinity,
                  width: double.infinity,
                  padding:
                      EdgeInsets.only(top: 30, bottom: 5, left: 0, right: 0),
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(left: 8, right: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                //color: Colors.blue[100],
                                alignment: Alignment.centerLeft,
                                child: GamePlayer(
                                  gameID: widget.data['gameID'],
                                  playersNotifier: playersCountNotifier,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                // color: Colors.blue[200],
                                alignment: Alignment.centerRight,
                                child: GameWinners(
                                  gameID: widget.data['gameID'],
                                  winnersNotifier: winnersCountNotifier,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                                  instance.onMultiTap =
                                      (correctNumberOfTouches) =>
                                          this.onTap(correctNumberOfTouches);
                                },
                              ),
                            },
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onPanStart: (details) async {
                                await Future.delayed(
                                    Duration(milliseconds: 500));
                                if (!multiTouch) {
                                  if (!isFinished) {
                                    final RenderBox box = _keyRed.currentContext
                                        .findRenderObject();
                                    final RenderBox boxYellow = _keyYellow
                                        .currentContext
                                        .findRenderObject();
                                    final result = BoxHitTestResult();
                                    Offset localRed = box
                                        .globalToLocal(details.globalPosition);
                                    Offset localYellow = boxYellow
                                        .globalToLocal(details.globalPosition);
                                    if (box.hitTest(result,
                                        position: localRed)) {
                                      var total =
                                          (markedPoints.length * xOffset) *
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
                                    final RenderBox box = _keyRed.currentContext
                                        .findRenderObject();
                                    final RenderBox boxYellow = _keyYellow
                                        .currentContext
                                        .findRenderObject();
                                    final result = BoxHitTestResult();
                                    Offset localRed = box
                                        .globalToLocal(details.globalPosition);
                                    Offset localYellow = boxYellow
                                        .globalToLocal(details.globalPosition);
                                    if (box.hitTest(result,
                                        position: localRed)) {
                                      var total =
                                          (markedPoints.length * xOffset) *
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
                                      height:
                                          MediaQuery.of(context).size.height,
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
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.70,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: CachedNetworkImage(
                                                  fit: BoxFit.fill,
                                                  imageUrl:
                                                      widget.data['image'],
                                                  placeholder: (context, url) =>
                                                      Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  ),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          Icon(Icons.error),
                                                ),
                                              ),
                                            )
                                          : CustomPaint(
                                              key: _keyRed,
                                              foregroundPainter:
                                                  ScratchCardPainter(
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
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.70,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: CachedNetworkImage(
                                                  fit: BoxFit.fill,
                                                  imageUrl:
                                                      widget.data['image'],
                                                  placeholder: (context, url) =>
                                                      Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  ),
                                                  errorWidget:
                                                      (context, url, error) =>
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
