import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:win_diggy/Globals.dart' as globals;
import 'package:win_diggy/Models/Message.dart';

var currentUserEmail;

class ChatMessageListItem extends StatelessWidget {
  final DataSnapshot messageSnapshot;
  final Animation animation;
  bool publicChat;

  ChatMessageListItem({this.messageSnapshot, this.animation, this.publicChat});

  Widget checkUsername(context) {
    if (publicChat) {
      if (messageSnapshot.value['senderID'] == globals.userID)
        return getSentMessageLayout(context);
      else
        return getReceivedMessageLayout(context);
    } else {
      if (messageSnapshot.value['sentBy'] == 'user')
        return getSentMessageLayout(context);
      else
        return getReceivedMessageLayout(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new SizeTransition(
      sizeFactor:
          new CurvedAnimation(parent: animation, curve: Curves.decelerate),
      child: new Container(
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          child: checkUsername(context)),
    );
  }

  Widget getSentMessageLayout(BuildContext context) {
    String timestamp = '';
    if (globals.currentAppVersion == 203.0) {
      timestamp = messageSnapshot.value['timestamp'];
    } else {
      try {
        DateTime msgTime =
            DateFormat("h:mm a").parse(messageSnapshot.value['timestamp']);
        timestamp = messageSnapshot.value['timestamp'];
        print('MESSAGE TIME1: $msgTime');
      } catch (error) {
        DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
        DateTime targetdateTime =
            dateFormat.parse(messageSnapshot.value['timestamp']);
        timestamp = DateFormat.yMd().add_jm().format(targetdateTime);
        print('MESSAGE TIME2: $dateFormat');
      }
    }
    return Container(
      alignment: Alignment.centerRight,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            //padding: EdgeInsets.only(bottom: 5),
            //color: Colors.blue[200],
            alignment: Alignment.centerRight,
            //height: 30,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomLeft: Radius.circular(30),
              ),
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
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 7, horizontal: 20),
                  width: MediaQuery.of(context).size.width * 0.90,
                  alignment: Alignment.centerLeft,
                  child: Column(
                    children: <Widget>[
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          messageSnapshot.value['senderName'],
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(top: 7),
                        alignment: Alignment.centerLeft,

                        //   color: Colors.blue[100],
                        child: Text(
                          messageSnapshot.value['text'],
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Colors.grey[800],
                            //  fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            // color: Colors.pink,
            alignment: Alignment.centerRight,
            margin: EdgeInsets.only(top: 0, right: 5, bottom: 0),
            padding: EdgeInsets.only(top: 5),
            height: 15,
            child: SizedBox(
              child: Text(
                timestamp,
                textAlign: TextAlign.right,
                maxLines: 1,
                style: TextStyle(
                  color: Colors.grey[300],
                  fontWeight: FontWeight.w600,
                  fontSize: 9,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getReceivedMessageLayout(BuildContext context) {
    String timestamp = '';
    if (globals.currentAppVersion == 203.0) {
      timestamp = messageSnapshot.value['timestamp'];
    } else {
      try {
        DateTime msgTime =
            DateFormat("h:mm a").parse(messageSnapshot.value['timestamp']);
        timestamp = messageSnapshot.value['timestamp'];
        print('MESSAGE TIME1: $msgTime');
      } catch (error) {
        DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
        DateTime targetdateTime =
            dateFormat.parse(messageSnapshot.value['timestamp']);
        timestamp = DateFormat.yMd().add_jm().format(targetdateTime);
        print('MESSAGE TIME2: $dateFormat');
      }
    }
    return Container(
      //padding: EdgeInsets.only(left: 8, right: 8),
      //  width: MediaQuery.of(context).size.width * 0.50,
      alignment: Alignment.centerLeft,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            //color: Colors.blue[200],
            alignment: Alignment.centerLeft,
            //height: 30,
            child: Material(
              color: Colors.grey[200],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 7, horizontal: 20),
                width: MediaQuery.of(context).size.width * 0.90,
                alignment: Alignment.centerLeft,
                child: Column(
                  children: <Widget>[
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        messageSnapshot.value['senderName'],
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: messageSnapshot.value['sentBy'] == 'admin'
                              ? Colors.red
                              : Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.only(top: 7),
                      child: new Text(
                        messageSnapshot.value['text'],
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(top: 5, left: 5),
            child: Text(
              timestamp,
              maxLines: 1,
              style: TextStyle(
                color: Colors.grey[300],
                fontWeight: FontWeight.w600,
                fontSize: 9,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
