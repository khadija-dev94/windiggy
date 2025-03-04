import 'dart:math';

import 'package:auto_direction/auto_direction.dart';
import 'package:flutter/material.dart';
import 'package:win_diggy/Models/GlobalTranslations.dart';

import 'BonusClock.dart';
import 'ClockPainter.dart';

class BonusView extends StatefulWidget {
  String engTxt;
  String urduTxt;
  ValueNotifier<String> langNotifier;

  BonusView(this.engTxt, this.urduTxt, this.langNotifier);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return BonusClockState();
  }
}

class BonusClockState extends State<BonusView>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation<double> animation;
  double animValue;
  String language = allTranslations.currentLanguage;
  String engText;
  String urdText;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    engText = '';
    urdText = '';
    engText = widget.engTxt;
    urdText = widget.urduTxt;
    print('CURRENT LANG:$language');
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              child: GestureDetector(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CustomPaint(
                    painter: BonusPainter(),
                    child: Container(
                      // color: Colors.blue[100],
                      padding: EdgeInsets.only(
                        top: 5,
                        left: 15,
                        right: 15,
                        bottom: 15,
                      ),
                      alignment: Alignment.topCenter,
                      child: Text(
                        allTranslations.text('bonusGame'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontFamily: 'BreeSerif',
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                onTap: () {
                  bonusGameDialog(widget.langNotifier.value);
                },
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BonusClock(),
          ),
        ],
      ),
    );
  }

  Future bonusGameDialog(String value) {
    return showGeneralDialog(
      barrierColor: Colors.black.withOpacity(0.5),
      transitionBuilder: (context, a1, a2, widget) {
        return Transform.scale(
          scale: a1.value,
          child: Opacity(
            opacity: a1.value,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0.0,
              backgroundColor: Colors.transparent,
              child: Stack(
                children: <Widget>[
                  Container(
                    //color: Colors.white,
                    //padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Container(
                      padding: EdgeInsets.only(top: 45),
                      child: Material(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                        child: Container(
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.08,
                            left: 30,
                            right: 30,
                            bottom: 30,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.only(top: 5, bottom: 0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      alignment: Alignment.center,
                                      child: AutoDirection(
                                        text: value == 'ur' ? urdText : engText,
                                        child: Text(
                                          value == 'ur' ? urdText : engText,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 18,
                                            fontFamily: 'Futura',
                                            height: 1.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: MediaQuery.of(context).size.height * 0.07,
                        child: Padding(
                          padding: EdgeInsets.all(5),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.12,
                            width: MediaQuery.of(context).size.height * 0.12,
                            child: Image.asset(
                              'assets/logo.png',
                              //color: Color(0xffe69c21),
                            ),
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
      },
      transitionDuration: Duration(milliseconds: 150),
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      pageBuilder: (context, animation1, animation2) {},
    );
  }
}

class BonusPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    Rect rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width,
      height: size.height,
    );
    final Gradient gradient = new LinearGradient(
      begin: Alignment(0.08, -2.8),
      end: Alignment(0.0, 2.8),
      colors: [
        Color(0xff5c4710),
        Color(0xffeccb58),
        Color(0xff5c4710),
      ],
    );

    // create the Shader from the gradient and the bounding square
    final Paint paint = new Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);
    Paint circlePaint = new Paint()..color = Colors.black;
    canvas.drawCircle(
        Offset(size.width / 2, size.height * 0.83), 4, circlePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }
}
