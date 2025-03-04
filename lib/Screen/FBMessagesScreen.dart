import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:win_diggy/Models/GlobalTranslations.dart';
import 'package:win_diggy/Models/Message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:win_diggy/Globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:win_diggy/Widgets/ChatMessageListItem.dart';

class FBMessagesScreen extends StatefulWidget {
  static MessageReultsState of(BuildContext context) =>
      context.ancestorStateOfType(const TypeMatcher<MessageReultsState>());
  GlobalKey key;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MessageReultsState();
  }
}

class MessageReultsState extends State<FBMessagesScreen> {
  TextEditingController typeTxt = new TextEditingController();
  final private = FirebaseDatabase(databaseURL: globals.fdbUrl2)
      .reference()
      .child('users')
      .child('user-' + globals.userID.toString())
      .child('private_messages');

  final unread = FirebaseDatabase.instance.reference().child('new-messages');

  FocusScopeNode currentFocus;
  bool buttonEnabled;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    buttonEnabled = false;
  }

  @override
  void dispose() async {
    // TODO: implement dispose
    typeTxt.dispose();
    super.dispose();

    if (currentFocus != null) {
      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
    }
    //FocusScope.of(context).requestFocus(FocusNode());
  }

  void sendMessage() async {
    // String timestamp = DateFormat.jm().format(DateTime.now());
    DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
    DateTime targetdateTime = dateFormat.parse(DateTime.now().toString());
    String msgTime = DateFormat("yyyy-MM-dd HH:mm:ss").format(targetdateTime);

    private.push().set({
      'text': typeTxt.text.toString(),
      'senderID': globals.userID,
      'senderName': globals.username,
      'timestamp': msgTime,
      'sentBy': 'user',
    });
    unread.child(globals.userID).push();
    unread.child(globals.userID).set({
      'senderID': globals.userID,
      'senderName': globals.username,
    });
    typeTxt.text = '';
  }

  Future<bool> closeScreen(context) async {
    globals.HOMEONFRONT = true;
    globals.onceInserted = false;
    globals.resumeCalledOnce = false;
    Navigator.popAndPushNamed(context, '/dashboard');
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
      onWillPop: () {
        return closeScreen(context);
      },
      child: Scaffold(
        //resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text(
            allTranslations.text('messages'),
            style: TextStyle(color: Theme.of(context).accentColor),
          ),
          centerTitle: true,
          backgroundColor: Colors.black,
          elevation: 0,
          iconTheme: IconThemeData(
            color: Theme.of(context).accentColor,
          ),
        ),
        body: SafeArea(
          top: false,
          child: Container(
            color: Colors.black,
            child: Container(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      child: new FirebaseAnimatedList(
                        query: private,

                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        reverse: true,
                        sort: (a, b) => b.key.compareTo(a.key),
                        //comparing timestamp of messages to check which one would appear first
                        itemBuilder: (_, DataSnapshot messageSnapshot,
                            Animation<double> animation, index) {
                          return new ChatMessageListItem(
                            messageSnapshot: messageSnapshot,
                            animation: animation,
                            publicChat: false,
                          );
                        },
                      ),
                    ),
                  ),
                  Container(
                    //height: 70,
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    child: Material(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.grey[200],
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Expanded(
                            flex: 4,
                            child: Container(
                              child: SizedBox(
                                child: TextField(
                                  textInputAction: TextInputAction.send,
                                  onTap: () {
                                    //to get the current FocusNode, which will be the node associated with our text field (assuming that you've tapped the field to activate it).
                                    currentFocus = FocusScope.of(context);
                                  },
                                  onChanged: (message) {
                                    if (message != '')
                                      setState(() {
                                        buttonEnabled = true;
                                      });
                                    else
                                      setState(() {
                                        buttonEnabled = false;
                                      });
                                  },
                                  maxLines: null,
                                  keyboardType: TextInputType.text,
                                  textAlign: TextAlign.left,
                                  controller: typeTxt,
                                  style: TextStyle(
                                    color: Colors.grey[800],
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    fontFamily: 'Roboto Regular',
                                    height: 1.2,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 5),
                                    hintText: allTranslations.text('type_here'),
                                    hintStyle: TextStyle(
                                      color: Colors.grey[500],
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      fontFamily: 'Roboto Regular',
                                    ),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              alignment: Alignment.centerRight,
                              // padding: EdgeInsets.only(right: 3),
                              child: SizedBox(
                                //width: 70,
                                //height: 40,
                                child: PhysicalModel(
                                  shape: BoxShape.circle,
                                  color: Colors.transparent,
                                  child: FloatingActionButton(
                                      mini: true,
                                      elevation: 1,
                                      backgroundColor:
                                          Theme.of(context).accentColor,
                                      child: Icon(
                                        Icons.send,
                                        color: Colors.black,
                                        size: 20,
                                      ),
                                      onPressed: buttonEnabled
                                          ? () {
                                              sendMessage();
                                            }
                                          : null),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
