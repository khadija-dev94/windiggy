import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
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
import 'package:percent_indicator/linear_percent_indicator.dart';
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

bool gameLoaded = false;
int singleCircleSize = 0;
int singleXGapSize = 0;
int singleYGapSize = 0;
bool setOneTime = false;
List<ui.Image> images;
int pos = null;
List<Color> colorsList = [Colors.blue, Colors.black, Colors.pink];
int currentIndex = null;
bool oneTime = false;
bool oneTimeFalse = false;
int currentTestPos = null;

Future<Map<String, dynamic>> fetchCountry(http.Client client) async {
  print('IMAGE DIFFERENCE GAME');

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String encryptGameID = prefs.getString('gameID');
  DateTime targetdateTime =
      globals.dateFormat.parse(prefs.getString('startTime'));
  String decryptedID = await GlobalsMethods.decryptGameID(
      targetdateTime.hour, targetdateTime.day, encryptGameID);

  List<String> images = new List();
  List<ui.Image> byteImages = new List();
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
      for (var data in snapshot.value['details']['images']) {
        images.add(data['url']);
        await DefaultCacheManager().getFile(data['url']);
      }
      byteImages = await _loadImage(images);
      ///////////////////////////WINNER NODE EXIST OR NOT
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
        'images': byteImages,
        'urls': images,
        'enterBefore': false,
        'nodeExist': true,
        'tabCount': snapshot.value['details']['count'],
      };
    } else
      return {'enterBefore': true, 'nodeExist': true};
  } else
    return {'enterBefore': false, 'nodeExist': false};
}

Future<List<ui.Image>> _loadImage(List<String> imagesList) async {
  List<ui.Image> imgs = new List();
  for (int i = 0; i < imagesList.length; i++) {
    Uint8List image = await _networkImageToByte(imagesList[i]);
    ui.Image image2 = await load(image);
    imgs.add(image2);
  }
  return imgs;
}

Future<Uint8List> _networkImageToByte(String imageStr) async {
  Uint8List byteImage = await networkImageToByte(imageStr);
  return byteImage;
}

Future<ui.Image> load(Uint8List img) async {
  final Completer<ui.Image> completer = new Completer();
  ui.decodeImageFromList(img, (ui.Image img) {
    return completer.complete(img);
  });
  return completer.future;
}

class BalloonsGameScreen extends StatefulWidget {
  static BalloonsGameScreenScreenState of(BuildContext context) => context
      .ancestorStateOfType(const TypeMatcher<BalloonsGameScreenScreenState>());
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return BalloonsGameScreenScreenState();
  }
}

bool matched = false;

class BalloonsGameScreenScreenState extends State<BalloonsGameScreen> {
  bool capPop;
  GlobalKey<BalloonViewState> _keyChild1 = GlobalKey();
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
    globals.BalloonsGlobalKey = _keyChild1;
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
                              ? new BalloonView(
                                  data: snapshot.data,
                                  key: _keyChild1,
                                )
                              : new Center(
                                  child: new CircularProgressIndicator());
                        },
                      )
                    : timerFinished
                        ? new BalloonView(
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

class BalloonView extends StatefulWidget {
  Map<String, dynamic> data;
  GlobalKey key;

  BalloonView({
    this.data,
    this.key,
  });
  static BalloonViewState of(BuildContext context) =>
      context.ancestorStateOfType(const TypeMatcher<BalloonViewState>());

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return BalloonViewState();
  }
}

