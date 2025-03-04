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
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:network_image_to_byte/network_image_to_byte.dart';
import 'package:win_diggy/Models/Center.dart';
import 'package:win_diggy/Models/GlobalMethods.dart';
import 'package:win_diggy/Models/JigsawPuzzleModels/GameEngine.dart';
import 'package:win_diggy/Models/JigsawPuzzleModels/ImageNode.dart';
import 'package:win_diggy/Models/JigsawPuzzleModels/PuzzleMagic.dart';
import 'package:win_diggy/Models/JigsawPuzzleModels/GamePainter2.dart';
import 'package:win_diggy/Models/Player.dart';
import 'package:win_diggy/Models/URLS.dart';
import 'package:win_diggy/Widgets/NetworkWidget.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:win_diggy/Globals.dart' as globals;
import 'package:win_diggy/Models/Box.dart';
import 'package:win_diggy/Models/GlobalTranslations.dart';
import 'package:win_diggy/CustomIcons/puzzle_icons_icons.dart';
import 'package:win_diggy/Widgets/CurrentPlayers.dart';
import 'package:win_diggy/Globals.dart' as globals;
import 'dart:ui' as ui;

bool gameLoaded = false;

Future<Map<String, dynamic>> fetchCountry(http.Client client) async {
  print('IMAGE DIFFERENCE GAME');
  List<int> posList = new List();

  DataSnapshot data =
      await FirebaseDatabase.instance.reference().child('24hrcontest').once();
  if (data.value != null) {
    for (var pos in data.value['game-data']['Details']['Start']) {
      posList.add(int.parse(pos));
    }
    await Future.wait([downloadImage(data)]);
    await DefaultCacheManager()
        .getFile(data.value['game-data']['Details']['ImageLink']);
    return {
      'image': data.value['game-data']['Details']['ImageLink'],
      'byteImage': _imageLoader,
      'position': posList,
      'size': int.parse(data.value['game-data']['Details']['size'])
    };
  }
  return {};
}

ui.Image _imageLoader;
Future downloadImage(DataSnapshot data) async {
  Uint8List image;
  image = await _networkImageToByte(
      data.value['game-data']['Details']['ImageLink']);
  _imageLoader = await loadImage(image);
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

class JigsawPuzzleContestScreen extends StatefulWidget {
  static JigsawPuzzleScreenState of(BuildContext context) =>
      context.ancestorStateOfType(const TypeMatcher<JigsawPuzzleScreenState>());
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return JigsawPuzzleScreenState();
  }
}

class JigsawPuzzleScreenState extends State<JigsawPuzzleContestScreen> {
  bool capPop;
  ScreenshotController screenshotController = ScreenshotController();
  bool timerFinished;
  Stopwatch watch = new Stopwatch();
  Timer timer;
  Duration duration = new Duration(seconds: 11);
  String seconds;
  bool gameLoaded;
  Map<String, dynamic> fbData;

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
                          ? new JigsawView(
                              MediaQuery.of(context).size,
                              snapshot.data['byteImage'],
                              snapshot.data['size'],
                              snapshot.data,
                              snapshot.data['position'],
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
                                                      '/24hrContestScreen');
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

enum Direction { none, left, right, top, bottom }
enum GameState { loading, play, complete }

class JigsawView extends StatefulWidget {
  final Size size;
  final ui.Image image;
  final int level;
  Map<String, dynamic> data;
  List<int> pos;
  JigsawView(this.size, this.image, this.level, this.data, this.pos);

  static JigsawViewState of(BuildContext context) =>
      context.ancestorStateOfType(const TypeMatcher<JigsawViewState>());

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return JigsawViewState(size, image, level, pos);
  }
}

