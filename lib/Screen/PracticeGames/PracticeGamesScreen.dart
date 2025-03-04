import 'package:flutter/material.dart';
import 'package:win_diggy/Models/GlobalTranslations.dart';
import 'package:win_diggy/Globals.dart' as globals;
import 'package:flutter_svg/flutter_svg.dart';

import 'PracticeFlipGameScreen.dart';
import 'PracticeImageDiffScreen.dart';
import 'PracticePickOddGameScreen.dart';
import 'PracticeQuizScreen.dart';
import 'PracticeTapTapScreen.dart';
import 'PracticeWSGamePlayScreen.dart';

class PracticeGameScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return PracticeGameScreenState();
  }
}

class PracticeGameScreenState extends State<PracticeGameScreen> {
  bool capPop;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    capPop = false;
  }

  Widget singleCell(text, index) {
    return Container(
      // color: Colors.blue[100],
      padding: EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 6,
      ),
      child: InkWell(
        onTap: () {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PracticeQuizScreen(),
              ),
            );
          }
          else if(index==1)
          {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PracticeWSGamePlayPage(),
              ),
            );
          }
          else if(index==2)
          {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PracticeImageDiffScreen(),
              ),
            );
          }
          else if(index==3)
          {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PracticePickOddGameScreen(),
              ),
            );
          }
          else if(index==4)
          {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PracticeTapTapScreen(),
              ),
            );
          }
          else if(index==5)
            {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PracticeFlipGameScreen(),
                ),
              );
            }
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
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
              //height: MediaQuery.of(context).size.height * 0.20,
              padding:
                  EdgeInsets.only(top: 15, bottom: 15, left: 20, right: 20),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      'assets/game.svg',
                      color: Colors.black,
                      height: MediaQuery.of(context).size.height * 0.10,
                      width: MediaQuery.of(context).size.height * 0.10,
                      semanticsLabel: 'A red up arrow',
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 5),
                    alignment: Alignment.center,
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontFamily: 'Futura',
                        // fontWeight: FontWeight.w600,
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

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              allTranslations.text('practice'),
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
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: singleCell('Question Answer', 0),
                          ),
                          Expanded(
                            child: singleCell('Cross Word', 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: singleCell('Find The Difference', 2),
                          ),
                          Expanded(
                            child: singleCell('Pick The Odd One Out', 3),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: singleCell('Tap Diggy', 4),
                          ),
                          Expanded(
                            child: singleCell('Flip', 5),
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
        onWillPop: () {
          return closeScreen(context);
        });
  }

  Future<bool> closeScreen(context) async {
    globals.HOMEONFRONT = true;
    globals.onceInserted = false;
    //Navigator.of(context).pop();
    globals.resumeCalledOnce=false;
    Navigator.popAndPushNamed(context, '/dashboard');
    return false;
  }
}
