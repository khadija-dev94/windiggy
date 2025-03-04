import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:auto_direction/auto_direction.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:win_diggy/CustomIcons/puzzle_icons_icons.dart';
import 'package:win_diggy/Models/GlobalTranslations.dart';

import 'package:win_diggy/Globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:soundpool/soundpool.dart';
import 'package:http/http.dart' as http;
import 'package:win_diggy/Globals.dart' as globals;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

Future<Map<String, dynamic>> fetchCountry(http.Client client) async {
  print('FLIP GAME SERVICE');
  DataSnapshot data = await FirebaseDatabase.instance
      .reference()
      .child('Practice-game')
      .child('flip')
      .once();

  return compute(parseData, data);
}

// A function that will convert a response body into a List<Country>
Map<String, dynamic> parseData(DataSnapshot dbData) {
  print('FLIP DATA: $dbData');
  List<String> boxes = new List();
  for (var data in dbData.value['grid']) {
    boxes.add(data['content']);
    boxes.add(data['content']);
  }

  Map<String, dynamic> parsedData;
  parsedData = {
    'cells': boxes,
    'totalBoxes': dbData.value['details']['grid_boxes'],
    'type': dbData.value['details']['type'],
  };

  return parsedData;
}

class PracticeFlipGameScreen extends StatefulWidget {
  static FlipGameScreenState of(BuildContext context) =>
      context.ancestorStateOfType(const TypeMatcher<FlipGameScreenState>());
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return FlipGameScreenState();
  }
}

class FlipGameScreenState extends State<PracticeFlipGameScreen> {
  bool capPop;
  GlobalKey<InnerViewFlipState> _keyChild1 = GlobalKey();

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
                    ? new InnerViewFlip(
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

class InnerViewFlip extends StatefulWidget {
  Map<String, dynamic> data;
  GlobalKey key;

  InnerViewFlip({this.data, this.key});

  static InnerViewFlipState of(BuildContext context) =>
      context.ancestorStateOfType(const TypeMatcher<InnerViewFlipState>());

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return InnerViewFlipState();
  }
}

class InnerViewFlipState extends State<InnerViewFlip>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  Animation<double> _contentAnimation;
  AnimationController _controller;
  bool isLoading;
  String hours, minutes, seconds, milliseconds;
  var finishTime;
  String gameID;
  bool meWinner;
  bool calledOneTime;
  String userName;
  int finishDateTime;
  bool gameLocked;
  bool popupShown;

  var updateListener;
  bool gameEndAlreadyShown;
  bool gameCompletedCalledOnce;
  Stopwatch watch = new Stopwatch();
  Timer timer;
  Timer timer2;
  Duration durationd;
  Duration duration2;
  ValueNotifier<int> playersCountNotifier = new ValueNotifier<int>(0);
  List<String> boxes = new List();

  List<int> checked = new List();
  String firstValue;
  List<int> currentIndices = new List();
  List<String> values = new List();
  List<AnimationController> controllers = new List();
  Soundpool pool;
  int soundId1;
  int soundId2;

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

    boxes = widget.data['cells'];
    boxes.shuffle();
    boxes.shuffle();
    gameLocked = false;
    popupShown = false;
    meWinner = false;
    calledOneTime = false;
    gameCompletedCalledOnce = false;

    gameEndAlreadyShown = false;

    gameID = '';
    userName = '';
    pool = Soundpool(streamType: StreamType.notification);

    isLoading = false;

    registerListener();

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
    if (updateListener != null) updateListener.cancel();

