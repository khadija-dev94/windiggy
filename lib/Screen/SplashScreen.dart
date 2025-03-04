import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trust_fall/trust_fall.dart';
import 'package:win_diggy/Globals.dart' as globals;
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => new _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String screenName;

  @override
  void initState() {
    super.initState();
    ///////////////////////////////////////////////////////CEHCK UPDATE AVAILABLE OR NOT

    startTime();
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _showVersionDialog(context) async {
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String title = "New Update Available";
        String message =
            "There is a newer version of app available please update it now.";
        String btnLabel = "Update Now";
        return Platform.isIOS
            ? new CupertinoAlertDialog(
                title: Text(title),
                content: Text(message),
                actions: <Widget>[
                  FlatButton(
                    child: Text(btnLabel),
                    onPressed: () => _launchURL(globals.APP_STORE_URL),
                  ),
                ],
              )
            : new AlertDialog(
                title: Text(title),
                content: Text(message),
                actions: <Widget>[
                  FlatButton(
                    child: Text(btnLabel),
                    onPressed: () => _launchURL(globals.PLAY_STORE_URL),
                  ),
                ],
              );
      },
    );
  }

  Future _showRootedDialog(context) async {
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String message =
            "Your device has been rooted. You cannot use this app.";
        String btnLabel = "Exit";
        return Platform.isIOS
            ? new CupertinoAlertDialog(
                content: Text(message),
                actions: <Widget>[
                  FlatButton(
                    child: Text(btnLabel),
                    onPressed: () {
                      Navigator.pop(context);
                      exit(0);
                    },
                  ),
                ],
              )
            : new AlertDialog(
                content: Text(message),
                actions: <Widget>[
                  FlatButton(
                    child: Text(btnLabel),
                    onPressed: () {
                      Navigator.pop(context);
                      exit(0);
                    },
                  ),
                ],
              );
      },
    );
  }

  Future navigationPage() async {
    versionCheck(context);
  }

  Future versionCheck(context) async {
    //Get Current installed version of app
    final PackageInfo info = await PackageInfo.fromPlatform();
    double currentVersion =
        double.parse(info.version.trim().replaceAll(".", ""));

    print('CURRENT VERSION: $currentVersion');
    globals.currentAppVersion = currentVersion;
    //Get Latest version info from firebase config
    final RemoteConfig remoteConfig = await RemoteConfig.instance;

    try {
      // Using default duration to force fetching from remote server.
      await remoteConfig.fetch(expiration: const Duration(seconds: 0));
      await remoteConfig.activateFetched();
      remoteConfig.getString('force_update_current_version');
      double newVersion = double.parse(remoteConfig
          .getString('force_update_current_version')
          .trim()
          .replaceAll(".", ""));
      globals.firebaseAppVersion = newVersion;
      print('firebase VERSION: ${globals.firebaseAppVersion}');

      if (newVersion > currentVersion) {
        _showVersionDialog(context);
      } else {
        bool isJailBroken = await TrustFall.isJailBroken;
        if (!isJailBroken) {
          print('THIS DEVICE IS NOT ROOTED');
          globals.onceInserted = false;
          globals.HOMEONFRONT = true;
          Navigator.of(context).pushReplacementNamed(screenName);
        } else
          _showRootedDialog(context);
      }
    } on FetchThrottledException catch (exception) {
      // Fetch throttled.
      print('FetchTrottledException:$exception');
    } catch (exception) {
      print('Unable to fetch remote config. Cached or default values will be '
          'used :$exception');
    }
  }

  startTime() async {
    await checkLoginStatus();

    var _duration = new Duration(seconds: 3);
    return new Timer(_duration, navigationPage);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: SafeArea(
        top: false,
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: Colors.black,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                child: Image.asset(
                  'assets/logo_text.png',
                  height: MediaQuery.of(context).size.height * 0.28,
                  width: MediaQuery.of(context).size.height * 0.28,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool status = prefs.getBool('loggedIn');

    print('LOGIN STATUS: $status');
    if (status != null && status) {
      globals.userID = prefs.getString('id');
      globals.country = prefs.getString('country');
      globals.username = prefs.getString('username');
      globals.profileURL = prefs.getString('profilePic');
      globals.LoggedIn = true;

      print('PROFILE PIC: ${globals.userID}');

      screenName = '/dashboard';
    } else {
      globals.LoggedIn = false;
      screenName = '/startupscreen';
    }
  }
}
