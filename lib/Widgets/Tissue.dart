import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soundpool/soundpool.dart';
import 'package:win_diggy/Screen/ContestGames/TissueBoxContestGame.dart';
import 'package:win_diggy/Screen/DailyGames/TissueBoxGame.dart';
import 'package:win_diggy/Globals.dart' as globals;

class Tissue extends StatefulWidget {
  Color initColor;
  Color newColor;
  double height;

  Tissue(
    this.initColor,
    this.newColor,
    this.height,
  );

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return TissueState();
  }
}

class TissueState extends State<Tissue> with TickerProviderStateMixin {
  Animation<RelativeRect> animation;
  Animation<double> animationOpacity;

  AnimationController animationController;
  double top, bottom;
  Color inittissueColor;
  Color newtissueColor;
  Offset startPosition;
  Soundpool pool;
  int soundID;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    top = widget.height * 0.10;
    bottom = 0.0;
    newtissueColor = widget.newColor;
    inittissueColor = widget.initColor;

    animationController = new AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);

    animationOpacity =
        Tween<double>(begin: 1, end: 0.0).animate(animationController);
    CurvedAnimation(parent: animationController, curve: Curves.easeIn);
    animation = RelativeRectTween(
      begin: new RelativeRect.fromLTRB(0.0, top, 0.0, bottom),
      end: new RelativeRect.fromLTRB(
          0.0, widget.height * 0.05, 0.0, widget.height * 0.20),
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.linearToEaseOut,
      ),
    )..addStatusListener((status) async {
        if (status == AnimationStatus.completed) {
          if (!globals.dailyContestTissueEnabled)
            TissueBoxView.of(context).incrementCount();
          else
            TissueBoxContestView.of(context).incrementCount();

          //await pool.play(soundID);
        }
      });

    //initSound();
  }

  Future initSound() async {
    pool = Soundpool(streamType: StreamType.notification);
    soundID = await rootBundle.load("assets/t.mp3").then((ByteData soundData) {
      return pool.load(soundData);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return PositionedTransition(
      child: Container(
        //height: 200,
        //color: Colors.blue[200],
        alignment: Alignment.bottomCenter,
        child: GestureDetector(
          onVerticalDragStart: (details) {
            startPosition = details.localPosition;
            print('START: $startPosition');
          },
          onVerticalDragUpdate: (details) async {
            print('CURRENT: ${details.localPosition.dy}');
            //print('CURRENT: ${-details.localPosition.dy - startPosition.dy}');
            //print('CURRENT: ${details.localPosition.dy - startPosition.dy}');

            if (startPosition.dy - details.localPosition.dy >= 10)
              animationController.forward();
          },
          child: Container(
            // height: 300,
            child: FadeTransition(
              opacity: animationOpacity,
              child: Container(
                // color: Colors.blue[200],
                //height: 300,
                alignment: Alignment.bottomCenter,
                child: Image.asset(
                  'assets/tissuePaper',
                  // height: 200,
                  // height: 300,
                ),
              ),
            ),
          ),
        ),
      ),
      rect: animation,
    );
  }
}
