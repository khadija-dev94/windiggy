import 'dart:async';
import 'dart:io';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:win_diggy/Screen/DashBoard.dart';
import 'package:win_diggy/Screen/PhoneNoScreen.dart';
import 'package:win_diggy/Screen/ProfileScreen.dart';
import 'package:win_diggy/Screen/StartupScreen.dart';
import 'package:win_diggy/Screen/DailyContestScreen.dart';
import 'package:win_diggy/Screen/DailyGames/WSGamePlayScreen.dart';
import 'package:provider/provider.dart';

import 'Models/ConnectivityStatus.dart';
import 'Models/GlobalTranslations.dart';
import 'Models/NetworkConnectivity.dart';
import 'Screen/Contest24HrScreen.dart';
import 'Screen/DailyContestSingleGameScreen.dart';
import 'Screen/FBMessagesScreen.dart';
import 'package:win_diggy/Screen/DailyGames/ImageDiffScreen.dart';
import 'Screen/SplashScreen.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.black, //top bar color
    statusBarIconBrightness: Brightness.dark, //top bar icons
    //systemNavigationBarColor: Colors.white, //bottom bar color
    systemNavigationBarIconBrightness: Brightness.dark, //bottom bar icons
  ));

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp
  ]) //////////////////LOCK SCREEN ORIENTATION
      .then(
    (_) async {
      await allTranslations.init();

      Crashlytics.instance.enableInDevMode = false;

      bool isInDebugMode = false;
      // Pass all uncaught errors to Crashlytics.
      FlutterError.onError = (FlutterErrorDetails details) {
        if (isInDebugMode) {
          // In development mode simply print to console.
          FlutterError.dumpErrorToConsole(details);
        } else {
          // In production mode report to the application zone to report to
          // Crashlytics.
          Zone.current.handleUncaughtError(details.exception, details.stack);
        }
      };
      FlutterError.onError = Crashlytics.instance.recordFlutterError;

      runZoned(() {
        runApp(
          StreamProvider<ConnectivityStatus>(
            builder: (context) =>
                ConnectivityService().connectionStatusController,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              routes: <String, WidgetBuilder>{
                '/dashboard': (BuildContext context) => DashBoard(),
                '/startup': (BuildContext context) => SrartupScreen(),
                '/playscreen': (BuildContext context) => WSGamePlayPage(),
                '/imgDiffscreen': (BuildContext context) => ImageDiffScreen(),
                '/profile': (BuildContext context) => ProfileScreen(),
                '/startupscreen': (BuildContext context) => SrartupScreen(),
                '/loginscreen': (BuildContext context) => PhoneNoScreen(),
                '/messagescreen': (BuildContext context) => FBMessagesScreen(),
                '/dailyContestScreen': (BuildContext context) =>
                    DailyContestSingleGameScreen(),
                '/24hrContestScreen': (BuildContext context) =>
                    SecondContestScreen(),
              },
              localizationsDelegates: [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              //supportedLocales: allTranslations.supportedLocales(),
              supportedLocales: [
                Locale("en", "US"),
                Locale("ur", "PK"),
              ],
              theme: ThemeData(
                // This is the theme of your application.
                //
                // Try running your application with "flutter run". You'll see the
                // application has a blue toolbar. Then, without quitting the app, try
                // changing the primarySwatch below to Colors.green and then invoke
                // "hot reload" (press "r" in the console where you ran "flutter run",
                // or simply save your changes to "hot reload" in a Flutter IDE).
                // Notice that the counter didn't reset back to zero; the application
                // is not restarted.
                primaryColor: Color(0xff5c4710),
                accentColor: Color(0xffeccb58),
              ),
              home: SplashScreen(),
            ),
          ),
        );
      }, onError: Crashlytics.instance.recordError);
    },
  );
}
