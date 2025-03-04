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

bool gameLoaded = false;

Future<Map<String, dynamic>> fetchCountry(http.Client client) async {
  print('IMAGE DIFFERENCE GAME');
  DataSnapshot data = null;
  List<Level> levels = new List();

  data = await FirebaseDatabase.instance
      .reference()
      .child('daily-list')
      .child(globals.dailyContestGameID)
      .once();
  if (!gameLoaded) {
    for (var data in data.value['game-data']['stages']) {
      levels.add(Level(
        duration: int.parse(data['speed']),
        tolerence: int.parse(data['tolerence']),
        image: data['picture'],
      ));
    }
  } else {
    for (var data in data.value['game-data']['stages']) {
      levels.add(Level(
        duration: int.parse(data['speed']),
        tolerence: int.parse(data['tolerence']),
        image: data['picture'],
      ));
    }
  }

  ui.Image _imageLoader;
  Uint8List image;
  image = await _networkImageToByte(levels[0].image);
  _imageLoader = await loadImage(image);
  return {
    'gameData': levels,
    'firstImage': _imageLoader,
  };
}

Future<Uint8List> _networkImageToByte(String imageStr) async {
  Uint8List byteImage = await networkImageToByte(imageStr);
  return byteImage;
}

Future<ui.Image> loadImage(Uint8List img) async {
  final Completer<ui.Image> completer = new Completer();
  ui.decodeImageFromList(img, (ui.Image img) {
    return completer.complete(img);
  });
  return completer.future;
}

class ShadowContestGameScreen extends StatefulWidget {
  static ShadowScreenState of(BuildContext context) =>
      context.ancestorStateOfType(const TypeMatcher<ShadowScreenState>());
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ShadowScreenState();
  }
}

bool matched = false;

class ShadowScreenState extends State<ShadowContestGameScreen> {
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
                          ? new ShadowView(
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

class ShadowView extends StatefulWidget {
  Map<String, dynamic> data;

  ShadowView({this.data});
  static ShadowViewState of(BuildContext context) =>
      context.ancestorStateOfType(const TypeMatcher<ShadowViewState>());

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ShadowViewState();
  }
}

class ShadowViewState extends State<ShadowView>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  bool isLoading;
  Animation<double> _contentAnimation;
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
  double per;
  Animation<double> animation;
  Animation<double> animation2;
  AnimationController animationController;
  double value;
  int level;
  int duration;
  ui.Image image;
  bool isImageloaded = false;
  List<Level> levels = new List();
  List<ui.Image> images = new List();
  ui.Image currentImg;
  String userName;
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
    gameID = '';
    level = 0;
    value = null;
    isLoading = false;
    levels = widget.data['gameData'];
    duration = levels[0].duration;
    currentImg = widget.data['firstImage'];
    value = null;
    animationController =
        AnimationController(vsync: this, duration: Duration(seconds: duration));

    animation = Tween<double>(begin: -350, end: 600).animate(
      CurvedAnimation(
          parent: animationController,
          curve: Interval(
            0.0,
            1.0,
            curve: Curves.linear,
          )),
    )..addListener(() => setState(() {
          value = animation.value;
        }));

