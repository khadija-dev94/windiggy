import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:win_diggy/Globals.dart' as globals;

class GlobalsMethods {
  static Future<DateTime> fetchCurrentTime(http.Client client) async {
    try {
      var url = "https://us-central1-puzzle-34184.cloudfunctions.net/api";
      final response = await client.get(url);
      if (response.statusCode == 200) {
        print("CLOUD FUNCTION RESPONSE");
        print(response.body);
        DateTime currentDateTime =
            DateFormat("M/dd/yyyy, h:mm:ss a").parse(response.body);
        print(
            'CLOUD FUNCTION CURRENT TIME: ${DateFormat("yyyy-MM-dd HH:mm:ss").parse(DateFormat("yyyy-MM-dd HH:mm:ss").format(currentDateTime))}');
        return DateFormat("yyyy-MM-dd HH:mm:ss")
            .parse(DateFormat("yyyy-MM-dd HH:mm:ss").format(currentDateTime));
      } else {
        print("response code not 200");
        return null;
      }
    } finally {
      client.close();
      print("CONNECTION CLOSED");
    }
  }

  static DateTime currentTime;
  static Future<DateTime> getNTPTime() async {
    currentTime = null;
    currentTime = await NTP.now().timeout(Duration(seconds: 2), onTimeout: () {
      print('NTP TIME OUT');
      return null;
    }).catchError((error) async {
      print('NTP CATCH ERROR');

      currentTime = await fetchCurrentTime(new http.Client());
      print('CLOUD FUNCTION RETURN CURRENT TIME: $currentTime');
    });
    if (currentTime == null) {
      print('NTP TIME IS NULL');
      currentTime = await fetchCurrentTime(new http.Client());
      print('CLOUD FUNCTION RETURN CURRENT TIME: $currentTime');
    } else {
      print('NTP TIME: $currentTime');
      return currentTime;
    }
  }

////////////////////////////////////////////////////////GET CURRENT TIME FROM SERVER
  static Future<void> getCurrentTime() async {
    await getNTPTime().catchError((error) {
      print('NTP TIME ERROR: $error');
    }).then((value) {
      globals.currentTimeZone =
          globals.dateFormat.parse(currentTime.toString());
    });
  }

  static Future<void> showNotification(
      String title, String body, String payload) async {
    print('NOTIFICATION SHOWED');
    /////////////////////////////////////////CHANNEL DETAILS
    var groupChannelId = 'C_ID_1';
    var groupChannelName = 'GAMES TO START';
    var groupChannelDescription =
        'Contains all scheduled notification for newly added game';

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      groupChannelId,
      groupChannelName,
      groupChannelDescription,
      icon: 'ic_app_icon',
      enableLights: true,
      color: Color(0xff5c4710),
      ledColor: Colors.blue,
      ledOnMs: 1000,
      ledOffMs: 500,
      importance: Importance.Max,
      priority: Priority.High,
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await globals.flutterLocalNotificationsPlugin
        .show(0, title, body, platformChannelSpecifics, payload: payload);
  }

  static Future<String> encryptGameID(int hours, int day, String gameID) async {
    int encGameID = int.parse(gameID) + hours + day;
    print('ENCRYPTED GAME ID:${encGameID}');
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String encoded = stringToBase64.encode(encGameID.toString());
    return encoded;
  }

  static Future<String> decryptGameID(int hour, int day, String gameID) async {
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String decodedStr=prefs.getString('gameID');
    String decoded = stringToBase64.decode(decodedStr);
    int decGameID = int.parse(decoded) - hour - day;
    return decGameID.toString();
  }
}
