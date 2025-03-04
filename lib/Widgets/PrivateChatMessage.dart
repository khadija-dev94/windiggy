import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:win_diggy/Globals.dart' as globals;
import 'package:win_diggy/Models/Message.dart';

var currentUserEmail;

class PrivateChatMessageListItem extends StatelessWidget {
  final Message msg;

  PrivateChatMessageListItem({
    this.msg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: const EdgeInsets.symmetric(vertical: 5.0),
      child: msg.sentBy == 'user'
          ? getSentMessageLayout(context)
          : getReceivedMessageLayout(context),
    );
  }

  Widget getSentMessageLayout(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 5, bottom: 0),
      // padding: EdgeInsets.only(bottom: 5),
      //color: Colors.blue[100],

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
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
                bottomLeft: Radius.circular(15),
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
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  width: MediaQuery.of(context).size.width * 0.80,
                  alignment: Alignment.centerRight,
                  child: Column(
                    children: <Widget>[
                      Text(
                        msg.userName,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
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
            height: 20,
            child: SizedBox(
              child: Text(
                msg.timestamp,
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
    return Container(
      //padding: EdgeInsets.only(left: 8, right: 8),
      //  width: MediaQuery.of(context).size.width * 0.50,
      margin: EdgeInsets.only(top: 10),
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
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                width: MediaQuery.of(context).size.width * 0.80,
                child: Column(
                  children: <Widget>[
                    new Text(
                      msg.userName,
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    new Text(
                      msg.message,
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
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
              msg.timestamp,
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
