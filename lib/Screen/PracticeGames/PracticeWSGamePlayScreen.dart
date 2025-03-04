import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:auto_direction/auto_direction.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:win_diggy/Models/CompletedWordOffsets.dart';
import 'package:win_diggy/Models/GlobalTranslations.dart';

import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soundpool/soundpool.dart';
import 'package:win_diggy/Models/CompletedWord.dart';
import 'package:http/http.dart' as http;
import 'package:win_diggy/Globals.dart' as globals;
import 'package:win_diggy/CustomIcons/puzzle_icons_icons.dart';
import 'package:win_diggy/Globals.dart' as globals;

Future<Map<String, dynamic>> fetchCountry(http.Client client) async {
  print('PUZZLE GAME');

  DataSnapshot data = await FirebaseDatabase.instance
      .reference()
      .child('Practice-game')
      .child('puzzle')
      .once();

  return compute(parseData, data);
}

Map<String, dynamic> parseData(DataSnapshot dbData) {
  List<String> alphabets = new List<String>();
  List<String> words = new List();
  for (var data in dbData.value['grid']) {
    print(data[0]);
    alphabets.add(data[0]);
    alphabets.add(data[1]);
    alphabets.add(data[2]);
    alphabets.add(data[3]);
    alphabets.add(data[4]);
    alphabets.add(data[5]);
    alphabets.add(data[6]);
    alphabets.add(data[7]);
    alphabets.add(data[8]);
  }
  for (var data in dbData.value['solution']) {
    words.add(data['description']);
  }
  Map<String, dynamic> data = {'grid': alphabets, 'words': words};
  return data;
}

class PracticeWSGamePlayPage extends StatefulWidget {
  static WSGamePlayPageState of(BuildContext context) =>
      context.ancestorStateOfType(const TypeMatcher<WSGamePlayPageState>());
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return WSGamePlayPageState();
  }
}

class WSGamePlayPageState extends State<PracticeWSGamePlayPage> {
  ScreenshotController screenshotController = ScreenshotController();
  bool capPop;
  GlobalKey<StateWSGamePlayPage> _keyChild1 = GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    capPop = false;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
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
              child: Container(
                child: new FutureBuilder<Map<String, dynamic>>(
                  future: fetchCountry(new http.Client()),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) print(snapshot.error);

                    return snapshot.hasData
                        ? new InnerView(
                            data: snapshot.data,
                            key: _keyChild1,
                          )
                        : new Center(child: new CircularProgressIndicator());
                  },
                ),
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

class InnerView extends StatefulWidget {
  static StateWSGamePlayPage of(BuildContext context) =>
      context.ancestorStateOfType(const TypeMatcher<StateWSGamePlayPage>());
  Map<String, dynamic> data;
  GlobalKey key;
  InnerView({this.data, this.key});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return StateWSGamePlayPage();
  }
}

