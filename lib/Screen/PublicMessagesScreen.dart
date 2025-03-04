import 'package:auto_direction/auto_direction.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:win_diggy/Models/GlobalTranslations.dart';
import 'package:win_diggy/Models/Message.dart';
import 'package:win_diggy/Models/URLS.dart';
import 'package:win_diggy/Widgets/ChatMessageListItem.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:win_diggy/Globals.dart' as globals;
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> fetchCountry(http.Client client) async {
  print('PUBLIC CHAT');
  DataSnapshot data = await FirebaseDatabase.instance
      .reference()
      .child('blockUser')
      .child('Chat')
      .once();

  if (data.value != null) {
    List<String> list = new List();
    print('${data.value}');
    Map<dynamic, dynamic> values = data.value;
    values.forEach((key, values) {
      list.add(key);
    });
    print('BLOCK USERS:$list');
    print('MY ID:${globals.userID}');

    if (list.contains(globals.userID)) {
      {
        print('YOU ARE BLOCKED');
        return {'block': true};
      }
    } else {
      return {'block': false};
    }
  }
}

class PublicMessagesScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return FBMessagesScreenState();
  }
}

class FBMessagesScreenState extends State<PublicMessagesScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future<bool> closeScreen(context) async {
    globals.HOMEONFRONT = true;
    globals.onceInserted = false;
    globals.resumeCalledOnce=false;
    Navigator.popAndPushNamed(context, '/dashboard');
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
      onWillPop: () {
        FocusScope.of(context).requestFocus(FocusNode());
        return closeScreen(context);
      },
      child: Scaffold(
        //resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text(
            allTranslations.text('public_chat'),
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
            height: double.infinity,
            width: double.infinity,
            child: new FutureBuilder<Map<String, dynamic>>(
              future: fetchCountry(
                new http.Client(),
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) print(snapshot.error);

                return snapshot.hasData
                    ? MessageReults(
                        data: snapshot.data,
                      )
                    : new Center(child: new CircularProgressIndicator());
              },
            ),
          ),
        ),
      ),
    );
  }
}

class MessageReults extends StatefulWidget {
  static MessageReultsState of(BuildContext context) =>
      context.ancestorStateOfType(const TypeMatcher<MessageReultsState>());

  Map<String, dynamic> data;

  MessageReults({this.data});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MessageReultsState();
  }
}

class MessageReultsState extends State<MessageReults> {
  TextEditingController typeTxt = new TextEditingController();

  FocusScopeNode currentFocus;
  bool buttonEnabled;
  final public = FirebaseDatabase.instance.reference().child('public_messages');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    buttonEnabled = false;
  }

  @override
  void dispose() async {
    // TODO: implement dispose
    super.dispose();
    typeTxt.dispose();
    if (currentFocus != null) {
      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
    }
  }

  void sendMessage() async {
    //String timestamp = DateFormat.jm().format(DateTime.now());
    DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
    DateTime targetdateTime = dateFormat.parse(DateTime.now().toString());
    String msgTime = DateFormat("yyyy-MM-dd HH:mm:ss").format(targetdateTime);

    public.push().set({
      'text': typeTxt.text.toString(),
      'senderID': globals.userID,
      'senderName': globals.username,
      'timestamp': msgTime,
      'sentBy': 'user',
    });
    typeTxt.text = '';
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return !widget.data['block']
        ? Container(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    child: new FirebaseAnimatedList(
                      query: public,
                      padding: const EdgeInsets.all(8.0),
                      reverse: true,
                      sort: (a, b) => b.key.compareTo(a.key),
                      //comparing timestamp of messages to check which one would appear first
                      itemBuilder: (_, DataSnapshot messageSnapshot,
                          Animation<double> animation, index) {
                        return new ChatMessageListItem(
                          messageSnapshot: messageSnapshot,
                          animation: animation,
                          publicChat: true,
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
          )
        : blockWidget();
  }

  Widget blockWidget() {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20),
      alignment: Alignment.center,
      //height: MediaQuery.of(context).size.height * 0.30,
      child: Container(
        alignment: Alignment.center,
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
                height: MediaQuery.of(context).size.height * 0.20,
                padding: EdgeInsets.symmetric(horizontal: 15),
                alignment: Alignment.center,
                child: SizedBox(
                  child: AutoDirection(
                    text: allTranslations.text('block_chat'),
                    child: Text(
                      allTranslations.text('block_chat'),
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