    registerListener();
  }

  Future<Uint8List> _networkImageToByte(String imageStr) async {
    Uint8List byteImage = await networkImageToByte(imageStr);
    return byteImage;
  }

  Future<ui.Image> loadImage(Uint8List img) async {
    final Completer<ui.Image> completer = new Completer();
    ui.decodeImageFromList(img, (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    if (animationController != null) animationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    watch.stop();
    if (timer2 != null) timer2.cancel();

    if (timer1 != null) timer1.cancel();
  }

  Future registerListener() async {
    setState(() {
      isLoading = true;
    });

    animationController.forward();
    animationController.repeat();
    await getUsername();
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
    print('DATA TO SEND: $userdata');
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
      await FirebaseDatabase.instance
          .reference()
          .child('daily-list')
          .child(globals.dailyContestGameID)
          .update({'winner': userName, 'winner_id': globals.userID}).then(
              (value) {
        Future.wait([
          sendNotificationToServer(gameID, finishTime, globals.base64Image)
        ]).catchError((error) {
          print('SOMETHING WENT WRON');
          Crashlytics.instance.log(
              'MCQ IMAGE SENT TO SERVER EXCEPTION IN setWinnerDetails METHOD: $error');
          Crashlytics.instance.setString('USER ID', globals.userID);
          Crashlytics.instance.setString('USERNAME', globals.username);
        });
      });
    } else {
      setState(() {
        meWinner = false;
        isLoading = false;
      });

      gameEndDialog(playersList[0]['timeStamp']);
    }
  }

  Future wrongTouchDialog() async {
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
                                    'OOPPS...!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Theme.of(context).accentColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
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
                                      Navigator.of(context).pop();
                                      animationController.reset();

                                      animationController.forward();
                                      animationController.repeat();
                                    },
                                    child: Padding(
                                      padding:
                                          EdgeInsets.only(left: 20, right: 20),
                                      child: Text(
                                        'TRY AGAIN',
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

  Future nextLevelDialog() async {
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
                                    'GOOD JOB!!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Theme.of(context).accentColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
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
                                      changeLevel();
                                      Navigator.of(context).pop();
                                    },
                                    child: Padding(
                                      padding:
                                          EdgeInsets.only(left: 20, right: 20),
                                      child: Text(
                                        'NEXT LEVEL',
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

  Future changeLevel() async {
    setState(() {
      isLoading = true;
      level++;
    });
    duration = levels[level].duration;
    print('IMAGE URL: ${levels[level].image}');
    ui.Image _imageLoader;
    Uint8List image;
    image = await _networkImageToByte(levels[level].image);
    _imageLoader = await loadImage(image);
    images.add(_imageLoader);
    setState(() {
      currentImg = _imageLoader;
    });

    animationController.duration = Duration(seconds: duration);
    animationController.reset();
    setState(() {
      isLoading = false;
    });
    animationController.forward();
    animationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
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
              margin: EdgeInsets.only(top: 30),
              child: Text(
                'Level ' + (level + 1).toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 37,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 5),
              child: Text(
                '(margin of error ' + levels[0].tolerence.toString() + ')',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                //color: Colors.blue[100],
                margin: EdgeInsets.only(top: 10),
                child: Container(
                  //margin: EdgeInsets.only(top: 20),
                  //  color: Colors.blue[200],
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      Container(
                        //alignment: Alignment.center,
                        child: BottomImageWidget(image: currentImg),
                      ),
                      GestureDetector(
                        onTapDown: (TapDownDetails details) async {
                          print('CALLED');
                          animationController.stop();
                          final RenderBox box = context.findRenderObject();
                          final Offset localOffset =
                              box.globalToLocal(details.globalPosition);
                          final result = BoxHitTestResult();
                          if (box.hitTest(result, position: localOffset)) {
                            if (matched) {
                              if ((level + 1) < levels.length) {
                                nextLevelDialog();
                              } else
                                gameWon();
                            } else
                              wrongTouchDialog();
                          }
                        },
                        child: TopImageWidget(
                          image: currentImg,
                          tolerence: levels[level].tolerence,
                          AnimValue: animation.value,
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
      inAsyncCall: isLoading,
    );
  }

  Future gameWon() async {
    watch.stop();
    if (timer2 != null) timer2.cancel();

    if (timer1 != null) timer1.cancel();
    await Future.delayed(Duration(seconds: 1));
    try {
      await Future.wait([ShadowContestGameScreen.of(context).takeScreenShot()])
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
      });
    } catch (e, s) {
      Crashlytics.instance.recordError(e, s, context: 'as an example');
    }
  }
}

double leftSide;
double currentLeft;

class CurvePainter extends CustomPainter {
  final ui.Image image;

  /// Determine how the image should fit the scratch area
  final BoxFit imageFit;

  CurvePainter({this.image, this.imageFit});

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    final paint = Paint();
    paint.color = Colors.orange;

    var areaRect = Rect.fromCenter(
        center: Offset(size.width / 2, (size.height / 2)),
        height: image.height.toDouble(),
        width: image.width.toDouble());
    var imageSize = Size(image.width.toDouble(), image.height.toDouble());
    var sizes = applyBoxFit(BoxFit.scaleDown, imageSize, size);
    var inputSubrect =
        Alignment.center.inscribe(sizes.source, Offset.zero & imageSize);
    var outputSubrect = Alignment.center.inscribe(sizes.destination, areaRect);
    leftSide = areaRect.left;

    canvas.drawImageRect(image, inputSubrect, outputSubrect, Paint());
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}

class CurvePainter2 extends CustomPainter {
  final double animValue;
  final ui.Image image;
  final BoxFit imageFit;
  int tol;

  CurvePainter2({this.image, this.animValue, this.tol, this.imageFit});

  @override
  void paint(Canvas canvas, Size size) async {
    // TODO: implement paint
    final paint = Paint();
    paint.color = Colors.blue;

    //canvas.drawImage(image.width, new Offset(animValue, 0.0), new Paint());

    var areaRect = Rect.fromCenter(
        center: Offset(animValue, (size.height / 2)),
        height: image.height.toDouble(),
        width: image.width.toDouble());
    var imageSize = Size(image.width.toDouble(), image.height.toDouble());
    var sizes = applyBoxFit(BoxFit.scaleDown, imageSize, size);
    var inputSubrect =
        Alignment.center.inscribe(sizes.source, Offset.zero & imageSize);
    var outputSubrect = Alignment.center.inscribe(sizes.destination, areaRect);
    canvas.drawImageRect(image, inputSubrect, outputSubrect, Paint());

    currentLeft = areaRect.left;
  }

  @override
  bool hitTest(Offset position) {
    Path path;
    path = Path();

    Rect rect = Rect.fromCenter(center: position, height: 230, width: 100);
    path.addRect(Rect.fromCenter(center: position, height: 230, width: 100));

    path.close();

    print('CURRENT LEFT : ${currentLeft}');
    print(' LEFT : $leftSide');
    print(' TOLERENCE : $tol');

    if (!currentLeft.isNegative) {
      if (currentLeft >= (leftSide - tol) && currentLeft <= (leftSide + tol)) {
        print('TRUE');
        matched = true;
        return true;
      } else
        print('FALSE');
    }
    matched = false;
    return true;
  }

  @override
  bool shouldRepaint(CurvePainter2 oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}

class BottomImageWidget extends StatefulWidget {
  ui.Image image;

  BottomImageWidget({this.image});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return BottomImageState();
  }
}

class BottomImageState extends State<BottomImageWidget> {
  Future<ui.Image> _imageLoader;
  Uint8List image;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future<Uint8List> _networkImageToByte(String imageStr) async {
    Uint8List byteImage = await networkImageToByte(imageStr);
    return byteImage;
  }

  Future<ui.Image> loadImage(Uint8List img) async {
    final Completer<ui.Image> completer = new Completer();
    ui.decodeImageFromList(img, (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return CustomPaint(
      painter: new CurvePainter(image: widget.image, imageFit: BoxFit.cover),
      child: Container(
        height: 230,
        width: 100,
      ),
      // child: Container(color: Colors.yellow,),
    );
  }
}

class TopImageWidget extends StatefulWidget {
  ui.Image image;
  double AnimValue;
  int tolerence;

  TopImageWidget({this.image, this.tolerence, this.AnimValue});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return TopImageState();
  }
}

class TopImageState extends State<TopImageWidget> {
  Future<ui.Image> _imageLoader;
  Uint8List image;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future<Uint8List> _networkImageToByte(String imageStr) async {
    Uint8List byteImage = await networkImageToByte(imageStr);
    return byteImage;
  }

  Future<ui.Image> loadImage(Uint8List img) async {
    final Completer<ui.Image> completer = new Completer();
    ui.decodeImageFromList(img, (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return CustomPaint(
      painter: new CurvePainter2(
          image: widget.image,
          animValue: widget.AnimValue,
          tol: widget.tolerence,
          imageFit: BoxFit.cover),
      // child: Container(color: Colors.yellow,),
    );
  }
}
