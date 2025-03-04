import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:auto_direction/auto_direction.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:win_diggy/Models/Center.dart';
import 'package:win_diggy/Models/Player.dart';
import 'package:win_diggy/Widgets/NetworkWidget.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:win_diggy/Globals.dart' as globals;
import 'package:win_diggy/Models/Box.dart';
import 'package:win_diggy/Models/GlobalTranslations.dart';
import 'package:win_diggy/CustomIcons/puzzle_icons_icons.dart';
import 'package:win_diggy/Globals.dart' as globals;

Future<Map<String, dynamic>> fetchCountry(http.Client client) async {
  print('IMAGE DIFFERENCE GAME');

  DataSnapshot data = await FirebaseDatabase.instance
      .reference()
      .child('Practice-game')
      .child('ftd')
      .once();
  return compute(parseData, data);
}

// A function that will convert a response body into a List<Country>
Map<String, dynamic> parseData(DataSnapshot dbData) {
  print(dbData);
  List<Box> boxes = new List<Box>();
  Map<String, dynamic> parsedData;
  for (var data in dbData.value['results']) {
    boxes.add(Box(
        x1: double.parse(data['x']),
        y1: double.parse(data['y']),
        x2: double.parse(data['x_end']),
        y2: double.parse(data['y_end'])));
  }
  print('DIFFERENCES LENGTH: ${boxes.length}');

  print('ANSWERS');
  parsedData = {
    'image1': dbData.value['details']['side_a'],
    'image2': dbData.value['details']['side_b'],
    'attempts': dbData.value['details']['attempts'],
    'boxes': boxes,
    'answers': dbData.value['details']['answers'],
  };

  return parsedData;
}

class PracticeImageDiffScreen extends StatefulWidget {
  static ImageDiffScreenState of(BuildContext context) =>
      context.ancestorStateOfType(const TypeMatcher<ImageDiffScreenState>());
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ImageDiffScreenState();
  }
}

class ImageDiffScreenState extends State<PracticeImageDiffScreen> {
  bool capPop;
  GlobalKey<DrawingViewState> _keyChild1 = GlobalKey();

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
          child: Container(
            color: Colors.black,
            child: new FutureBuilder<Map<String, dynamic>>(
              future: fetchCountry(new http.Client()),
              builder: (context, snapshot) {
                if (snapshot.hasError) print(snapshot.error);

                return snapshot.hasData
                    ? new DrawingView(
                        data: snapshot.data,
                        key: _keyChild1,
                      )
                    : new Center(child: new CircularProgressIndicator());
              },
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
}

class DrawingView extends StatefulWidget {
  Map<String, dynamic> data;
  GlobalKey key;

  DrawingView({
    this.data,
    this.key,
  });

  static DrawingViewState of(BuildContext context) =>
      context.ancestorStateOfType(const TypeMatcher<DrawingViewState>());

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return DrawingViewState();
  }
}

class DrawingViewState extends State<DrawingView>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  Animation<double> _contentAnimation;
  AnimationController _controller;
  bool isLoading;
  List<Widget> icons = new List();
  List<Box> boxes = new List();
  List<CenterPoint> centerPoints = new List();

  int attempts;
  String hours, minutes, seconds, milliseconds;
  var finishTime;
  String gameID;
  bool meWinner;
  bool calledOneTime;
  var diffFound;
  ValueNotifier<double> percentNotifier = new ValueNotifier<double>(0.0);
  ValueNotifier<int> attemptsNotifier = new ValueNotifier<int>(0);
  String userName;
  double percIncrement;
  int finishDateTime;
  bool gameLocked;
  bool popupShown;

  bool gameEndAlreadyShown;
  bool gameCompletedCalledOnce;
  Stopwatch watch = new Stopwatch();
  Timer timer;
  Timer timer2;
  Duration durationd;
  Duration duration2;

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

    boxes = widget.data['boxes'];
    attempts = int.parse(widget.data['attempts']);
    diffFound = 0;
    percIncrement = 0.0;
    popupShown = false;
    gameCompletedCalledOnce = false;

    gameEndAlreadyShown = false;

    gameID = '';
    userName = '';

    calculatePercentInc();

    isLoading = false;
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _controller.forward();
    _contentAnimation = Tween(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();

    watch.stop();
    if (timer != null) timer.cancel();
    if (timer2 != null) timer2.cancel();
  }

