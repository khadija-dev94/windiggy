import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class GameWinners extends StatefulWidget {
  String gameID;
  ValueNotifier<int> winnersNotifier;

  GameWinners({this.gameID, this.winnersNotifier});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return GamePlayerState();
  }
}

class GamePlayerState extends State<GameWinners> {
  var updateListener;
  ValueNotifier<int> playersCountNotifier = new ValueNotifier<int>(0);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getInitialData();
  }

  Future getInitialData() async {
    playersCountNotifier.value = widget.winnersNotifier.value;
    updateListener = FirebaseDatabase.instance
        .reference()
        .child('game-' + widget.gameID)
        .child('players')
        .onChildAdded
        .listen(_onChildUpdated);
  }

  Future _onChildUpdated(Event event) async {
    print('NEW WINNER ADDED :${event.snapshot.value}');
    playersCountNotifier.value++;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            child: Text(
              'Position(s) Taken',
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).accentColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 10),
            alignment: Alignment.center,
            //color: Colors.blue[100],
            //padding: EdgeInsets.symmetric(horizontal: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(0.8, -2.0),
                    end: Alignment(0.0, 2.8),
                    colors: [
                      // Colors are easy thanks to Flutter's Colors class.
                      Color(0xff5c4710),
                      Color(0xffeccb58),
                      Color(0xff5c4710),

                      // Color(0xff5c4710),
                    ],
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 3),
                  child: Text(
                    playersCountNotifier.value.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
