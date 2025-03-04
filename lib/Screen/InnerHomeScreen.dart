import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:auto_direction/auto_direction.dart';
import 'package:badges/badges.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:win_diggy/CustomIcons/puzzle_icons_icons.dart';
import 'package:win_diggy/Models/Game.dart';
import 'package:win_diggy/Models/GlobalMethods.dart';
import 'package:win_diggy/Models/GlobalTranslations.dart';
import 'package:win_diggy/Globals.dart' as globals;
import 'package:win_diggy/Widgets/BottomNotiSlider.dart';
import 'package:win_diggy/Widgets/Drawer.dart';
import 'package:win_diggy/Widgets/ScrollBarAlwaysVisible.dart';
import 'package:win_diggy/Widgets/SingleGameTile.dart';
import 'package:win_diggy/Widgets/TimerDialog.dart';
import 'package:win_diggy/main.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Contest24HrScreen.dart';
import 'FBMessagesScreen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'DailyContestScreen.dart';
import 'WinnersScreen.dart';
import 'package:win_diggy/Widgets/BonusGameView.dart';

class HomePage extends StatefulWidget {
  Map<String, dynamic> serverData;

  HomePage({this.serverData});

  static HomePageState of(BuildContext context) =>
      context.ancestorStateOfType(const TypeMatcher<HomePageState>());

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return HomePageState();
  }
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  List<Game> games = new List<Game>();
  Game nextGame, nextGame2;
  FirebaseMessaging _fcm = FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  AnimationController animationController;
  Animation<double> animation;

  String parsedTime;
  String language = allTranslations.currentLanguage;
  String lang;
  ValueNotifier<String> langNotifier;
  String game2parsedTime;
  int badgeCounter;
  GlobalKey<MessageReultsState> _keyChild1 = GlobalKey();
  bool showLangOption;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool resumedOnce;
  ProgressDialog pr;
  bool gameIDChanged = true;
  bool statusChanged = false;
  var _firebaseRef = FirebaseDatabase.instance.reference().child('dashboard');
  DataSnapshot initialData;
  bool showContest;
  bool showBonusGame;
  String bonusTextEng;
  String bonusTextUrd;
  String dashbordTextEng;
  String dashbordTextUrd;

  @override
  void dispose() {
    // TODO: implement dispose
    if (animationController != null) animationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    showLangOption = false;
    resumedOnce = false;
    nextGame = null;
    nextGame2 = null;
    showBonusGame = false;
    bonusTextEng = '';
    bonusTextUrd = '';
    dashbordTextEng = '';
    dashbordTextUrd = '';

    showContest = false;
    globals.key = _keyChild1;
    WidgetsBinding.instance.addObserver(this);
    badgeCounter = 0;
    allTranslations.onLocaleChangedCallback = _onLocaleChanged;
    getCountry();

    if (language == 'ur')
      lang = 'English';
    else
      lang = 'اردو';
    langNotifier = new ValueNotifier(language);

    configureLocalNotification();
    globals.fcm = _fcm;
    configureFCM();

    if (!widget.serverData['blocked']) readNextGame();

    animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    animation = Tween(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
    );

    animationController.forward();
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed)
        animationController.reverse();
      else if (status == AnimationStatus.dismissed)
        animationController.forward();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    print('HOME WIDGET STATE: $state');

    if (globals.timerDialogShowed) {
      Navigator.of(context, rootNavigator: true).pop();
      globals.timerDialogShowed = false;
    }
    if (pr.isShowing()) await pr.hide();

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      if (globals.timerDialogShowed) {
        Navigator.of(context, rootNavigator: true).pop();
        globals.timerDialogShowed = false;
      }
      if (pr.isShowing()) await pr.hide();

      if (globals.updateListener != null) globals.updateListener.cancel();
    }
    if (state == AppLifecycleState.resumed) {
      if (globals.timerDialogShowed) {
        Navigator.of(context, rootNavigator: true).pop();
        globals.timerDialogShowed = false;
      }
      if (pr.isShowing()) await pr.hide();

      globals.updateListener = FirebaseDatabase.instance
          .reference()
          .child('next-game')
          .onChildChanged
          .listen(_onChildUpdated);
      ////////////////////////////////////////////////////////RESUME WIDGET ONLY IF DASHBOARD IS ON FOREGROUND
      print('HOME WIDGET RESUMED');

      if (pr.isShowing()) await pr.hide();

      ////////////////////////////////////////////////////////RESUME WIDGET ONLY IF DASHBOARD IS ON FOREGROUND
      print('HOME WIDGET RESUMED');

      if (!widget.serverData['blocked']) {
        if (globals.HOMEONFRONT) {
          print('RESUMED ONCE:${globals.resumeCalledOnce}');
          if (!globals.resumeCalledOnce) {
            globals.resumeCalledOnce = true;
            if (_scaffoldKey.currentState != null) {
              print('SCAFFOLD KEY IS NON NULL');
              if (!_scaffoldKey.currentState.isDrawerOpen) {
                print('TIMER ALREADY SHOWN:${globals.timerDialogShowed}');

                if (globals.timerDialogShowed) {
                  Navigator.of(context, rootNavigator: true).pop();
                  globals.timerDialogShowed = false;
                }
                if (pr.isShowing()) await pr.hide();

                await getData();
              } else {
                globals.resumeCalledOnce = false;
              }
            } else {
              print('SCAFFOLD KEY IS NULL');

              if (globals.timerDialogShowed) {
                Navigator.of(context, rootNavigator: true).pop();
                globals.timerDialogShowed = false;
              }
              if (pr.isShowing()) await pr.hide();
              await getData();
              print('DIALOG LOADING CALLED 1');
            }
          }
        }
      }
    }
  }

  ////////////////////////////////////////////////////////////////READ NEXTGAME NODE FOR THE FIRST TIME
  Future readNextGame() async {
    await Future.delayed(Duration.zero, () async {
      pr = new ProgressDialog(context,
          type: ProgressDialogType.Normal,
          isDismissible: false,
          showLogs: false);
    });
    await getNextGameNode();
  }

  Future getNextGameNode() async {
    DataSnapshot snapshot =
        await FirebaseDatabase.instance.reference().child('next-game').once();

    if (snapshot.value != null) {
      globals.updateListener = FirebaseDatabase.instance
          .reference()
          .child('next-game')
          .onChildChanged
          .listen(_onChildUpdated);
      if (snapshot.value['env'] == 'live') {
        globals.targetTime = snapshot.value['start-time'];
        if (snapshot.value['status'] == 'new') {
          /////////////////////////////////////////////////////////CLEAR PREFERENCE FOR EXCEPTION CASE
          SharedPreferences prefs = await SharedPreferences.getInstance();
          String encryptGameID = prefs.getString('gameID');
          if (encryptGameID == null || encryptGameID == '') {
          } else {
            if (prefs.getString('startTime') == '' ||
                prefs.getString('startTime') == null) {
            } else {
              DateTime targetdateTime =
                  globals.dateFormat.parse(prefs.getString('startTime'));
              String decryptedID = await GlobalsMethods.decryptGameID(
                  targetdateTime.hour, targetdateTime.day, encryptGameID);

              if (decryptedID != snapshot.value['game-id'].toString()) {
                prefs.setString('gamePlayed', '');
                DateTime newTime =
                    globals.dateFormat.parse(snapshot.value['start-time']);
                String encryptedID = await GlobalsMethods.encryptGameID(
                    newTime.hour,
                    newTime.day,
                    snapshot.value['game-id'].toString());
                prefs.setString('gameID', encryptedID);
              }
            }
          }

          if (!pr.isShowing()) await pr.show();
          await Future.wait([getNTPTime(snapshot)]);
        } else {
          SharedPreferences prefs = await SharedPreferences.getInstance();

          prefs.setString('gameLoaded', '');

          print('GAME IS COMPLETED');
          if (pr.isShowing()) pr.hide();
        }
      } else {
        print('LOADING CLOSED 14');

        if (pr.isShowing()) {
          pr.hide();
        } else
          print('DIALOG NOT SHOWN');
      }
    } else {
      print('LOADING CLOSED 15');

      if (pr.isShowing()) {
        pr.hide();
      } else
        print('PROGRESS NOT SHOWN');

      print('NO NEXT-GAME NODE EXIST');
    }
  }

  Future _onChildUpdated(Event event) async {
    print('FB CHILD UPDATED AT HOME ${globals.updateCalledOnce}');
    print('FB CHILD UPDATED AT HOME ${globals.resumeCalledOnce}');

    if (!globals.resumeCalledOnce) {
      try {
        DataSnapshot data = await FirebaseDatabase.instance
            .reference()
            .child('next-game')
            .child('env')
            .once();
        print('GAME ENVIRONMENT: ${data.value}');
        if (data.value == 'live') {
          if (event.snapshot.key == 'status') {
            statusChanged = true;
          }

          if (!globals.updateCalledOnce) {
            globals.updateCalledOnce = true;
            if (_scaffoldKey != null) {
              if (_scaffoldKey.currentState != null) {
                if (!_scaffoldKey.currentState.isDrawerOpen) {
                  ///////////////////////////////////////////////////////////IF POPUP IS ALREADT SHOWN ON SCREEN
                  if (globals.HOMEONFRONT) {
                    if (pr.isShowing()) {
                      await pr.hide();
                    }
                    if (globals.timerDialogShowed) {
                      print('TIMER IS ALREADY ON SCREEN');
                      Navigator.of(context, rootNavigator: true).pop();
                      globals.timerDialogShowed = false;

                      if (pr.isShowing()) {
                        await pr.hide();
                      }
                      if (statusChanged) {
                        if (event.snapshot.value.toString() == 'Complete') {
                          gameCompleteDialog();
                        } else
                          await getData();
                      } else {
                        await getData();
                      }
                    } else {
                      print(
                          'ELSE CALLED IN FB UPDATE: ${event.snapshot.value}');

                      await getData();
                    }
                  }
                } else {
                  globals.updateCalledOnce = false;
                }
              } else {
                ///////////////////////////////////////////////////////////IF POPUP IS ALREADT SHOWN ON SCREEN
                scaffoldIsNull(event);
              }
            } else
              scaffoldIsNull(event);
          }
        }
      } catch (e, s) {
        Crashlytics.instance.recordError(e, s, context: 'as an example');
      }
    }
  }

  Future scaffoldIsNull(Event event) async {
    print('SCAFOFLS IS NULL');
    if (globals.HOMEONFRONT) {
      if (globals.timerDialogShowed) {
        print('TIMER IS ALREADY ON SCREEN');
        Navigator.of(context, rootNavigator: true).pop();

        globals.timerDialogShowed = false;
        if (event.snapshot.key == 'status') {
          if (event.snapshot.value.toString() == 'Complete') {
            print('LOADING CLOSED 17');

            if (pr.isShowing()) {
              pr.hide();
            }

            gameCompleteDialog();
          }
        }
        if (event.snapshot.key == 'game-id') {
          // await Future.delayed(Duration(seconds: 2));
          await getData();

          print('DIALOG LOADING CALLED 1');
        }
      } else {
        print('ELSE CALLED IN FB UPDATE 2');
        if (event.snapshot.key == 'game-id') {
          //await Future.delayed(Duration(seconds: 2));
          await getData();

          print('DIALOG LOADING CALLED 1');
        }
      }
    }
  }

  Future getCountry() async {
    initialData = await _firebaseRef.once();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('country') == 'Pakistan')
      setState(() {
        showLangOption = true;
      });
    else
      setState(() {
        showLangOption = false;
      });
  }

  ///////////////////////////////////////////////////////////////CHECK FIREBASE FOR NEW GAME ON WIDGET RESUME
  Future getData() async {
    print('getData CALLED');
    await Future.delayed(Duration(seconds: 1));
    if (pr.isShowing()) await pr.hide();
    DataSnapshot snapshot =
        await FirebaseDatabase.instance.reference().child('next-game').once();
    if (snapshot.value != null) {
      await Future.wait([checkFBData(snapshot)],
          eagerError: true, cleanUp: (value) {});
    } else
      print('NO NEXT-GAME NODE EXIST');
  }

  Future checkFBData(DataSnapshot snapshot) async {
    print('DIALOG IS ON SCREEN? ${globals.timerDialogShowed}');
    print('GAME ENVIRONMENT: ${snapshot.value['env']}');
    if (snapshot.value['env'] == 'live') {
      globals.targetTime = snapshot.value['start-time'];
      if (snapshot.value['status'] == 'new') {
        /////////////////////////////////////////////////////////CLEAR PREFERENCE FOR EXCEPTION CASE
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String encryptGameID = prefs.getString('gameID');
        if (encryptGameID == null || encryptGameID == '') {
        } else {
          if (prefs.getString('startTime') == '' ||
              prefs.getString('startTime') == null) {
          } else {
            DateTime targetdateTime =
                globals.dateFormat.parse(prefs.getString('startTime'));
            String decryptedID = await GlobalsMethods.decryptGameID(
                targetdateTime.hour, targetdateTime.day, encryptGameID);
            if (decryptedID != snapshot.value['game-id'].toString()) {
              prefs.setString('gamePlayed', '');
              DateTime newTime =
                  globals.dateFormat.parse(snapshot.value['start-time']);
              String encryptedID = await GlobalsMethods.encryptGameID(
                  newTime.hour,
                  newTime.day,
                  snapshot.value['game-id'].toString());
              prefs.setString('gameID', encryptedID);
            }
          }
        }
        if (globals.timerDialogShowed) {
          Navigator.of(context, rootNavigator: true).pop();
          globals.timerDialogShowed = false;
        }
        if (pr.isShowing()) {
          await pr.hide();
        }
        if (!pr.isShowing()) await pr.show();
        await Future.wait([getNTPTime(snapshot)]);
      } else if (globals.timerDialogShowed) {
        print('STATUS IS COMPLETE');

        Navigator.of(context, rootNavigator: true).pop();
        globals.timerDialogShowed = false;
        if (pr.isShowing()) {
          await pr.hide();
        }

        globals.resumeCalledOnce = false;
        globals.updateCalledOnce = false;

        await gameCompleteDialog();
        print('GAME HAS BEEN COMPLETED');
      } else {
        print('LOADING CLOSED 21');
        globals.resumeCalledOnce = false;
        globals.updateCalledOnce = false;

        if (pr.isShowing()) {
          await pr.hide();
        }
      }
    } else {
      print('GAME ENVIRONMENT IS LIVE');
      print('LOADING CLOSED 22');
      globals.resumeCalledOnce = false;
      globals.updateCalledOnce = false;

      if (pr.isShowing()) {
        await pr.hide();
      }
    }
  }

  Future getNTPTime(snapshot) async {
    print('getNTPTime CALLED');
    try {
      await Future.wait([GlobalsMethods.getCurrentTime()],
              eagerError: true, cleanUp: (value) {})
          .then((value) async {
        print('TIME RECEIVED IN getNTPTime METHOD');
        await doTimeCalculation(snapshot);
      });
    } catch (e, s) {
      Crashlytics.instance.recordError(e, s, context: 'as an example');
    }
  }

  Future saveToPrefsForNewGame(
      DataSnapshot snapshot, DateTime targetDate) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String encryptedID = await GlobalsMethods.encryptGameID(
        targetDate.hour, targetDate.day, snapshot.value['game-id'].toString());

    prefs.setString('gamePlayed', '');
    prefs.setInt('attemptsUsed', 0);
    prefs.setDouble('percentNotifier', 0.0);
    prefs.setInt('cluesFound', 0);
    prefs.setString('cluesList', '');

    prefs.setString('gameID', encryptedID);
    prefs.setString('startTime', snapshot.value['start-time']);

    prefs.setBool('timerStarted', true);

    prefs.setString('puzzleID', snapshot.value['puzzleid'].toString());

    prefs.setString('game_type', snapshot.value['gametype']);

    prefs.setString('gamePlayed', '');
    prefs.setString('addedToGame', '');

    prefs.setString('gamePrizeEng', snapshot.value['prize']);
    prefs.setString('gamePrizeUrd', snapshot.value['prize-urdu']);
    prefs.setString('addedToPlayers', '');

    globals.puzZleID = snapshot.value['puzzleid'].toString();
  }

  Future doTimeCalculation(DataSnapshot snapshot) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    DateTime targetdateTime =
        globals.dateFormat.parse(snapshot.value['start-time']);
    String currentDate = globals.dateFormat.format(globals.currentTimeZone);
    DateTime datetimeFormatted = DateTime.parse(currentDate);

    Duration durationd = targetdateTime.difference(datetimeFormatted);

    if (!durationd.isNegative) {
      prefs.setString('gameLoaded', '');
      await Future.wait([saveToPrefsForNewGame(snapshot, targetdateTime)],
              eagerError: true, cleanUp: (value) {})
          .then((value) async {
        globals.dismissable = false;

        String prizeTxt = '';
        if (language == 'ur')
          prizeTxt = snapshot.value['prize-urdu'];
        else
          prizeTxt = snapshot.value['prize'];

        prefs.setString('gamePrizeEng', snapshot.value['prize']);
        prefs.setString('gamePrizeUrd', snapshot.value['prize-urdu']);

        print('LOADING CLOSED 25');

        if (pr.isShowing()) {
          await pr.hide();
        }
        await Future.delayed(Duration(milliseconds: 200));
        globals.timerDialogShowed = true;
        dialog(
          durationd.inSeconds.toString(),
          snapshot.value['start-time'],
          snapshot.value['puzzleid'].toString(),
          snapshot.value['game-id'].toString(),
          snapshot.value['gametype'],
          false,
          prizeTxt,
          '',
          '',
        );

        globals.puzZleID = snapshot.value['puzzleid'].toString();
      });
    } else {
      print('GAME PLAYED: ${prefs.getString('gamePlayed')}');

      if (prefs.getString('gamePlayed') == 'yes') {
        print('LOADING CLOSED 27');

        if (pr.isShowing()) {
          pr.hide();
        }

        globals.resumeCalledOnce = false;
        globals.updateCalledOnce = false;

        print('GAME HAS BEEN PLAYED BY ME');
      } else {
        await Future.wait([saveToPrefsForNewGame(snapshot, targetdateTime)],
                eagerError: true, cleanUp: (value) {})
            .then((value) async {
          globals.dismissable = true;

          String prizeTxt = '';
          if (language == 'ur')
            prizeTxt = snapshot.value['prize-urdu'];
          else
            prizeTxt = snapshot.value['prize'];

          print('LOADING CLOSED 26');

          if (pr.isShowing()) {
            await pr.hide();
          }
          await Future.delayed(Duration(milliseconds: 200));
          globals.timerDialogShowed = true;
          dialog(
            durationd.inSeconds.toString(),
            snapshot.value['start-time'],
            snapshot.value['puzzleid'].toString(),
            snapshot.value['game-id'].toString(),
            snapshot.value['gametype'],
            false,
            prizeTxt,
            '',
            '',
          );
        });
      }
    }
  }

  configureFCM() async {
    _fcm.configure(
      /////////////////////////////APP IS OPEN AND RUNNING IN FOREGROUND
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage HOME: $message");
        print(message['data']);

        if (message['data']['type'] == 'message') {
          print('MESSAGE RECEIVED');

          if (!globals.HOMEONFRONT) {
            print('MESSAGE CALLBACK CALLED');
          } else {
            setState(() {
              badgeCounter++;
            });

            GlobalsMethods.showNotification(message['notification']['title'],
                message['notification']['body'], 'MESSAGE');
          }
        } else if (message['data']['type'] == 'game_end' && !globals.iWinGame) {
          GlobalsMethods.showNotification(message['notification']['title'],
              message['notification']['body'], 'WINNER');
        } else {
          if (!globals.HOMEONFRONT) {
            if (globals.currentGame == 'mcq')
              globals.MCQGlobalKey.currentState.gameCancelDialog();
            else if (globals.currentGame == 'ftd')
              globals.ImgDiffGlobalKey.currentState.gameCancelDialog();
            else if (globals.currentGame == 'oddone')
              globals.OddOneGlobalKey.currentState.gameCancelDialog();
            else if (globals.currentGame == 'puzzle')
              globals.PuzzleGlobalKey.currentState.gameCancelDialog();
            else if (globals.currentGame == 'flip')
              globals.FlipGlobalKey.currentState.gameCancelDialog();
            else if (globals.currentGame == 'tab')
              globals.TapGlobalKey.currentState.gameCancelDialog();
            else if (globals.currentGame == 'jigsaw')
              globals.JigsawGlobalKey.currentState.gameCancelDialog();
            else if (globals.currentGame == 'shadow')
              globals.ShadowGlobalKey.currentState.gameCancelDialog();
            else if (globals.currentGame == 'tissue')
              globals.TissueGlobalKey.currentState.gameCancelDialog();
            else if (globals.currentGame == 'balloon')
              globals.BalloonsGlobalKey.currentState.gameCancelDialog();
            else if (globals.currentGame == 'scratch')
              globals.ScratchGlobalKey.currentState.gameCancelDialog();
          }
          globals.onHomeCalled = true;
          globals.dismissable = false;
        }
      },

      ///////////////// the app is fully terminated
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        // TODO optional
        print("onMessage: $message");
        print(message['data']);

        if (message['data']['type'] == 'message') {
        } else {}
      },
      ////////////// app is closed, but still running in the background
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        // TODO optional
        print("onMessage: $message");
        print(message['data']);

        if (message['data']['type'] == 'message') {
        } else {}
      },
    );
  }

  ///////////////////////////////////////////////////////////////TIMER DIALOG
  Future dialog(String sec, String targetTime, String puzzleID, gameID, type,
      bool barrieDismissable, String prize, String title, String body) async {
    print('DIALOG METHOD CALLED');
    globals.updateCalledOnce = false;
    globals.resumeCalledOnce = false;

    if (pr.isShowing()) {
      await pr.hide();
    }
    if (globals.HOMEONFRONT) {
      return showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: Opacity(
                opacity: a1.value,
                child: WillPopScope(
                  onWillPop: () async {
                    print('WILLPOP: ${globals.dismissable}');
                    if (globals.dismissable) {
                      print('WILLPOP CALLED');
                      globals.HOMEONFRONT = true;

                      globals.timerDialogShowed = false;
                      globals.resumeCalledOnce = false;
                      globals.updateCalledOnce = false;

                      Navigator.of(context, rootNavigator: true).pop();
                    }
                    return false;
                  },
                  child: dialogContent(sec, targetTime, puzzleID, gameID, type,
                      prize, title, body, context),
                )),
          );
        },
        transitionDuration: Duration(milliseconds: 150),
        barrierDismissible: barrieDismissable,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {},
      );
    }
  }

  Widget dialogContent(String sec, String targetTime, String puzzleID, gameID,
      type, String prize, String title, String body, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 0.0, right: 0.0),
      child: Dialog(
        //insetAnimationCurve: Curves.easeInOut,
        //insetAnimationDuration: Duration(milliseconds: 350),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * 0.02,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Container(
                //color: Colors.white,
                child: Container(
                  padding: EdgeInsets.only(top: 45),
                  child: PhysicalModel(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    elevation: 6,
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.12,
                        bottom: 5,
                        left: 5,
                        right: 5,
                      ),
                      child: Container(
                        child: Column(
                          //crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            CustomDialog(
                              timer: {
                                'sec': sec,
                                'target': targetTime,
                                'ID': puzzleID,
                                'gameID': gameID,
                                'game_type': type,
                                'prize': prize,
                                'title': title,
                                'body': body,
                              },
                            ),
                          ],
                        ),
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
                    radius: MediaQuery.of(context).size.height * 0.08,
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.14,
                        width: MediaQuery.of(context).size.height * 0.14,
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
                    //padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Container(
                      padding: EdgeInsets.only(top: 45),
                      child: Material(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                        child: Container(
                          padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.10,
                              left: 30,
                              right: 30,
                              bottom: 30),
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
                                        allTranslations.text('exit_from_game'),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      //margin: EdgeInsets.only(top: 20),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Container(
                                            margin: EdgeInsets.only(top: 30),
                                            child: Container(
                                              constraints: BoxConstraints(
                                                maxHeight:
                                                    MediaQuery.of(context)
                                                            .size
                                                            .height *
                                                        0.06,
                                              ),
                                              child: MaterialButton(
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
                                                      left: 20, right: 20),
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
                                                  exit(0);
                                                },
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 20, right: 20),
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

  Widget noGameAvailableDialog() {
    return Container(
      child: Dialog(
        insetAnimationDuration: Duration(seconds: 1),
        insetAnimationCurve: Curves.elasticInOut,
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
                child: Material(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  child: Container(
                    padding: EdgeInsets.only(
                        top: 80, left: 30, right: 30, bottom: 50),
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
                                  allTranslations.text('no_game'),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
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
    );
  }

  Future _onLocaleChanged() async {
    // do anything you need to do if the language changes
    print('Language has been changed to: ${allTranslations.currentLanguage}');
    setState(() {
      if (allTranslations.currentLanguage == 'ur') {
        lang = 'English';
        language = 'ur';
        langNotifier.value = language;
        globals.currentLan = language;
      } else {
        lang = 'اردو';
        language = 'en';
        langNotifier.value = language;
        globals.currentLan = language;
      }
    });
  }

  Widget nextGame2Widget() {
    return nextGame2 != null
        ? Padding(
            padding: EdgeInsets.only(left: 30, right: 30, top: 10),
            child: GestureDetector(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.60,
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
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 10,
                      left: 5,
                      right: 5,
                      bottom: 10,
                    ),
                    child: Container(
                      //height: MediaQuery.of(context).size.height * 0.11,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.26,
                                  child: Column(
                                    children: <Widget>[
                                      AutoDirection(
                                        text: language == 'ur'
                                            ? nextGame2.gamePrizeUrd
                                            : nextGame2.gamePrizeEng,
                                        child: Text(
                                          language == 'ur'
                                              ? nextGame2.gamePrizeUrd
                                              : nextGame2.gamePrizeEng,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                            fontFamily: 'Futura',
                                            height: 1.2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 10),
                                  alignment: Alignment.center,
                                  child: SizedBox(
                                    height: 55,
                                    width: 55,
                                    child: CachedNetworkImage(
                                      fit: BoxFit.fill,
                                      imageUrl: nextGame2.screenshot,
                                      placeholder: (context, url) => Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
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
                ),
              ),
              onTap: () {
                String title = '';
                String popupText = '';
                if (language == 'ur') {
                  title = nextGame2.gamePrizeUrd;
                  popupText = dashbordTextUrd;
                } else {
                  title = nextGame2.gamePrizeEng;
                  popupText = dashbordTextEng;
                }

                game2Dialog(
                    title, game2parsedTime, nextGame2.screenshot, popupText);
              },
            ),
          )
        : SizedBox();
  }

  Widget nextGameWidget() {
    return nextGame != null
        ? Padding(
            padding: EdgeInsets.only(left: 40, right: 40),
            child: GestureDetector(
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
                      //height: MediaQuery.of(context).size.height * 0.14,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            // color: Colors.blue[100],
                            width: double.infinity,
                            alignment: Alignment.topCenter,
                            child: ScaleTransition(
                              scale: animation,
                              child: Text(
                                allTranslations.text('next_game'),
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
                          Container(
                            alignment: Alignment.topCenter,
                            margin: EdgeInsets.only(top: 10),
                            //color: Colors.blue[200],
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  alignment: Alignment.center,
                                  child: Icon(
                                    PuzzleIcons.alarm_clock,
                                    color: Colors.black,
                                    size: MediaQuery.of(context).size.height *
                                        0.025,
                                  ),
                                ),
                                Container(
                                  //  color: Colors.blue[300],

                                  alignment: Alignment.centerLeft,
                                  margin: EdgeInsets.only(left: 15, top: 0),
                                  child: Text(
                                    parsedTime,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Futura',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.only(top: 5),
                            child: AutoDirection(
                              text: language == 'ur'
                                  ? allTranslations.text('play_win') +
                                      nextGame.gamePrizeUrd
                                  : allTranslations.text('play_win') +
                                      nextGame.gamePrizeEng,
                              child: Text(
                                language == 'ur'
                                    ? allTranslations.text('play_win') +
                                        nextGame.gamePrizeUrd
                                    : allTranslations.text('play_win') +
                                        nextGame.gamePrizeEng,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black,
                                  //fontWeight: FontWeight.w700,
                                  fontStyle: FontStyle.italic,
                                  fontSize: 13,
                                  fontFamily: 'Futura',
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
              onTap: () {
                String title = '';
                if (language == 'ur')
                  title =
                      allTranslations.text('play_win') + nextGame.gamePrizeUrd;
                else
                  title =
                      allTranslations.text('play_win') + nextGame.gamePrizeEng;

                nextGameDialog(title, parsedTime);
              },
            ),
          )
        : SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
      child: ModalProgressHUD(
          child: SafeArea(
            top: false,
            child: Scaffold(
              key: _scaffoldKey,
              resizeToAvoidBottomPadding: true,
              drawer: SideDrawer(),
              bottomNavigationBar: BottomNavigationBar(
                backgroundColor: Colors.black,
                type: BottomNavigationBarType.fixed,
                showSelectedLabels: false,
                showUnselectedLabels: false,
                iconSize: 25,
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(
                      PuzzleIcons.thumbs_up_hand_symbol,
                      color: Color(0xffeccb58),
                    ),
                    title: Container(
                      height: 10,
                    ),
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      PuzzleIcons.share,
                      color: Color(0xffeccb58),
                    ),
                    title: Container(
                      height: 10,
                    ),
                  ),
                  BottomNavigationBarItem(
                    icon: badgeCounter == 0
                        ? Icon(
                            PuzzleIcons.live_chat,
                            color: Color(0xffeccb58),
                          )
                        : Badge(
                            badgeContent: Text(badgeCounter.toString()),
                            badgeColor: Colors.white,
                            child: Icon(
                              PuzzleIcons.live_chat,
                              color: Color(0xffeccb58),
                            ),
                          ),
                    title: Container(
                      height: 10,
                    ),
                  ),
                ],
                onTap: (index) async {
                  if (index == 2) {
                    globals.HOMEONFRONT = false;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FBMessagesScreen(),
                      ),
                    );
                  } else if (index == 1) {
                    Share.share('Win prizes with WinDiggy http://windiggy.com/',
                        subject: 'Try this new App');
                  } else {
                    const url =
                        'https://www.facebook.com/Money-Gali-105238564318974/';
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      throw 'Could not launch $url';
                    }
                  }
                },
              ),
              body: Builder(
                builder: (context) => Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    Container(
                      height: double.infinity,
                      width: double.infinity,
                      color: Colors.black,
                      child: Image(
                        image: AssetImage('assets/glitters.gif'),
                        fit: BoxFit.fill,
                      ),
                    ),
                    //addGlitter(),
                    new Positioned(
                      top: 0.0,
                      left: 0.0,
                      right: 0.0,
                      child: AppBar(
                        elevation: 0,
                        backgroundColor: Colors.transparent,
                        actions: <Widget>[
                          showLangOption
                              ? FlatButton(
                                  onPressed: () async {
                                    await allTranslations.setNewLanguage(
                                        language == 'ur' ? 'en' : 'ur');
                                    setState(() {});
                                  },
                                  child: Text(
                                    lang,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )
                              : SizedBox(),
                        ],
                      ),
                    ),
                    new Positioned(
                      top: 0.0,
                      left: 0,
                      right: 0,
                      child: Container(
                        margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.05,
                        ),

                        alignment: Alignment.center,
                        // color: Colors.blue[100],
                        child: CircleAvatar(
                          radius: MediaQuery.of(context).size.height * 0.06,
                          backgroundColor: Colors.transparent,
                          child: SizedBox(
                            child: Image.asset(
                              'assets/logo.png',
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.17,
                      ),
                      child: StreamBuilder(
                        stream: _firebaseRef.onValue,
                        initialData: initialData,
                        builder: (context, snap) {
                          print('HOME DATA: $snap');
                          if (snap.hasError) {
                            return Text('Error');
                          }
                          if (snap.connectionState == ConnectionState.waiting)
                            return new Center(
                                child: new CircularProgressIndicator());
                          if (snap.hasData &&
                              !snap.hasError &&
                              snap.data.snapshot.value != null) {
                            //print('FB DATA: ${snap.data.snapshot.value['games']}');
                            if (snap.data.snapshot.value.containsKey('games')) {
                              parseDashboardGames(snap.data.snapshot);
                            }
                            if (snap.data.snapshot.value
                                .containsKey('dailycontestbutton')) {
                              if (snap.data.snapshot
                                      .value['dailycontestbutton'] ==
                                  '2')
                                showContest = true;
                              else
                                showContest = false;
                            } else
                              showContest = false;

                            if (snap.data.snapshot.value.containsKey('bonus')) {
                              if (snap.data.snapshot.value['bonus']['show'] ==
                                  '1') {
                                showBonusGame = true;
                                bonusTextEng =
                                    snap.data.snapshot.value['bonus']['text'];
                                bonusTextUrd = snap.data.snapshot.value['bonus']
                                    ['text-urdu'];
                              } else
                                showBonusGame = false;
                            } else
                              showBonusGame = false;

                            if (snap.data.snapshot.value
                                .containsKey('dashboard')) {
                              parseFutureGame(snap.data.snapshot);
                            } else
                              nextGame2 = null;
                            if (snap.data.snapshot.value
                                .containsKey('nextgame')) {
                              parseNextGame(snap.data.snapshot);
                            } else
                              nextGame = null;

                            return Column(
                              //mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                nextGameWidget(),
                                nextGame2Widget(),
                                showBonusGame ? bonusGameWidget() : SizedBox(),
                                games.length == 0
                                    ? SizedBox()
                                    : Expanded(
                                        child: Container(
                                          alignment: Alignment.bottomCenter,
                                          child: Container(
                                            //  color: Colors.blue[500],
                                            margin: EdgeInsets.only(top: 15),
                                            padding: EdgeInsets.all(0.0),
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.45,
                                            child:
                                                SingleChildScrollViewWithScrollbar(
                                              scrollbarColor: Color(0xffeccb58),
                                              scrollbarThickness: 5.0,
                                              child: Container(
                                                // color: Colors.blue[100],
                                                padding: EdgeInsets.only(
                                                  left: 12,
                                                  right: 12,
                                                  bottom: 10,
                                                  top: 0,
                                                ),
                                                child: ListView.builder(
                                                  padding: EdgeInsets.all(0.0),
                                                  physics:
                                                      NeverScrollableScrollPhysics(),
                                                  shrinkWrap: true,
                                                  itemCount: games.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return SingleGameView(
                                                      gameTitle: (index + 1)
                                                          .toString(),
                                                      prizeEng: games[index]
                                                          .gamePrizeEng,
                                                      prizeUrd: games[index]
                                                          .gamePrizeUrd,
                                                      time: games[index]
                                                          .startTime,
                                                      next: games[index].next,
                                                      winner: games[index]
                                                          .winnerNaame,
                                                      status:
                                                          games[index].status,
                                                      langNotifier:
                                                          langNotifier,
                                                      bonusGame: games[index]
                                                          .bonusGame,
                                                      index: games[index].index,
                                                      showGame:
                                                          games[index].showGame,
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                widget.serverData['blocked']
                                    ? BottomSlider()
                                    : SizedBox()
                              ],
                            );
                          } else {
                            nextGame2 = null;
                            nextGame = null;
                            return Column(
                              children: <Widget>[
                                nextGameWidget(),
                                nextGame2Widget(),
                                showBonusGame ? bonusGameWidget() : SizedBox(),
                                SizedBox(),
                                widget.serverData['blocked']
                                    ? BottomSlider()
                                    : SizedBox()
                              ],
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          inAsyncCall: false),
      onWillPop: () async {
        if (!pr.isShowing()) closeDialog();
        return false;
      },
    );
  }

  Widget bonusGameWidget() {
    return Container(
      margin: EdgeInsets.only(top: 5, left: 85, right: 85),
      height: 82,
      // width: 200,
      child: BonusView(
        bonusTextEng,
        bonusTextUrd,
        langNotifier,
      ),
    );
  }

  Future parseNextGame(DataSnapshot data) async {
    print('NEXTGAME NODE PARSED');
    nextGame = Game(
      gameID: data.value['nextgame']['id'],
      gamePrizeEng: data.value['nextgame']['Prize'],
      gamePrizeUrd: data.value['nextgame']['prize_urdu'],
      gameType: '',
      gameStatus: '',
      wonBy: '',
      screenshot: '',
      finishTime: '',
      startTime: data.value['nextgame']['start_time'],
      winnerNaame: '',
      next: true,
      status: '',
      winEngMsg: '',
      winUrdMsg: '',
    );
    DateTime targetdateTime = globals.dateFormat.parse(nextGame.startTime);
    parsedTime = DateFormat.jm().format(targetdateTime);
  }

  Future parseFutureGame(DataSnapshot data) async {
    print('DASHBOARD NODE PARSED');
    dashbordTextEng = data.value['dashboard']['popup_english'];
    dashbordTextUrd = data.value['dashboard']['popup_urdu'];

    nextGame2 = Game(
      gameID: data.value['dashboard']['id'],
      gamePrizeEng: data.value['dashboard']['english'],
      gamePrizeUrd: data.value['dashboard']['urdu'],
      gameType: '',
      gameStatus: '',
      wonBy: '',
      screenshot: data.value['dashboard']['image'],
      finishTime: '',
      startTime: data.value['dashboard']['timestamp'],
      winnerNaame: '',
      next: true,
      status: '',
    );
    DateTime nextGame2DT = globals.dateFormat.parse(nextGame2.startTime);
    game2parsedTime = DateFormat.yMMMd("en_US").format(nextGame2DT);
  }

  Future parseDashboardGames(DataSnapshot data) async {
    print('GAMES LIST PARSED');

    games = new List();

    bool bonusgame = false;
    int gameIndex = 1;
    for (Map<dynamic, dynamic> game in data.value['games']) {
      if (game['game_push'] == 'game')
        bonusgame = false;
      else
        bonusgame = true;
      if (game['status'] == "complete") {
        DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
        DateTime targetdateTime = dateFormat.parse(game['start_time']);
        String parsedTime = DateFormat.jm().format(targetdateTime);
        if (game.containsKey('winner_profile')) {
          if (!bonusgame)
            games.add(
              Game(
                gameID: game['gameid'],
                gamePrizeEng: game['Prize'],
                gamePrizeUrd: game['prize_urdu'],
                gameType: game['type'],
                gameStatus: game['status'],
                wonBy: game['wonby_id'],
                screenshot: game['screenshoot'],
                finishTime: game['time_finish'],
                startTime: parsedTime,
                winnerNaame: game['winner_profile']['username'],
                next: game['next'],
                status: game['status'],
                winEngMsg: '',
                winUrdMsg: '',
                winners: [],
                bonusGame: false,
                index: gameIndex,
                showGame: true,
              ),
            );
          else
            games.add(
              Game(
                gameID: game['gameid'],
                gamePrizeEng: game['Prize'],
                gamePrizeUrd: game['prize_urdu'],
                gameType: game['type'],
                gameStatus: game['status'],
                wonBy: game['wonby_id'],
                screenshot: game['screenshoot'],
                finishTime: game['time_finish'],
                startTime: parsedTime,
                winnerNaame: game['winner_profile']['username'],
                next: game['next'],
                status: game['status'],
                winEngMsg: '',
                winUrdMsg: '',
                winners: [],
                bonusGame: true,
                index: 0,
                showGame: true,
              ),
            );
        } else {
          if (!bonusgame)
            games.add(
              Game(
                gameID: game['gameid'],
                gamePrizeEng: game['Prize'],
                gamePrizeUrd: game['prize_urdu'],
                gameType: game['type'],
                gameStatus: game['status'],
                wonBy: game['wonby_id'],
                screenshot: '',
                finishTime: '',
                startTime: parsedTime,
                winnerNaame: '',
                next: game['next'],
                status: game['status'],
                winEngMsg: '',
                winUrdMsg: '',
                winners: [],
                bonusGame: false,
                index: gameIndex,
                showGame: true,
              ),
            );
          else
            games.add(
              Game(
                gameID: game['gameid'],
                gamePrizeEng: game['Prize'],
                gamePrizeUrd: game['prize_urdu'],
                gameType: game['type'],
                gameStatus: game['status'],
                wonBy: game['wonby_id'],
                screenshot: '',
                finishTime: '',
                startTime: parsedTime,
                winnerNaame: '',
                next: game['next'],
                status: game['status'],
                winEngMsg: '',
                winUrdMsg: '',
                winners: [],
                bonusGame: true,
                index: 0,
                showGame: true,
              ),
            );
        }
      } else if (game['status'] == "new") {
        DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
        DateTime targetdateTime = dateFormat.parse(game['start_time']);
        String parsedTime = DateFormat.jm().format(targetdateTime);
        if (!bonusgame)
          games.add(
            Game(
              gameID: game['gameid'],
              gamePrizeEng: game['Prize'],
              gamePrizeUrd: game['prize_urdu'],
              gameType: game['type'],
              gameStatus: game['status'],
              wonBy: game['wonby_id'],
              screenshot: game['screenshoot'],
              finishTime: game['time_finish'],
              startTime: parsedTime,
              winnerNaame: '',
              next: game['next'],
              status: game['status'],
              winUrdMsg: '',
              winEngMsg: '',
              winners: [],
              bonusGame: false,
              index: gameIndex,
              showGame: true,
            ),
          );
        else
          games.add(
            Game(
              gameID: game['gameid'],
              gamePrizeEng: game['Prize'],
              gamePrizeUrd: game['prize_urdu'],
              gameType: game['type'],
              gameStatus: game['status'],
              wonBy: game['wonby_id'],
              screenshot: game['screenshoot'],
              finishTime: game['time_finish'],
              startTime: parsedTime,
              winnerNaame: '',
              next: game['next'],
              status: game['status'],
              winUrdMsg: '',
              winEngMsg: '',
              winners: [],
              bonusGame: true,
              index: 0,
              showGame: false,
            ),
          );
      } else if (game['status'] == "Canceled") {
        DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
        DateTime targetdateTime = dateFormat.parse(game['start_time']);
        String parsedTime = DateFormat.jm().format(targetdateTime);
        if (!bonusgame)
          games.add(
            Game(
              gameID: game['gameid'],
              gamePrizeEng: game['Prize'],
              gamePrizeUrd: game['prize_urdu'],
              gameType: game['type'],
              gameStatus: game['status'],
              wonBy: game['wonby_id'],
              screenshot: game['screenshoot'],
              finishTime: game['time_finish'],
              startTime: parsedTime,
              winnerNaame: '',
              next: game['next'],
              status: game['status'],
              winUrdMsg: '',
              winEngMsg: '',
              winners: [],
              bonusGame: false,
              index: gameIndex,
              showGame: true,
            ),
          );
        else
          games.add(
            Game(
              gameID: game['gameid'],
              gamePrizeEng: game['Prize'],
              gamePrizeUrd: game['prize_urdu'],
              gameType: game['type'],
              gameStatus: game['status'],
              wonBy: game['wonby_id'],
              screenshot: game['screenshoot'],
              finishTime: game['time_finish'],
              startTime: parsedTime,
              winnerNaame: '',
              next: game['next'],
              status: game['status'],
              winUrdMsg: '',
              winEngMsg: '',
              winners: [],
              bonusGame: true,
              index: 0,
              showGame: false,
            ),
          );
      } else if (game['status'] == "disqualified") {
        DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
        DateTime targetdateTime = dateFormat.parse(game['start_time']);
        String parsedTime = DateFormat.jm().format(targetdateTime);
        if (!bonusgame)
          games.add(
            Game(
              gameID: game['gameid'],
              gamePrizeEng: game['Prize'],
              gamePrizeUrd: game['prize_urdu'],
              gameType: game['type'],
              gameStatus: game['status'],
              wonBy: game['wonby_id'],
              screenshot: game['screenshoot'],
              finishTime: game['time_finish'],
              startTime: parsedTime,
              winnerNaame: '',
              next: game['next'],
              status: game['status'],
              winUrdMsg: '',
              winEngMsg: '',
              winners: [],
              bonusGame: false,
              index: gameIndex,
              showGame: true,
            ),
          );
        else
          games.add(
            Game(
              gameID: game['gameid'],
              gamePrizeEng: game['Prize'],
              gamePrizeUrd: game['prize_urdu'],
              gameType: game['type'],
              gameStatus: game['status'],
              wonBy: game['wonby_id'],
              screenshot: game['screenshoot'],
              finishTime: game['time_finish'],
              startTime: parsedTime,
              winnerNaame: '',
              next: game['next'],
              status: game['status'],
              winUrdMsg: '',
              winEngMsg: '',
              winners: [],
              bonusGame: true,
              index: 0,
              showGame: false,
            ),
          );
      }
      if (!bonusgame) gameIndex++;
    }
  }

  Future game2Dialog(
      String title, String timestamp, String image, String popupText) {
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
                    //padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Container(
                      padding: EdgeInsets.only(top: 45),
                      child: Material(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                        child: Container(
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.08,
                            left: 30,
                            right: 30,
                            bottom: 30,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.only(top: 5, bottom: 0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.35,
                                            child: Column(
                                              children: <Widget>[
                                                Text(
                                                  popupText,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 18,
                                                    fontFamily: 'Futura',
                                                    height: 1.5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
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
        );
      },
      transitionDuration: Duration(milliseconds: 150),
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      pageBuilder: (context, animation1, animation2) {},
    );
  }

  Future nextGameDialog(String title, String timestamp) {
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
                    //padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Container(
                      padding: EdgeInsets.only(top: 45),
                      child: Material(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                        child: Container(
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.08,
                            left: 30,
                            right: 30,
                            bottom: 30,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.only(top: 5, bottom: 0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        allTranslations.text('next_game'),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.grey[800],
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Futura',
                                        ),
                                      ),
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      margin: EdgeInsets.only(top: 8),
                                      child: Text(
                                        timestamp,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Theme.of(context).accentColor,
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Futura',
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: 10),
                                      alignment: Alignment.center,
                                      child: Text(
                                        title,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                          fontFamily: 'Futura',
                                          height: 1.5,
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
        );
      },
      transitionDuration: Duration(milliseconds: 150),
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      pageBuilder: (context, animation1, animation2) {},
    );
  }

  Future configureLocalNotification() {
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
        AndroidInitializationSettings('ic_app_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
    globals.flutterLocalNotificationsPlugin =
        this.flutterLocalNotificationsPlugin;
  }

  //////////////////////////////////////////////WHEN NOTIFICATION IS TAPPED FROM NOTIFICATION TRAY
  Future<void> onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    if (payload == 'NOT STARTED') {
      if (!globals.HOMEONFRONT) {
        ///////////////////////////////OPEN HOME SCREEN IF GAME NOT STARTED
        exit(0);

        main();
      }
    } else if (payload == 'MESSAGE') {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FBMessagesScreen()),
      );
    } else if (payload == 'WINNER') {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => WinnersScreen()),
      );
    } else {
      if (!globals.HOMEONFRONT) {
        ///////////////////////////////OPEN HOME SCREEN IF GAME NOT STARTED
        exit(0);

        main();
      }
    }
  }

  Future<void> onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    if (payload == 'NOT STARTED') {
      if (!globals.HOMEONFRONT) {
        ///////////////////////////////OPEN HOME SCREEN IF GAME NOT STARTED
        exit(0);

        main();
      }
    } else if (payload == 'MESSAGE') {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FBMessagesScreen()),
      );
    } else if (payload == 'WINNER') {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => WinnersScreen()),
      );
    } else {
      if (!globals.HOMEONFRONT) {
        ///////////////////////////////OPEN HOME SCREEN IF GAME NOT STARTED
        exit(0);
        main();
      }
    }
  }

  Future gameCompleteDialog() async {
    print('GAME COMPLETED DIALOG IN HOME SCREEN');

    _cancelAllNotifications();

    globals.timerDialogShowed = false;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    ///////////////////////////////////RESET PREFERENCES
    // prefs.setString('dialogOnScreen', '');

    //prefs.setString('targetTime', '');
    prefs.setBool('timerStarted', false);
    prefs.setString('puzzleID', '');
    prefs.setString('gamePlayed', 'yes');
    globals.resumeCalledOnce = false;
    globals.updateCalledOnce = false;

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
                            bottom: 40,
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
                                  text: allTranslations.text('game_completed'),
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
        );
      },
      transitionDuration: Duration(milliseconds: 150),
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      pageBuilder: (context, animation1, animation2) {},
    );
  }

  //////////////////////////////////////////////////////////CANCEL ALL PREVIOUS NOTIFICATION IF NEW GAME ADDED
  Future<void> _cancelAllNotifications() async {
    await globals.flutterLocalNotificationsPlugin.cancelAll();
  }
}