    watch.stop();
    if (timer != null) timer.cancel();
    if (timer2 != null) timer2.cancel();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      print('QUIZ SCREEN WIDGET RESUMED');
    }
  }



  Future startStopWatch() async {
    soundId1 =
        await rootBundle.load("assets/flip.mp3").then((ByteData soundData) {
      return pool.load(soundData);
    });

    soundId2 = await rootBundle
        .load("assets/flipMatch.mp3")
        .then((ByteData soundData) {
      return pool.load(soundData);
    });

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
      finishTime = '$hours:'
          '$minutes:'
          '$seconds:'
          '$milliseconds';
      finishDateTime = duration2.inMilliseconds;
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

  Future gameComplete() async {
    watch.stop();
    if (timer != null) timer.cancel();
    if (timer2 != null) timer2.cancel();
    giffyDialog(
      allTranslations.text('you_win'),
    );
  }

  Future giffyDialog(String message) async {
    watch.stop();
    if (timer != null) timer.cancel();
    if (timer2 != null) timer2.cancel();

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

  Future gameEndDialog() async {
    print('GAME END DIALOG CALLED');
    watch.stop();
    if (timer != null) timer.cancel();
    if (timer2 != null) timer2.cancel();

    if (popupShown) Navigator.pop(context);

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

  @override
  Widget build(BuildContext context) {
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
              Container(
                margin: EdgeInsets.only(top: 10),
                alignment: Alignment.center,
                child: Text(
                  allTranslations.text('flip_text'),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                    alignment: Alignment.center,
                    //  color: Colors.yellow,
                    //margin: EdgeInsets.only(top: 10),
                    child: StaggeredGridView.countBuilder(
                      crossAxisCount: 5,
                      shrinkWrap: true,
                      itemCount: boxes.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: EdgeInsets.all(2),
                          child: FlipCard(
                              boxes[index], index, widget.data['type']),
                        );
                      },
                      staggeredTileBuilder: (int index) =>
                          new StaggeredTile.extent(
                              1, MediaQuery.of(context).size.height * 0.11),
                    )),
              ),
            ],
          ),
        ),
        inAsyncCall: isLoading,
      ),
    );
  }
}

class FlipCard extends StatefulWidget {
  String value;
  int index;
  String type;

  FlipCard(this.value, this.index, this.type);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return CardFlipState();
  }
}