class JigsawViewState extends State<JigsawView>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  bool isLoading;
  String hours, minutes, seconds, milliseconds;
  var finishTime;
  bool meWinner;
  bool calledOneTime;
  var diffFound;
  bool popupShown;
  String prizeTxt;
  int finishDateTime;
  bool gameLocked;
  bool gameEndAlreadyShown;
  bool gameCompletedCalledOnce;
  Stopwatch watch = new Stopwatch();
  Timer timer1;
  Timer timer2;
  Duration durationd;
  Duration duration2;
  bool alreayAddedToList;
  bool gamePlayed;
  final Size size;
  var image;
  PuzzleMagic puzzleMagic;
  List<ImageNode> nodes;
  Animation<int> alpha;
  AnimationController controller;
  Map<int, ImageNode> nodeMap = Map();
  int level;
  ui.Image byteImage;
  ImageNode hitNode;
  double downX, downY, newX, newY;
  int emptyIndex;
  Direction direction;
  bool needdraw = true;
  List<ImageNode> hitNodeList = [];
  List<int> posList;
  bool enterBeforeTime;
  bool corruptGame;
  String userName;
  GameState gameState = GameState.loading;
  Animation<double> _contentAnimation;
  AnimationController _controller;

  ValueNotifier<int> playersCountNotifier = new ValueNotifier<int>(0);
  String gameID;

  JigsawViewState(this.size, this.byteImage, this.level, this.posList) {
    puzzleMagic = PuzzleMagic();
    emptyIndex = level * level - 1;

    puzzleMagic.init(byteImage, size, level).then((val) async {
      setState(() {
        nodes = puzzleMagic.doTask();
        GameEngine.makeRandom(nodes, posList);
        setState(() {
          gameState = GameState.play;
        });
        showStartAnimation();
      });
    });
  }
  int count;

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
    isLoading = false;
    gameEndAlreadyShown = false;
    userName = '';
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _controller.forward();
    _contentAnimation = Tween(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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

  Future pauseTimer() async {}

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
        .child('24hrcontest')
        .child('players_visit')
        .once();
    if (snapshot.value != null) {
      await FirebaseDatabase.instance
          .reference()
          .child('24hrcontest')
          .child('players_visit')
          .push();
      await FirebaseDatabase.instance
          .reference()
          .child('24hrcontest')
          .child('players_visit')
        ..child(globals.userID).push();
      await FirebaseDatabase.instance
          .reference()
          .child('24hrcontest')
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
          .child('24hrcontest')
          .child('players_visit')
          .push();
      await FirebaseDatabase.instance
          .reference()
          .child('24hrcontest')
          .child('players_visit')
        ..child(globals.userID).push();
      await FirebaseDatabase.instance
          .reference()
          .child('24hrcontest')
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

    await getUsername();
  }

  //////////////////////////////////////////////////////////////////GET USERNAME AND CHECK FB FOR FIRST LOAD
  Future getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userName = prefs.getString('username');

    ///////////////////////////WINNER NODE EXIST OR NOT
    DataSnapshot data;
    data =
        await FirebaseDatabase.instance.reference().child('24hrcontest').once();

    setState(() {
      if (allTranslations.currentLanguage == 'ur')
        prizeTxt = data.value['prize-urdu'];
      else
        prizeTxt = data.value['prize'];
    });

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
                                          context, '/24hrContestScreen');
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

  Future gameComplete() async {
    watch.stop();
    if (timer2 != null) timer2.cancel();

    if (timer1 != null) timer1.cancel();
    await Future.delayed(Duration(seconds: 1));
    try {
      await Future.wait(
              [JigsawPuzzleContestScreen.of(context).takeScreenShot()])
          .then((value) async {
        setState(() {
          isLoading = true;
        });

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
        .child('24hrcontest')
        .child('players')
        .once();
    //////////////////////////////PUSH NODE
    if (data.value == null) {
      FirebaseDatabase.instance
          .reference()
          .child('24hrcontest')
          .child('players')
          .push();
      FirebaseDatabase.instance
          .reference()
          .child('24hrcontest')
          .child('players')
          .child(globals.userID)
          .push();
      await FirebaseDatabase.instance
          .reference()
          .child('24hrcontest')
          .child('players')
          .child(globals.userID)
          .set({
        'userID': globals.userID.toString(),
        'username': globals.username,
        'timeStampInMilli': finishDateTime,
        'timeStamp': finishTime,
        'count': count,
        'appVer': globals.currentAppVersion,
      });
    } else {
      FirebaseDatabase.instance
          .reference()
          .child('24hrcontest')
          .child('players')
          .child(globals.userID)
          .push();
      await FirebaseDatabase.instance
          .reference()
          .child('24hrcontest')
          .child('players')
          .child(globals.userID)
          .set({
        'userID': globals.userID.toString(),
        'username': globals.username,
        'timeStampInMilli': finishDateTime,
        'timeStamp': finishTime,
        'count': count,
        'appVer': globals.currentAppVersion,
      });
    }
    await Future.delayed(Duration(seconds: 1));
    DataSnapshot playerData = await FirebaseDatabase.instance
        .reference()
        .child('24hrcontest')
        .child('players')
        .once();

    Map<dynamic, dynamic> map = playerData.value;
    List<dynamic> playersList = new List();
    map.forEach((key, values) {
      playersList.add(values);
    });

    playersList
        .sort((a, b) => a['timeStampInMilli'].compareTo(b['timeStampInMilli']));
    print('SORTED PLAYER LIST: $playersList');

    if (playersList[0]['userID'] == globals.userID) {
      try {
        await FirebaseDatabase.instance
            .reference()
            .child('24hrcontest')
            .update({
          'winner': globals.username,
          'winner_id': globals.userID
        }).then((value) {
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
      } catch (e, s) {
        Crashlytics.instance.recordError(e, s, context: 'as an example');
      }
    } else {
      setState(() {
        meWinner = false;
        isLoading = false;
      });
      gameEndDialog(playersList[0]['tissueCount'].toString());
    }
  }

  Widget buildPuzzle() {
    if (gameState == GameState.loading) {
      return Center(
        child: Text('Loading'),
      );
    } else if (gameState == GameState.complete) {
      gameComplete();
    } else {
      return GestureDetector(
        child: CustomPaint(
            painter: GamePainter2(nodes, level, hitNode, hitNodeList, direction,
                downX, downY, newX, newY, needdraw),
            size: Size.infinite),
        onPanDown: onPanDown,
        onPanUpdate: onPanUpdate,
        onPanEnd: onPanUp,
      );
    }
  }

  void showStartAnimation() {
    needdraw = true;
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    alpha = IntTween(begin: 0, end: 100).animate(controller);
    nodes.forEach((node) {
      nodeMap[node.curIndex] = node;

      Rect rect = node.rect;
      Rect dstRect = puzzleMagic.getOkRectF(
          node.curIndex % level, (node.curIndex / level).floor());

      final double deltX = dstRect.left - rect.left;
      final double deltY = dstRect.top - rect.top;

      final double oldX = rect.left;
      final double oldY = rect.top;

      alpha.addListener(() {
        double oldNewX2 = alpha.value * deltX / 100;
        double oldNewY2 = alpha.value * deltY / 100;
        setState(() {
          node.rect = Rect.fromLTWH(
              oldX + oldNewX2, oldY + oldNewY2, rect.width, rect.height);
        });
      });
    });
    alpha.addStatusListener((AnimationStatus val) {
      if (val == AnimationStatus.completed) {
        needdraw = false;
      }
    });
    controller.forward();
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
              padding: EdgeInsets.symmetric(horizontal: 20),
              margin: EdgeInsets.only(top: 20),
              height: MediaQuery.of(context).size.height * 0.15,
              child: CachedNetworkImage(
                fit: BoxFit.fill,
                imageUrl: widget.data['image'],
                placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
            Expanded(
              child: Container(
                //color: Colors.blue[400],
                alignment: Alignment.center,
                child: Container(
                  margin: EdgeInsets.only(top: 10),
                  height: MediaQuery.of(context).size.height * 0.63,
                  alignment: Alignment.center,
                  //  color: Colors.blue[100],
                  //margin: EdgeInsets.only(top: 10),
                  child: GestureDetector(
                    child: CustomPaint(
                        painter: GamePainter2(
                            nodes,
                            level,
                            hitNode,
                            hitNodeList,
                            direction,
                            downX,
                            downY,
                            newX,
                            newY,
                            needdraw),
                        size: Size.infinite),
                    onPanDown: onPanDown,
                    onPanUpdate: onPanUpdate,
                    onPanEnd: onPanUp,
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

  void onPanDown(DragDownDetails details) {
    if (controller != null && controller.isAnimating) {
      return;
    }

    needdraw = true;
    RenderBox referenceBox = context.findRenderObject();
    Offset localPosition = referenceBox.globalToLocal(details.localPosition);
    for (int i = 0; i < nodes.length; i++) {
      ImageNode node = nodes[i];
      if (node.rect.contains(localPosition)) {
        hitNode = node;
        direction = isBetween(hitNode, emptyIndex);
        if (direction != Direction.none) {
          newX = downX = localPosition.dx;
          newY = downY = localPosition.dy;

          nodes.remove(hitNode);
          nodes.add(hitNode);
        }
        setState(() {});
        break;
      }
    }
  }

  void onPanUpdate(DragUpdateDetails details) {
    if (hitNode == null) {
      return;
    }
    RenderBox referenceBox = context.findRenderObject();
    Offset localPosition = referenceBox.globalToLocal(details.localPosition);
    newX = localPosition.dx;
    newY = localPosition.dy;
    if (direction == Direction.top) {
      newY = min(downY, max(newY, downY - hitNode.rect.width));
    } else if (direction == Direction.bottom) {
      newY = max(downY, min(newY, downY + hitNode.rect.width));
    } else if (direction == Direction.left) {
      newX = min(downX, max(newX, downX - hitNode.rect.width));
    } else if (direction == Direction.right) {
      newX = max(downX, min(newX, downX + hitNode.rect.width));
    }

    setState(() {});
  }

  void onPanUp(DragEndDetails details) {
    if (hitNode == null) {
      return;
    }
    needdraw = false;
    if (direction == Direction.top) {
      if (-(newY - downY) > hitNode.rect.width / 2) {
        swapEmpty();
      }
    } else if (direction == Direction.bottom) {
      if (newY - downY > hitNode.rect.width / 2) {
        swapEmpty();
      }
    } else if (direction == Direction.left) {
      if (-(newX - downX) > hitNode.rect.width / 2) {
        swapEmpty();
      }
    } else if (direction == Direction.right) {
      if (newX - downX > hitNode.rect.width / 2) {
        swapEmpty();
      }
    }

    hitNodeList.clear();
    hitNode = null;

    var isComplete = true;
    nodes.forEach((node) {
      if (node.curIndex != node.index) {
        isComplete = false;
      }
    });
    if (isComplete) {
      gameComplete();
    }

    setState(() {});
  }

  Direction isBetween(ImageNode node, int emptyIndex) {
    int x = emptyIndex % level;
    int y = (emptyIndex / level).floor();

    int x2 = node.curIndex % level;
    int y2 = (node.curIndex / level).floor();

    if (x == x2) {
      if (y2 < y) {
        for (int index = y2; index < y; ++index) {
          hitNodeList.add(nodeMap[index * level + x]);
        }
        return Direction.bottom;
      } else if (y2 > y) {
        for (int index = y2; index > y; --index) {
          hitNodeList.add(nodeMap[index * level + x]);
        }
        return Direction.top;
      }
    }
    if (y == y2) {
      if (x2 < x) {
        for (int index = x2; index < x; ++index) {
          hitNodeList.add(nodeMap[y * level + index]);
        }
        return Direction.right;
      } else if (x2 > x) {
        for (int index = x2; index > x; --index) {
          hitNodeList.add(nodeMap[y * level + index]);
        }
        return Direction.left;
      }
    }
    return Direction.none;
  }

  void swapEmpty() {
    int v = -level;
    if (direction == Direction.right) {
      v = 1;
    } else if (direction == Direction.left) {
      v = -1;
    } else if (direction == Direction.bottom) {
      v = level;
    }
    hitNodeList.forEach((node) {
      node.curIndex += v;
      nodeMap[node.curIndex] = node;
      node.rect = puzzleMagic.getOkRectF(
          node.curIndex % level, (node.curIndex / level).floor());
    });
    emptyIndex -= v * hitNodeList.length;
  }
}