class BalloonViewState extends State<BalloonView>
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
  double per;
  double value;

  bool isImageloaded = false;
  AnimationController _controller;
  List<Bubble> bubbles = new List();
  List<String> imagesStr = new List();
  String currentImge;

  Offset _pointerDownPosition;
  Future<List<ui.Image>> _imageLoader;
  double percent;

  ui.Image currentImg;
  Stopwatch targetWatch = new Stopwatch();
  Timer targetTimer;
  double percIncrement;
  bool decrease;
  double barHeight;
  bool barCmplete;
  bool multiTouch = false;

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
    percIncrement = 0.0;
    prizeTxt = '';
    gameLocked = false;
    popupShown = false;
    meWinner = false;
    calledOneTime = false;
    percent = 0.0;
    gameCompletedCalledOnce = false;
    gameEndAlreadyShown = false;
    decrease = false;
    barCmplete = false;
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
      images = widget.data['images'];
      imagesStr = widget.data['urls'];
      //_imageLoader = _loadImage(imagesStr);

      _controller = new AnimationController(
          duration: const Duration(seconds: 1000), vsync: this);
      _controller.addListener(() {
        if (bubbles.length != 0) updateBubblePosition();
      });

      _controller.forward();
      _controller.repeat();

      pool = Soundpool(streamType: StreamType.notification);

      currentIndex = 0;
      currentImge = imagesStr[0];

      targetWatch.start();
      /////////////////////////////////////////////////////////////////////TIMER FOR HOURS, MINUTES AND SECONDS
      targetTimer = new Timer.periodic(new Duration(seconds: 4), changeImage);
      registerListener();
    }
  }

  Future<List<ui.Image>> _loadImage(List<String> imagesList) async {
    List<ui.Image> imgs = new List();
    for (int i = 0; i < imagesList.length; i++) {
      Uint8List image = await _networkImageToByte(imagesList[i]);
      ui.Image image2 = await load(image);
      imgs.add(image2);
    }
    images = imgs;
    return imgs;
  }

  Future<Uint8List> _networkImageToByte(String imageStr) async {
    Uint8List byteImage = await networkImageToByte(imageStr);
    return byteImage;
  }

  Future<ui.Image> load(Uint8List img) async {
    final Completer<ui.Image> completer = new Completer();
    ui.decodeImageFromList(img, (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

  Future updateBubblePosition() async {
    bubbles.forEach((it) {
      it.updatePosition();
    });
    setState(() {});
  }

  Future changeImage(Timer timer) async {
    if (watch.isRunning) {
      int position = 0;
      position = Random().nextInt(imagesStr.length);

      setState(() {
        currentImge = imagesStr[position];
      });
      currentIndex = position;
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
    targetWatch.stop();
    if (timer2 != null) timer2.cancel();

    if (timer1 != null) timer1.cancel();
    if (targetTimer != null) targetTimer.cancel();

    singleCircleSize = 0;
    singleXGapSize = 0;
    singleYGapSize = 0;
    setOneTime = false;
    pos = null;
    colorsList = [Colors.blue, Colors.black, Colors.pink];
    currentIndex = null;
    oneTime = false;
    oneTimeFalse = false;
    currentTestPos = null;
    bubbles = new List();
    images = new List();
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
            } else
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

    int taps = int.parse(widget.data['tabCount']);
    double per = 100 / taps;
    percIncrement = per / 100;
    soundID =
        await rootBundle.load("assets/pop.mp3").then((ByteData soundData) {
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
    } else if (event.snapshot.key != 'players_counter') {
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
      Map map = event.snapshot.value;
      winnersCountNotifier.value = map.length;
    }
  }

  Future gameComplete() async {
    watch.stop();
    if (timer2 != null) timer2.cancel();

    if (timer1 != null) timer1.cancel();
    await Future.delayed(Duration(seconds: 1));
    try {
      await Future.wait([BalloonsGameScreen.of(context).takeScreenShot()])
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
        'username': globals.username,
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
        'username': globals.username,
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

  Future incrementBar() {
    setState(() {
      decrease = false;
      percent = percent + (barHeight * percIncrement);
    });
    print('PERCENT: $percent');
    if (percent.round() >= barHeight.round()) {
      setState(() {
        barCmplete = true;
      });
      gameComplete();
    }
  }

  Future decrementBar() {
    if (percent > barHeight * percIncrement) {
      setState(() {
        decrease = true;
        percent = percent - barHeight * percIncrement;
      });
      print('DECREASE PERCENT: $percent');
    }
  }

  void onTap(bool correctNumberOfTouches) async {
    print("Tapped with  finger(s): $correctNumberOfTouches");
    if (correctNumberOfTouches)
      multiTouch = false;
    else
      multiTouch = true;
  }

  @override
  Widget build(BuildContext context) {
    barHeight = MediaQuery.of(context).size.width * 0.70;

    // TODO: implement build
    return corruptGame
        ? errorGame()
        : enterBeforeTime
            ? outFromGame()
            : ModalProgressHUD(
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  padding:
                      EdgeInsets.only(top: 0, bottom: 0, left: 0, right: 0),
                  child: Stack(
                    children: <Widget>[
                      Container(
                        color: Colors.white,
                        height: MediaQuery.of(context).size.height,
                        //height: double.infinity,
                        width: MediaQuery.of(context).size.width,
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
                            onPanDown: (details) {
                              if (!multiTouch) {
                                if (!barCmplete)
                                  _pointerDownPosition = details.localPosition;
                              }
                            },
                            onPanUpdate: (details) async {
                              if (!multiTouch) {
                                if (!barCmplete) {
                                  if (details.localPosition.dy -
                                              _pointerDownPosition.dy >
                                          5 ||
                                      details.localPosition.dx -
                                              _pointerDownPosition.dx >
                                          5 ||
                                      _pointerDownPosition.dx -
                                              details.localPosition.dx >
                                          5 ||
                                      _pointerDownPosition.dy -
                                              details.localPosition.dy >
                                          5) {
                                    final RenderBox box =
                                        context.findRenderObject();
                                    final Offset localOffset = box
                                        .globalToLocal(details.localPosition);
                                    final result = BoxHitTestResult();
                                    if (box.hitTest(result,
                                        position: localOffset)) {
                                      if (pos != null) {
                                        if (currentTestPos == pos && !oneTime) {
                                          oneTime = true;
                                          setState(() {
                                            bubbles[pos].width = 0.0;
                                            bubbles[pos].height = 0.0;
                                            bubbles[pos].colour =
                                                Colors.transparent;
                                          });
                                          incrementBar();
                                          await pool.play(soundID);
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            },
                            child: CustomPaint(
                              foregroundPainter: BubblePainter(
                                  bubbles: bubbles,
                                  controller: _controller,
                                  onWrongTouch: () {
                                    decrementBar();
                                  }),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 20,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.05,
                          ),
                          color: Colors.black,
                          // height: 155,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
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
                                        padding:
                                            EdgeInsets.only(top: 5, right: 15),
                                        alignment: Alignment.bottomCenter,
                                        child: Text(
                                          prizeTxt,
                                          maxLines: 2,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).accentColor,
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
                                        padding:
                                            EdgeInsets.only(left: 15, top: 5),
                                        // color: Colors.blue[200],
                                        alignment: Alignment.bottomCenter,
                                        child: SizedBox(
                                          child: Text(
                                            globals.username,
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color:
                                                  Theme.of(context).accentColor,
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
                                // color: Colors.yellow,
                                width: double.infinity,
                                alignment: Alignment.center,
                                height: 70,
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 0),
                                      // width: 100,
                                      alignment: Alignment.center,
                                      child: CachedNetworkImage(
                                        fit: BoxFit.fill,
                                        imageUrl: currentImge,
                                        placeholder: (context, url) => Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        child: Container(
                                          alignment: Alignment.centerRight,
                                          //padding: EdgeInsets.only(right: 15),
                                          //color: Colors.blue[100],
                                          child: Stack(
                                            children: <Widget>[
                                              Container(
                                                color: Colors.grey,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.05,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.70,
                                              ),
                                              Positioned(
                                                bottom: 0,
                                                child: Container(
                                                  // color: Colors.white,

                                                  child: AnimatedContainer(
                                                    duration: Duration(
                                                        milliseconds: 400),
                                                    curve: decrease
                                                        ? Curves.linear
                                                        : Curves.elasticOut,
                                                    width: percent,
                                                    constraints: BoxConstraints(
                                                        minHeight: 10),
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.05,
                                                    color: Theme.of(context)
                                                        .accentColor,
                                                    child: Container(),
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
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                inAsyncCall: isLoading,
              );
  }
}

class BubblePainter extends CustomPainter {
  List<Bubble> bubbles;
  AnimationController controller;
  double screenHeight;
  int rows = 0;
  int on = 0;
  int currentNoColumns = 0;
  double totalHeight = 0.0;
  double x = 0;
  double y = 0;
  VoidCallback onWrongTouch;

  BubblePainter({this.bubbles, this.controller, this.onWrongTouch});

  @override
  void paint(Canvas canvas, Size canvasSize) {
    if (!setOneTime) {
      setOneTime = true;
      Calculation(canvasSize);
      totalHeight = canvasSize.height;
      var paint = new Paint();
      paint.color = Colors.white;
      int previousY = singleYGapSize;
      int previousX = 0;
      int bubblePos = 0;
      for (int row = 0; row < rows; row++) {
        previousX = 0;
        if (on == 0) {
          currentNoColumns = 6;
          previousX = 0;
        } else {
          currentNoColumns = 5;
          previousX = singleXGapSize;
        }
        int imagePos = 0;
        for (int col = 0; col < currentNoColumns; col++) {
          int radius = (singleCircleSize / 2).round();

          // print('PREV X: $previousX');
          Offset center = Offset(
              (radius + previousX).toDouble(), (radius + previousY).toDouble());
          x = (radius + previousX).toDouble();
          y = (radius + previousY).toDouble();
          // canvas.drawCircle(center, radius.toDouble(), paint);
          previousX = previousX + singleCircleSize + singleXGapSize;
          int colIndex = Random().nextInt(4);

          bubbles.add(Bubble(
              center.dx,
              center.dy,
              row,
              totalHeight,
              center,
              bubblePos,
              colIndex,
              colorsList[0],
              images[imagePos],
              images[imagePos].width.toDouble(),
              images[imagePos].height.toDouble()));
          bubblePos++;
          if (imagePos <= images.length - 2)
            imagePos++;
          else
            imagePos = 0;
        }
        previousY = previousY + singleCircleSize + singleYGapSize;
        if (on == 0)
          on = 1;
        else
          on = 0;
      }
    }

    bubbles.forEach((it) => it.draw(
        canvas,
        canvasSize,
        it.centerPoint.dx,
        it.centerPoint.dy,
        it.colour,
        it.index,
        it.image,
        it.image.width.toDouble(),
        it.image.height.toDouble()));
  }

  Future Calculation(Size canvasSize) async {
    singleCircleSize = (canvasSize.width * 0.1).round();
    int totalSpaceForBoxes = 5 * singleCircleSize;
    int remainingSpace = canvasSize.width.round() - totalSpaceForBoxes;
    singleXGapSize = (remainingSpace / 4).round();
    singleYGapSize = (singleXGapSize * 1.5).round();

    rows = ((canvasSize.height.round()) /
            (singleCircleSize + ((singleXGapSize).round())))
        .round();
    print('NO OF ROWS: $rows');
  }

  @override
  bool hitTest(Offset position) {
    Path path;

    for (int i = 0; i < bubbles.length; i++) {
      path = Path();
      path.addRect(
        Rect.fromCenter(
          center: bubbles[i].centerPoint,
          width: singleCircleSize.toDouble(),
          height: singleCircleSize.toDouble(),
        ),
      );
      path.close();

      oneTimeFalse = false;
      if (path.contains(position) && bubbles[i].index == currentIndex) {
        currentTestPos = i;
        if (i != pos) {
          oneTime = false;
          pos = i;
          print('POSITION: $pos');
          return true;
        }
      } else if (path.contains(position) && bubbles[i].index != currentIndex) {
        if (!oneTimeFalse) {
          oneTimeFalse = true;
          print('WRONG TOUCH: $pos');
          onWrongTouch();
        }
        return false;
      }
    }
    return false;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class Bubble {
  Color colour;
  int row;
  double totalheight;
  double x;
  double y;
  Offset centerPoint;
  ui.Image image;
  double height;
  double width;
  int itemPos;
  double speed;
  double direction;
  var paint = new Paint();
  int index;

  Bubble(double x, double y, int row, double height, Offset center, int pos,
      int i, Color colour, ui.Image img, double w, double h) {
    this.colour = colour;
    this.row = row;
    this.totalheight = height;
    this.centerPoint = center;

    this.itemPos = pos;
    this.speed = 2.3;
    this.direction = 270;
    this.index = i;
    this.image = img;
    this.width = w;
    this.height = h;
  }

  draw(Canvas canvas, Size canvasSize, double xPoint, double yPoint, Color col,
      int i, ui.Image img, double w, double h) {
    this.y = yPoint;
    this.x = xPoint;
    this.colour = col;

    this.index = i;
    paint.color = colour;

    this.centerPoint = Offset(xPoint, yPoint);
    this.image = img;
    this.width = w;
    this.height = h;
    paint.color = colour;
    var areaRect =
        Rect.fromCenter(center: centerPoint, height: height, width: width);
    var size = Size(width, height);
    var sizes = applyBoxFit(BoxFit.scaleDown, size, canvasSize);
    var inputSubrect =
        Alignment.center.inscribe(sizes.source, Offset.zero & size);
    var outputSubrect = Alignment.center.inscribe(sizes.destination, areaRect);
    canvas.drawImageRect(image, inputSubrect, outputSubrect, paint);
    //double radius = singleCircleSize / 2;
    //canvas.drawCircle(centerPoint, radius, paint);
  }

  var a = 180 - (270 + 90);
  updatePosition() {
    y -= speed * sin(a) / sin(speed);
    centerPoint = Offset(x, y);
    if (y == 0 || (y >= -singleYGapSize && y < 0)) {
      y = singleYGapSize + totalheight + totalheight * 0.20;
      centerPoint = Offset(x, y);
      colour = colorsList[0];
      int colIndex = Random().nextInt(images.length);
      image = images[colIndex];
      index = colIndex;
      height = image.height.toDouble();
      width = image.width.toDouble();
    }
  }
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
