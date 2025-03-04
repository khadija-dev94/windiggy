import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:win_diggy/Globals.dart' as globals;
import 'package:win_diggy/Screen/DashBoard.dart';

class FirebaseNotifications {
  FirebaseMessaging _fcm;
  VoidCallback callHomeDialog;
  var homePage;

  void setUpFirebase(callbacl) {
    _fcm = FirebaseMessaging();
    homePage = callbacl;
    firebaseCloudMessaging_Listeners();
  }

  void firebaseCloudMessaging_Listeners() async {}
}