class CardFlipState extends State<FlipCard>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> _frontRotation;
  Animation<double> _backRotation;
  bool notMatched;
  bool isFront = true;
  bool animatedCompleted;

  Future toggleCard() async {
    checkMatch();
  }

  @override
  void initState() {
    super.initState();
    notMatched = false;
    animatedCompleted = false;

    controller =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    _frontRotation = TweenSequence(
      <TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: Tween(begin: 0.0, end: pi / 2)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 50.0,
        ),
        TweenSequenceItem<double>(
          tween: ConstantTween<double>(pi / 2),
          weight: 50.0,
        ),
      ],
    ).animate(controller);
    _backRotation = TweenSequence(
      <TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: ConstantTween<double>(pi / 2),
          weight: 50.0,
        ),
        TweenSequenceItem<double>(
          tween: Tween(begin: -pi / 2, end: 0.0)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 50.0,
        ),
      ],
    ).animate(controller);
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animatedCompleted = true;
        if (InnerViewFlip.of(context).checked.length ==
            InnerViewFlip.of(context).boxes.length) if (animatedCompleted) {
          InnerViewFlip.of(context).gameComplete();
          print('ALL CLEAR AFTER MATCHED');
        }
      }
    });
  }

  Future checkMatch() async {
    if (!InnerViewFlip.of(context).checked.contains(widget.index)) {
      if (!InnerViewFlip.of(context).currentIndices.contains(widget.index)) {
        await InnerViewFlip.of(context)
            .pool
            .play(InnerViewFlip.of(context).soundId1);

        setState(() {
          InnerViewFlip.of(context).currentIndices.add(widget.index);
          InnerViewFlip.of(context).values.add(widget.value);

          InnerViewFlip.of(context).controllers.add(controller);
        });
        print('NEW ITEM: ${InnerViewFlip.of(context).currentIndices.last}');

        if (InnerViewFlip.of(context).currentIndices.length == 2) {
          print(
              'MATCHED FIRST INDEX VALUE: ${InnerViewFlip.of(context).values[0]}');
          print(
              'MATCHED SEC INDEX VALUE: ${InnerViewFlip.of(context).values[1]}');

          if (InnerViewFlip.of(context).values[0] ==
              InnerViewFlip.of(context).values[1]) {
            await InnerViewFlip.of(context)
                .pool
                .play(InnerViewFlip.of(context).soundId2);

            setState(() {
              InnerViewFlip.of(context)
                  .checked
                  .add(InnerViewFlip.of(context).currentIndices[0]);
              InnerViewFlip.of(context)
                  .checked
                  .add(InnerViewFlip.of(context).currentIndices[1]);

              InnerViewFlip.of(context).values.clear();
              InnerViewFlip.of(context).currentIndices.clear();

              InnerViewFlip.of(context).controllers.clear();
            });
          }
        }
        if (InnerViewFlip.of(context).currentIndices.length <= 3) {
          if (InnerViewFlip.of(context).currentIndices.length == 3) {
            int index1 = InnerViewFlip.of(context).currentIndices[0];
            int index2 = InnerViewFlip.of(context).currentIndices[1];
            AnimationController cont1 =
                InnerViewFlip.of(context).controllers[0];
            AnimationController cont2 =
                InnerViewFlip.of(context).controllers[1];
            String firstVaue = InnerViewFlip.of(context).values[0];
            String secVaue = InnerViewFlip.of(context).values[1];

            print(
                'FIRST INDEX VALUE: ${InnerViewFlip.of(context).currentIndices[0]}');
            print(
                'SECOND INDEX VALUE: ${InnerViewFlip.of(context).currentIndices[1]}');
            controller.forward();

            InnerViewFlip.of(context).controllers[0].reverse();
            InnerViewFlip.of(context).controllers[1].reverse();
            setState(() {
              InnerViewFlip.of(context).controllers.remove(cont1);
              InnerViewFlip.of(context).controllers.remove(cont2);
              InnerViewFlip.of(context).currentIndices.remove(index1);
              InnerViewFlip.of(context).currentIndices.remove(index2);
              InnerViewFlip.of(context).values.remove(firstVaue);
              InnerViewFlip.of(context).values.remove(secVaue);
            });
            print(
                'LIST LENGTH AFTER CLEAR: ${InnerViewFlip.of(context).currentIndices.length}');

            print(
                'FIRST INDEX VALUE AFTER CLEAR: ${InnerViewFlip.of(context).currentIndices[0]}');
          } else {
            controller.forward();
          }
        }

        setState(() {
          isFront = !isFront;
        });
      }
    }
  }

  Widget _buildContent({@required bool front}) {
    // pointer events that would reach the backside of the card should be
    // ignored
    return IgnorePointer(
      // absorb the front card when the background is active (!isFront),
      // absorb the background when the front is active
      ignoring: front ? !isFront : isFront,
      child: AnimatedBuilder(
        animation: front ? _frontRotation : _backRotation,
        builder: (BuildContext context, Widget child) {
          var transform = Matrix4.identity();
          transform.setEntry(3, 2, 0.001);
          transform.rotateX(front ? _frontRotation.value : _backRotation.value);

          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: front
                ? Container(
                    color: Theme.of(context).accentColor,
                    alignment: Alignment.center,
                  )
                : Container(
                    color: Colors.white,
                    alignment: Alignment.center,
                    child: widget.type == 'text'
                        ? Text(
                            widget.value,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : CachedNetworkImage(
                            fit: BoxFit.fill,
                            imageUrl: widget.value,
                            placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                  ),
          );
        },
        child: front
            ? Container(
                color: Theme.of(context).accentColor,
                alignment: Alignment.center,
              )
            : Container(
                color: Colors.white,
                alignment: Alignment.center,
                child: widget.type == 'text'
                    ? Text(
                        widget.value,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : CachedNetworkImage(
                        fit: BoxFit.fill,
                        imageUrl: widget.value,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final child = Stack(
      fit: StackFit.passthrough,
      children: <Widget>[
        _buildContent(front: true),
        _buildContent(front: false),
      ],
    );

    // if we need to flip the card on taps, wrap the content
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: toggleCard,
      child: child,
    );

    return child;
  }
}
