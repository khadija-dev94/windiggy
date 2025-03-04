import 'package:auto_direction/auto_direction.dart';
import 'package:flutter/material.dart';
import 'package:win_diggy/Models/GlobalTranslations.dart';
import 'package:win_diggy/Globals.dart' as globals;
import 'package:win_diggy/Screen/DailyGames/QuizScreen.dart';
import 'package:win_diggy/Screen/DailyGames/WSGamePlayScreen.dart';
import 'package:win_diggy/Screen/DailyGames/ImageDiffScreen.dart';
import 'package:win_diggy/Screen/DailyGames/PickOddGameScreen.dart';

class BottomSlider extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return BottomSliderState();
  }
}

class BottomSliderState extends State<BottomSlider>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation<Offset> offset;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
    );

    offset = Tween<Offset>(begin: Offset(0.0, 1.0), end: Offset.zero)
        .animate(animationController);

    animationController.forward();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    if (animationController != null) animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SlideTransition(
      position: offset,
      child: Container(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 18),
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
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.only(right: 10),
                  child: AutoDirection(
                    text: allTranslations.text('block_game'),
                    child: Text(
                      allTranslations.text('block_game'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
