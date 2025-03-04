import 'dart:convert';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:win_diggy/Screen/DailyGames/QuizScreen.dart';
import 'package:win_diggy/Screen/DailyGames/ImageDiffScreen.dart';
import 'package:win_diggy/Screen/DailyGames/PickOddGameScreen.dart';

import 'package:win_diggy/Screen/DailyGames/FlipGameScreen.dart';
import 'package:win_diggy/Screen/DailyGames/TapTapScreen.dart';
import 'package:win_diggy/Screen/DailyGames/WSGamePlayScreen.dart';

import 'Screen/DailyGames/BalloonsGame.dart';
import 'Screen/DailyGames/JigsawPuzzleGame.dart';
import 'Screen/DailyGames/ScratchCardGame.dart';
import 'Screen/DailyGames/ShadowGame.dart';
import 'Screen/DailyGames/TissueBoxGame.dart';

List<String> words = new List();
bool permissionStatus;
String username = 'John Michael';
String contact = '';
String profileURL = '';
File temImage = null;
String base64Image = '';
bool loggedIn = false;
int boxPosition = 0;
double height = 0.0;
double width = 0.0;
String userID = '';
String puzZleID = '';
const APP_STORE_URL = '';
const PLAY_STORE_URL =
    'https://play.google.com/store/apps/details?id=com.windiggy.win_diggy';
bool launchApp = true;
GlobalKey key;
GlobalKey<MSQSViewState> MCQGlobalKey;
GlobalKey<DrawingViewState> ImgDiffGlobalKey;
GlobalKey<OddOneDrawingViewState> OddOneGlobalKey;
GlobalKey<StateWSGamePlayPage> PuzzleGlobalKey;
GlobalKey<TapTapInnerViewState> TapGlobalKey;
GlobalKey<InnerViewFlipState> FlipGlobalKey;
GlobalKey<ShadowViewState> ShadowGlobalKey;
GlobalKey<TissueBoxViewState> TissueGlobalKey;
GlobalKey<BalloonViewState> BalloonsGlobalKey;
GlobalKey<ScratchCardViewState> ScratchGlobalKey;
GlobalKey<JigsawViewState> JigsawGlobalKey;


String currentGame = '';

String country = '';
String initials = '';
bool HOMEONFRONT = true;
bool iWinGame = false;
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
bool showUpdateDialog = false;
bool gameCompleted = false;
bool onHomeCalled = false;
bool onceInserted = false;
DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");

String dataLoaded = 'no';
bool dismissable = false;
bool correctDeviceTime = true;
bool gameEnded = false;
DateTime currentTimeZone;
String hours = '';
String min = '';
String sec = '';
FirebaseMessaging fcm;
bool dialogOnScreen = false;
var updateListener = null;

int userEnterTime = 0;
bool LoggedIn = false;
Offset selectedRect;
int index = 0;
bool timerDialogShowed = false;
bool updateCalledOnce = false;
bool resumeCalledOnce = false;

bool loadingGameData = false;
var currentAppVersion;
String targetTime;
String myDailyCount = '';
const encryptKey = "u1BvOHzUOcklgNpn1MaWvdn9DT4LyzSX";
const iv = "12345678";
String dailyContestGameID='';
String fdbUrl2 = "https://puzzle-34184-9fd14.firebaseio.com/";
String userPosition='';
String userScore='0';
bool dailyContestTissueEnabled=false;
String currentLan='';
var firebaseAppVersion;