class StateWSGamePlayPage extends State<InnerView>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  List<int> selectedIndex = new List();
  List<int> lastIndeces = new List();
  List<int> firstIndeces = new List();

  int pos;
  int selectedDiff;
  List<String> alphabets = new List();
  List<String> words = new List();
  List<String> chossenWord = new List();
  List<int> completedIndices = new List();

  int wordsFound;
  Soundpool pool;
  int soundID;
  Animation<double> _contentAnimation;
  Animation<double> textAnimation;

  AnimationController _controller;
  String wordsCount;
  List<String> wordsSearched = new List();
  DateTime currentTimeZone;
  String userName;
  var finishTime;
  String gameID;
  bool calledOneTime;
  bool isLoading;
  bool meWinner;
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
  ValueNotifier<int> playersCountNotifier = new ValueNotifier<int>(0);
  int selectedOffset;
  int chacIndex;
  bool notMatched;
  double boxWidth;
  double boxHeight;
  List<CompletedPoints> completedPonits = new List();
  List<Offset> centerPoints = List();
  Color textColor;
  ValueNotifier<int> completedValueNotif = new ValueNotifier(0);
  String hours, minutes, seconds, milliseconds;

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    hours = '00';
    minutes = '00';
    seconds = '00';
    milliseconds = '00';

    WidgetsBinding.instance.addObserver(this);

    gameLocked = false;
    calledOneTime = false;
    isLoading = false;
    meWinner = false;
    popupShown = false;
    gameCompletedCalledOnce = false;
    gameEndAlreadyShown = false;
    gameID = '';
    userName = '';
    selectedOffset = 0;
    notMatched = false;
    chacIndex = 0;
    textColor = Colors.black;

    registerListener();
    alphabets = widget.data['grid'];
    words = widget.data['words'];
    wordsCount = words.length.toString();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _controller.forward();
    _contentAnimation = Tween(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    textAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticInOut),
    );

    pos = -1;
    wordsFound = 0;
    lastIndeces = [8, 17, 26, 35, 44, 53, 62, 71, 80];
    firstIndeces = [0, 9, 18, 27, 36, 45, 54, 63, 72, 81];
    pool = Soundpool(streamType: StreamType.notification);
    selectedDiff = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      print('QUIZ SCREEN WIDGET RESUMED');
      ////////////////////////////////////////////////////////RESUME WIDGET ONLY IF DASHBOARD IS ON FOREGROUND

    }
  }

  Future registerListener() async {
    soundID = await rootBundle
        .load("assets/flipMatch.mp3")
        .then((ByteData soundData) {
      return pool.load(soundData);
    });

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
      if (timer.isActive) {
        duration2 = duration2 + Duration(milliseconds: 10);
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
      }
    }
  }



  Future matchWord() async {
    var concatenate = StringBuffer();
    chossenWord.forEach((item) {
      concatenate.write(item);
    });
    print(words);
    print(concatenate);
    if (words.contains(concatenate.toString())) {
      List<int> completedSets = new List();

      completedSets = selectedIndex;

      setState(() {
        completedIndices.clear();

        for (var value in completedSets) completedIndices.add(value);
      });

      print('TOTAL INDECES LENGTH: ${completedIndices.length}');
      selectedIndex.clear();
      selectedDiff = null;

      words.remove(concatenate.toString());
      chossenWord.clear();
      print('ONE WORD SEARCHED!!!!');
      print('REMAINING WORDS');
      print(words);
      List<Offset> completedOffests = new List();
      setState(() {
        for (var value in centerPoints) {
          completedOffests.add(value);
        }
        completedPonits.add(CompletedPoints(completedOffests));

        print(
            'completedPonits first index LENGTH: ${completedPonits[0].centers.length}');

        print('completedOffests LENGTH: ${completedOffests.length}');
        print('centerPoints LENGTH: ${centerPoints.length}');

        centerPoints.clear();
      });

      wordsSearched.add(concatenate.toString());
      setState(() {
        wordsFound++;
        //_controller.forward();
        completedValueNotif.value = completedValueNotif.value++;
      });
    } else {
      setState(() {
        notMatched = true;
      });
    }
    print('NOT MATCHED');

    if (words.length == 0) {
      watch.stop();
      if (timer != null) timer.cancel();
      if (timer2 != null) timer2.cancel();
      giffyDialog(
        allTranslations.text('you_win'),
      );
    }
  }

  Future giffyDialog(String message) async {
    watch.stop();
    if (timer != null) timer.cancel();
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

  Future gameEndDialog(message) async {
    print('GAME END DIALOG CALLED');

    watch.stop();
    if (timer != null) timer.cancel();
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
                                      //sub.cancel();
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

  Future checkTap() async {
    print('CHECK TAP CALLED');
    if (selectedIndex.isEmpty) {
      setState(() {
        selectedIndex.add(globals.index);
        centerPoints.add(globals.selectedRect);
      });
      pos++;
      selectedDiff = null;
      chossenWord.add(alphabets[globals.index]);
    } else {
      int diff = globals.index - selectedIndex.last;
      if (diff == 1 || diff == -1) {
        if (lastIndeces.contains(selectedIndex.last) &&
            selectedIndex.length != 1) {
          selectedDiff = null;
          setState(() {
            selectedIndex.clear();

            centerPoints.clear();
            selectedIndex.add(globals.index);

            centerPoints.add(globals.selectedRect);
          });
          pos = 0;
          chossenWord.clear();
          chossenWord.add(alphabets[globals.index]);
          print("WORD");
          print(chossenWord);
          matchWord();
        } else if (selectedIndex.length == 1 &&
            lastIndeces.contains(selectedIndex.last) &&
            diff == 1) {
          selectedDiff = null;
          setState(() {
            selectedIndex.clear();

            centerPoints.clear();

            selectedIndex.add(globals.index);

            centerPoints.add(globals.selectedRect);
          });
          pos = 0;
          chossenWord.clear();
          chossenWord.add(alphabets[globals.index]);
          print("WORD");
          print(chossenWord);
          matchWord();
        }
        if (selectedDiff == 1) {
          selectedDiff = 1;
          setState(() {
            selectedIndex.add(globals.index);

            centerPoints.add(globals.selectedRect);
          });
          pos++;
          chossenWord.add(alphabets[globals.index]);
          print("WORD");
          print(chossenWord);
          matchWord();
        } else if (selectedDiff == null) {
          selectedDiff = 1;
          setState(() {
            selectedIndex.add(globals.index);

            centerPoints.add(globals.selectedRect);
          });
          pos++;
          chossenWord.add(alphabets[globals.index]);
          print("WORD");
          print(chossenWord);
          matchWord();
        } else {
          selectedDiff = null;
          setState(() {
            selectedIndex.clear();
            centerPoints.clear();

            selectedIndex.add(globals.index);

            centerPoints.add(globals.selectedRect);
          });
          pos = 0;
          chossenWord.clear();
          chossenWord.add(alphabets[globals.index]);
          print("WORD");
          print(chossenWord);
          matchWord();
        }
      } else if (diff == 9 || diff == -9) {
        if (selectedDiff == 9) {
          selectedDiff = 9;
          setState(() {
            selectedIndex.add(globals.index);

            centerPoints.add(globals.selectedRect);
          });
          pos++;
          chossenWord.add(alphabets[globals.index]);
          print("WORD");
          print(chossenWord);
          matchWord();
        } else if (selectedDiff == null) {
          selectedDiff = 9;
          setState(() {
            selectedIndex.add(globals.index);

            centerPoints.add(globals.selectedRect);
          });
          pos++;
          chossenWord.add(alphabets[globals.index]);
          print("WORD");
          print(chossenWord);
          matchWord();

          // matchWord();
        } else {
          selectedDiff = null;
          setState(() {
            selectedIndex.clear();

            centerPoints.clear();

            selectedIndex.add(globals.index);

            centerPoints.add(globals.selectedRect);
          });
          pos = 0;
          chossenWord.clear();
          chossenWord.add(alphabets[globals.index]);
          print("WORD");
          print(chossenWord);
          matchWord();
        }
      } else if (diff == 8 || diff == -8) {
        if (diff == -8) {
          if ((selectedDiff != -8) && selectedDiff != null) {
            selectedDiff = null;
            setState(() {
              selectedIndex.clear();

              centerPoints.clear();

              selectedIndex.add(globals.index);

              centerPoints.add(globals.selectedRect);
            });
            pos = 0;
            chossenWord.clear();
            chossenWord.add(alphabets[globals.index]);
            print("WORD");
            print(chossenWord);
            matchWord();
          } else if (selectedDiff == null &&
              ((firstIndeces.contains(globals.index) &&
                  lastIndeces.contains(selectedIndex.last)))) {
            selectedDiff = null;
            setState(() {
              selectedIndex.clear();

              centerPoints.clear();

              selectedIndex.add(globals.index);

              centerPoints.add(globals.selectedRect);
            });
            pos = 0;
            chossenWord.clear();
            chossenWord.add(alphabets[globals.index]);
            print("WORD");
            print(chossenWord);
            matchWord();
          } else if (selectedDiff == null) {
            selectedDiff = diff;
            setState(() {
              selectedIndex.add(globals.index);

              centerPoints.add(globals.selectedRect);
            });
            pos++;
            chossenWord.add(alphabets[globals.index]);
            print("WORD");
            print(chossenWord);
            matchWord();
          } else {
            selectedDiff = diff;
            setState(() {
              selectedIndex.add(globals.index);

              centerPoints.add(globals.selectedRect);
            });
            pos++;
            chossenWord.add(alphabets[globals.index]);
            print("WORD");
            print(chossenWord);
            matchWord();
          }
        } else if (diff == 8) {
          if ((selectedDiff != 8) && selectedDiff != null) {
            selectedDiff = null;
            setState(() {
              selectedIndex.clear();

              centerPoints.clear();

              selectedIndex.add(globals.index);

              centerPoints.add(globals.selectedRect);
            });
            pos = 0;
            chossenWord.clear();
            chossenWord.add(alphabets[globals.index]);
            print("WORD");
            print(chossenWord);
            matchWord();
          } else if (selectedDiff == null &&
              (lastIndeces.contains(globals.index) &&
                  firstIndeces.contains(selectedIndex.last))) {
            selectedDiff = null;
            setState(() {
              selectedIndex.clear();

              centerPoints.clear();

              selectedIndex.add(globals.index);

              centerPoints.add(globals.selectedRect);
            });
            pos = 0;
            chossenWord.clear();
            chossenWord.add(alphabets[globals.index]);
            print("WORD");
            print(chossenWord);
            matchWord();
          } else if (selectedDiff == null) {
            selectedDiff = diff;
            setState(() {
              selectedIndex.add(globals.index);

              centerPoints.add(globals.selectedRect);
            });
            pos++;
            chossenWord.add(alphabets[globals.index]);
            print("WORD");
            print(chossenWord);
            matchWord();
          } else {
            selectedDiff = diff;
            setState(() {
              selectedIndex.add(globals.index);

              centerPoints.add(globals.selectedRect);
            });
            pos++;
            chossenWord.add(alphabets[globals.index]);
            print("WORD");
            print(chossenWord);
            matchWord();
          }
        }
      } else if (diff == 10 || diff == -10) {
        if (diff == -10) {
          if ((selectedDiff != -10) && selectedDiff != null) {
            selectedDiff = null;
            setState(() {
              selectedIndex.clear();

              centerPoints.clear();

              selectedIndex.add(globals.index);

              centerPoints.add(globals.selectedRect);
            });
            pos = 0;
            chossenWord.clear();
            chossenWord.add(alphabets[globals.index]);
            print("WORD");
            print(chossenWord);
            matchWord();
          } else if (selectedDiff == null) {
            selectedDiff = diff;
            setState(() {
              selectedIndex.add(globals.index);

              centerPoints.add(globals.selectedRect);
            });
            pos++;
            chossenWord.add(alphabets[globals.index]);
            print("WORD");
            print(chossenWord);
            matchWord();
          } else {
            selectedDiff = diff;
            setState(() {
              selectedIndex.add(globals.index);

              centerPoints.add(globals.selectedRect);
            });
            pos++;
            chossenWord.add(alphabets[globals.index]);
            print("WORD");
            print(chossenWord);
            matchWord();
            return;
          }
        } else if (diff == 10) {
          if ((selectedDiff != 10) && selectedDiff != null) {
            selectedDiff = null;
            setState(() {
              selectedIndex.clear();

              centerPoints.clear();

              selectedIndex.add(globals.index);

              centerPoints.add(globals.selectedRect);
            });
            pos = 0;
            chossenWord.clear();
            chossenWord.add(alphabets[globals.index]);
            print("WORD");
            print(chossenWord);
            matchWord();

            return;
          } else if (selectedDiff == null) {
            selectedDiff = diff;
            setState(() {
              selectedIndex.add(globals.index);

              centerPoints.add(globals.selectedRect);
            });
            pos++;
            chossenWord.add(alphabets[globals.index]);
            print("WORD");
            print(chossenWord);
            matchWord();
            return;
          } else {
            selectedDiff = diff;
            setState(() {
              selectedIndex.add(globals.index);

              centerPoints.add(globals.selectedRect);
            });
            pos++;
            chossenWord.add(alphabets[globals.index]);
            print("WORD");
            print(chossenWord);
            matchWord();
            return;
          }
        }
      } else if (diff == 0) {
        if (selectedIndex.last == globals.index) {
          setState(() {
            selectedIndex.remove(globals.index);

            centerPoints.remove(globals.selectedRect);

            chossenWord.removeLast();
          });
          matchWord();
          return;
        } else {
          selectedDiff = null;
          setState(() {
            selectedIndex.clear();

            centerPoints.clear();

            selectedIndex.add(globals.index);

            centerPoints.add(globals.selectedRect);
          });
          pos = 0;
          chossenWord.clear();
          chossenWord.add(alphabets[globals.index]);
          print("WORD");
          print(chossenWord);
          matchWord();

          return;
        }
      } else {
        selectedDiff = null;
        setState(() {
          selectedIndex.clear();

          centerPoints.clear();

          selectedIndex.add(globals.index);

          centerPoints.add(globals.selectedRect);
        });
        pos = 0;
        chossenWord.clear();
        chossenWord.add(alphabets[globals.index]);
        print("WORD");
        print(chossenWord);
        matchWord();

        return;
      }
    }
  }

  List<Widget> rowItems() {
    List<Widget> widgets = new List();
    for (int i = 0; i < 9; i++) {
      //print('charIndex VALUE: $chacIndex');
      widgets.add(cellItem(chacIndex, alphabets[chacIndex]));
      chacIndex++;
    }
    if (chacIndex == alphabets.length) chacIndex = 0;
    return widgets;
  }

  Color checkCellColor(index) {
    Color color;

    if (completedIndices.length != 0) {
      if (completedIndices.contains(index)) {
        color = Colors.black;
      } else
        color = Colors.black;
    } else
      color = Colors.black;

    return color;
  }

  Widget cellItem(int index, String alphabet) {
    return Container(
      height: boxHeight,
      width: boxWidth,
      alignment: Alignment.center,
      child:
          GridAlphabet(alphabet, index, completedIndices, completedValueNotif),
    );
  }

  @override
  Widget build(BuildContext context) {
    boxWidth = ((MediaQuery.of(context).size.width) / 9);
    boxHeight = ((MediaQuery.of(context).size.height * 0.47) / 9);

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
                  child: Container(
                    margin: EdgeInsets.only(top: 10, left: 15, right: 15),
                    height: MediaQuery.of(context).size.height * 0.47,
                    //color: Color(0x40ffffff),
                    alignment: Alignment.center,
                    child: Material(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      color: Color(0xffeccb58),
                      child: Stack(
                        children: <Widget>[
                          Table(
                            children: [
                              TableRow(
                                children: rowItems(),
                              ),
                              TableRow(
                                children: rowItems(),
                              ),
                              TableRow(
                                children: rowItems(),
                              ),
                              TableRow(
                                children: rowItems(),
                              ),
                              TableRow(
                                children: rowItems(),
                              ),
                              TableRow(
                                children: rowItems(),
                              ),
                              TableRow(
                                children: rowItems(),
                              ),
                              TableRow(
                                children: rowItems(),
                              ),
                              TableRow(
                                children: rowItems(),
                              ),
                            ],
                          ),
                          GestureDetector(
                            //behavior: HitTestBehavior.deferToChild,
                            onPanUpdate: (details) async {
                              final RenderBox box = context.findRenderObject();
                              final Offset localOffset =
                                  box.globalToLocal(details.globalPosition);
                              final result = BoxHitTestResult();
                              if (box.hitTest(result, position: localOffset)) {
                                if (globals.index != selectedOffset) {
                                  selectedOffset = globals.index;
                                  checkTap();
                                }
                              }
                            },
                            onPanDown: (details) async {
                              final RenderBox box = context.findRenderObject();
                              final Offset localOffset =
                                  box.globalToLocal(details.globalPosition);
                              final result = BoxHitTestResult();
                              if (box.hitTest(result, position: localOffset)) {
                                if (globals.index != selectedOffset) {
                                  selectedOffset = globals.index;
                                  checkTap();
                                }
                              }
                            },
                            onPanEnd: (details) async {
                              if (notMatched) {
                                print('ON PAN END CALLED');
                                setState(() {
                                  selectedIndex.clear();

                                  centerPoints.clear();
                                  selectedDiff = null;
                                });
                                pos = 0;
                                chossenWord.clear();
                              }
                            },
                            child: CustomPaint(
                              foregroundPainter: PuzzleLinePainter(
                                  centerPoints: centerPoints,
                                  completedCenterPoints: completedPonits),
                              painter: PuzzleGridPainter(
                                alphabets: this.alphabets,
                              ),
                              child: Container(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.10,
                margin: EdgeInsets.only(top: 5),
                padding: EdgeInsets.only(left: 20, right: 20),
                // color: Colors.blue,
                alignment: Alignment.bottomCenter,
                child: Container(
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
                            colors: [
                              Color(0xff5c4710),
                              Color(0xffeccb58),
                              Color(0xff5c4710),
                            ],
                          ),
                        ),
                        alignment: Alignment.center,
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              //color: Colors.blue[100],
                              child: Text(
                                allTranslations.text('words_found'),
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
                                wordsFound.toString() + '\/' + wordsCount,
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
              ),
            ],
          ),
        ),
        inAsyncCall: isLoading,
      ),
    );
  }
}

class GridAlphabet extends StatefulWidget {
  String alphabet;
  int index;
  List<int> completedIndices = new List();
  ValueNotifier<int> value;

  GridAlphabet(this.alphabet, this.index, this.completedIndices, this.value);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return GridAlphabetState();
  }
}

class GridAlphabetState extends State<GridAlphabet>
    with SingleTickerProviderStateMixin {
  Animation<double> textAnimation;

  AnimationController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );

    textAnimation = Tween(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
          parent: _controller, curve: Curves.ease, reverseCurve: Curves.easeIn),
    );
    widget.value.addListener(() async {
      if (widget.completedIndices.contains(widget.index)) {
        _controller.forward();

        textAnimation.addStatusListener((status) {
          if (status == AnimationStatus.completed) _controller.reverse();
        });
        await InnerView.of(context).pool.play(InnerView.of(context).soundID);

        // _controller.reverse(from: 1.2);

      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  Future reverseAnimator() async {
    if (widget.completedIndices.length != 0) {
      if (widget.completedIndices.contains(widget.index)) {
        _controller.forward();

        textAnimation.addStatusListener((status) {
          if (status == AnimationStatus.completed) _controller.reverse();
        });
        // _controller.reverse(from: 1.2);

        //reverseAnimator();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Transform.scale(
      scale: textAnimation.value,
      child: Text(
        widget.alphabet.toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 25,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class PuzzleLinePainter extends CustomPainter {
  List<Offset> centerPoints = List();
  List<CompletedPoints> completedCenterPoints = List();

  PuzzleLinePainter({
    this.centerPoints,
    this.completedCenterPoints,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..color = Color(0x59000000)
      ..strokeWidth = 28;

    int pointsLength = 0;
    if (completedCenterPoints.length >= 1) {
      for (int i = 0; i < completedCenterPoints.length; i++) {
        pointsLength = completedCenterPoints[i].centers.length;
        if (pointsLength > 1) {
          canvas.drawLine(completedCenterPoints[i].centers[0],
              completedCenterPoints[i].centers[pointsLength - 1], paint);
        }
      }
    }
    if (centerPoints.length >= 2) {
      canvas.drawLine(centerPoints[0], centerPoints.last, paint);
    } else {
      canvas.drawPoints(PointMode.points, centerPoints, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}

class PuzzleGridPainter extends CustomPainter {
  List<Color> colors = [
    Colors.blue,
    Colors.pink,
    Colors.blue,
    Colors.pink,
    Colors.blue,
    Colors.pink,
    Colors.blue,
    Colors.pink,
    Colors.blue
  ];
  List<Color> colors2 = [
    Colors.red,
    Colors.yellow,
    Colors.red,
    Colors.yellow,
    Colors.red,
    Colors.yellow,
    Colors.red,
    Colors.yellow,
    Colors.red
  ];

  PuzzleGridPainter({
    this.alphabets,
  });
  List<Offset> centerPoints = List();
  List<Rect> boxes = new List();
  List<String> alphabets = new List();

  @override
  void paint(Canvas canvas, Size size) {
    double boxWidth = (size.width / 9);
    double boxHeight = (size.height / 9);
    final paint = Paint();
    final paint2 = Paint();
    paint2.color = Colors.orange;
    final paint3 = Paint();
    paint3.color = Colors.transparent;

    double left = 0.0;
    double top = 0.0;
    double right = boxWidth;
    double bottom = boxHeight;
    int pos = 0;

    for (int i = 0; i < 9; i++) {
      for (int i = 0; i < 9; i++) {
        if (pos == 0)
          paint.color = colors[i];
        else
          paint.color = colors2[i];

        Rect rect2 = Rect.fromLTRB(left, top, right, bottom);
        canvas.drawRect(rect2, paint3);

        Offset center = Offset(
            ((rect2.width / 2) + rect2.left), ((rect2.height / 2)) + rect2.top);
        canvas.drawCircle(center, 12, paint3);
        // print('BOX WIDTH: ${rect2.width}');
        //print('BOX HEIGHT: ${rect2.height}');
        centerPoints.add(center);
        boxes.add(rect2);
        left = rect2.right;
        right = (rect2.right + boxWidth);
        top = rect2.top;
        bottom = rect2.bottom;
      }
      if (pos == 0)
        pos = 1;
      else
        pos = 0;
      left = 0.0;
      right = boxWidth;

      top = top + boxHeight;
      bottom = bottom + boxHeight;
    }
  }

  @override
  bool hitTest(Offset position) {
    Path path;
    for (int i = 0; i < boxes.length; i++) {
      path = Path();
      path.addOval(Rect.fromLTRB(
          boxes[i].left, boxes[i].top, boxes[i].right, boxes[i].bottom));
      path.close();
      if (path.contains(position)) {
        globals.selectedRect = centerPoints[i];
        globals.index = i;
        return true;
      }
    }

    return false;
  }

  @override
  bool shouldRepaint(PuzzleGridPainter oldDelegate) => false;
}