  Future calculatePercentInc() async {
    double per = 100 / attempts;
    percIncrement = per / 100;
    registerListener();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      print('QUIZ SCREEN WIDGET RESUMED');
    }
  }



  Future registerListener() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    gameID = prefs.getString('gameID');

    await getUsername();
  }

  //////////////////////////////////////////////////////////////////GET USERNAME AND CHECK FB FOR FIRST LOAD
  Future getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userName = prefs.getString('username');


    setState(() {
      isLoading = true;
    });
    await startStopWatch();
  }

  Future startStopWatch() async {
    durationd = -Duration(minutes: 0, seconds: 0, hours: 0);
    duration2 = -Duration(minutes: 0, seconds: 0, hours: 0);
    print('DURATIONS');
    print(duration2);
    print(durationd);
    setState(() {
      isLoading = false;
    });
    await startTimer();
  }

  Future startTimer() async {
    watch.start();
    /////////////////////////////////////////////////////////////////////TIMER FOR HOURS, MINUTES AND SECONDS
    timer = new Timer.periodic(new Duration(seconds: 1), forwardTimeCallback);
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
      duration2 = duration2 + Duration(milliseconds: 10);
      //print('FORWARD TIMER: $durationd');

      setState(() {
        if (duration2.inMilliseconds.remainder(1000).toString().length >= 2)
          milliseconds = (duration2.inMilliseconds.remainder(1000))
              .toString()
              .substring(0, 2);
        else if (duration2.inMilliseconds.remainder(1000).toString().length < 2)
          milliseconds = (duration2.inMilliseconds.remainder(1000))
              .toString()
              .padLeft(2, '0');
      });
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
                    hours.toString(),
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
                    minutes.toString(),
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
                    seconds.toString(),
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
                    milliseconds.toString(),
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

  Future giffyDialog(String message) async {
    watch.stop();
    if (timer != null) timer.cancel();
    if (timer2 != null) timer2.cancel();

    globals.gameEnded = true;
    globals.gameCompleted = true;

    setState(() {
      calledOneTime = true;
    });

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
                                      if (timer != null) timer.cancel();
                                      if (timer2 != null) timer2.cancel();
                                      Navigator.pop(context);
                                      Navigator.pop(context);
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

  Future addIcon(Rect center) async {
    setState(
      () {
        icons.add(
          Positioned(
            left: center.left + MediaQuery.of(context).size.width * 0.01,
            top: center.top - MediaQuery.of(context).size.height * 0.03,
            child: SizedBox(
              height: 45,
              width: 45,
              child: SvgPicture.asset(
                'assets/circle_outline.svg',
                semanticsLabel: 'A red up arrow',
              ),
            ),
          ),
        );
      },
    );
  }

  Future incrementCounter(CenterPoint center) async {
    var checkPoint = centerPoints.firstWhere(
        (product) => product.centerOffset == center.centerOffset,
        orElse: () => null);
    if (checkPoint != null) {
      print('THIS CLUE IS ALREADY FOUND');
    } else {
      print('CENTER POINT ADDED TO LIST');
      centerPoints.add(center);
      setState(() {
        ++diffFound;
      });
      if (diffFound == int.parse(widget.data['answers'])) {
        watch.stop();
        if (timer != null) timer.cancel();
        if (timer2 != null) timer2.cancel();
        giffyDialog(
          allTranslations.text('you_win'),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget drawCanvas() {
      return GestureDetector(
        onTapDown: (TapDownDetails details) async {
          print('CALLED');

          final RenderBox box = context.findRenderObject();
          final Offset localOffset = box.globalToLocal(details.globalPosition);
          final result = BoxHitTestResult();
          if (box.hitTest(result, position: localOffset)) {
            // print('CALLED');
            Rect rect = Rect.fromLTRB(
              boxes[globals.boxPosition].x1 * globals.width,
              boxes[globals.boxPosition].y1 * globals.height,
              boxes[globals.boxPosition].x2 * globals.width,
              (boxes[globals.boxPosition].y2 * globals.height),
            );

            print('BOX CENTER: ${rect.center}');
            incrementCounter(CenterPoint(centerOffset: rect.center));
          } else {
            print('ELSE CALLED IN GESTURE DET. YOU HIT OUT OF BOX');
          }
        },
        child: CustomPaint(
          foregroundPainter: Circle(centerPoints: centerPoints),
          painter: PicturePainter(
            boxes: boxes,
            percentNotifier: percentNotifier,
            attemptsNotifier: attemptsNotifier,
            incValue: percIncrement,
            onCountSelected: () {
              gameEndDialog();
            },
          ),
          child: Container(),
        ),
      );
    }

    // TODO: implement build
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
                          allTranslations.text('sample_prize'),
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
                  alignment: Alignment.center,
                  //  color: Colors.yellow,
                  margin: EdgeInsets.only(top: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          // color: Colors.blue[100],
                          //alignment: Alignment.center,
                          child: Stack(
                            fit: StackFit.expand,
                            children: <Widget>[
                              Container(
                                //color: Colors.blue[100],
                                child: CachedNetworkImage(
                                  fit: BoxFit.fill,
                                  imageUrl: widget.data['image1'],
                                  placeholder: (context, url) => Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                ),
                              ),
                              drawCanvas(),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Expanded(
                        child: Container(
                          // color: Colors.blue[300],
                          alignment: Alignment.center,
                          child: Stack(
                            fit: StackFit.expand,
                            children: <Widget>[
                              Container(
                                child: CachedNetworkImage(
                                  fit: BoxFit.fill,
                                  imageUrl: widget.data['image2'],
                                  placeholder: (context, url) => Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                ),
                              ),
                              drawCanvas(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.10,
                margin: EdgeInsets.only(top: 5),
                padding: EdgeInsets.only(left: 20, right: 20),
                // color: Colors.blue,
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.centerLeft,
                      //color: Colors.blue[100],
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.07,
                        alignment: Alignment.centerLeft,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
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
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                  //color: Colors.blue[100],
                                  child: Text(
                                    allTranslations.text('find_diff'),
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                      fontFamily: 'Futura',
                                    ),
                                  ),
                                ),
                                Container(
                                  //color: Colors.blue[200],
                                  margin: EdgeInsets.only(left: 10),
                                  child: Text(
                                    diffFound.toString() +
                                        '\/' +
                                        widget.data['answers'],
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                      fontFamily: 'Futura',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        // color: Colors.blue[100],
                        alignment: Alignment.centerRight,
                        child: CircularPercentIndicator(
                          radius: 47.0,
                          lineWidth: 8.0,
                          animation: true,
                          percent: percentNotifier.value,
                          animationDuration: 450,
                          animateFromLastPercent: true,
                          backgroundColor: Colors.white,
                          center: new Text(
                            attemptsNotifier.value.toString() +
                                '\/' +
                                attempts.toString(),
                            style: new TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 9.0,
                              color: Colors.white,
                            ),
                          ),
                          circularStrokeCap: CircularStrokeCap.round,
                          progressColor: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        inAsyncCall: isLoading,
      ),
    );
  }

  Future gameEndDialog() async {
    print('GAME END DIALOG CALLED');
    watch.stop();
    if (timer != null) timer.cancel();
    if (timer2 != null) timer2.cancel();

    if (popupShown) Navigator.pop(context);

    globals.gameEnded = true;
    globals.gameCompleted = true;

    setState(() {
      popupShown = true;
      gameEndAlreadyShown = true;
    });

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
                                    allTranslations.text('game_end'),
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
                                      watch.stop();
                                      if (timer != null) timer.cancel();
                                      if (timer2 != null) timer2.cancel();

                                      Navigator.pop(context);
                                      Navigator.pop(context);
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
}

class PicturePainter extends CustomPainter {
  List<Box> boxes = new List();
  ValueNotifier<double> percentNotifier;
  ValueNotifier<int> attemptsNotifier;
  double incValue;
  VoidCallback onCountSelected;

  PicturePainter({
    this.boxes,
    this.percentNotifier,
    this.attemptsNotifier,
    this.incValue,
    this.onCountSelected,
  });
  List<Offset> centerPoints = new List();
  bool valueChanged = false;

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint

    double height = (size.height / 1000);
    double width = (size.width / 1000);
    globals.height = height;
    globals.width = width;
    for (int i = 0; i < boxes.length; i++) {
      final paint = Paint();
      paint.color = Colors.transparent;
      canvas.drawRect(
        new Rect.fromLTRB(
            boxes[i].x1 * globals.width,
            (boxes[i].y1 * globals.height),
            boxes[i].x2 * globals.width,
            ((boxes[i].y2 * globals.height))),
        paint,
      );
      double centerx =
          (((boxes[i].x2 * globals.width) - (boxes[i].x1 * globals.width)) /
                  2) +
              (boxes[i].x1 * globals.width);
      double centery =
          ((((boxes[i].y2 * globals.height)) - (boxes[i].y1 * globals.height)) /
                  2) +
              (boxes[i].y1 * globals.height);

      // print(Offset(centerx, centery));
      centerPoints.add(
        Offset(centerx, centery),
      );
    }
  }

  @override
  bool hitTest(Offset position) {
    Path path;
    for (int i = 0; i < boxes.length; i++) {
      double boxwidth =
          ((boxes[i].x2 * globals.width) - (boxes[i].x1 * globals.width));
      double boxheight =
          (((boxes[i].y2 * globals.height)) - (boxes[i].y1 * globals.height));
      path = Path();
      path.addRect(
        Rect.fromCenter(
          center: centerPoints[i],
          width: (boxwidth),
          height: (boxheight),
        ),
      );
      path.close();
      if (path.contains(position)) {
        globals.boxPosition = i;
        return true;
      }
    }
    print('NO CLUE FOUND');
    if (percentNotifier.value < 0.9) {
      percentNotifier.value = percentNotifier.value + incValue;
      print('CURRENT PERCENT VALUE AFTER: ${percentNotifier.value}');

      attemptsNotifier.value++;
      if (percentNotifier.value > 0.9 ||
          percentNotifier.value.truncate() == 1.0) onCountSelected();
    }
    return false;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }
}

class Circle extends CustomPainter {
  List<CenterPoint> centerPoints;
  Circle({
    this.centerPoints,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    for (int i = 0; i < centerPoints.length; i++) {
      final paint = Paint()
        ..color = Colors.green
        ..strokeWidth = 7
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(centerPoints[i].centerOffset, 16, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }
}
