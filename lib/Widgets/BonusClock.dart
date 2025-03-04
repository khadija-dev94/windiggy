import 'dart:math';

import 'package:flutter/material.dart';

import 'ClockPainter.dart';
import 'dart:math' as math;
import 'package:vector_math/vector_math_64.dart';

class BonusClock extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return BonusClockState();
  }
}

class BonusClockState extends State<BonusClock>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation<double> animation;
  double animValue;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    animationController = AnimationController(
      duration: Duration(
        milliseconds: 900,
      ),
      vsync: this,
    );
    animation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    );
    animationController.addStatusListener(animationStatusListener);
    animationController.forward();
    /*animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    )..addListener(() => setState(() {}));

    animationController.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        await Future.delayed(Duration(seconds: 6));
        animationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        await Future.delayed(Duration(seconds: 5));
        animationController.forward();
      }
    });
    animation = Tween<double>(
      begin: 50.0,
      end: 120.0,
    ).animate(animationController);

    animationController.forward();*/
  }

  @override
  void dispose() {
    // TODO: implement dispose
    animationController.dispose();
    super.dispose();
  }

  void animationStatusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      animationController.reverse();
    } else if (status == AnimationStatus.dismissed) {
      animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return AnimatedBuilder(
      child: Align(
        alignment: Alignment(0.0, -1.0),
        child: Container(
          alignment: Alignment.topCenter,
          height: 50,
          child: Column(
            children: <Widget>[
              Container(
                height: 15,
                width: 3,
                decoration: BoxDecoration(
                  color: Theme.of(context).accentColor,
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              Container(
                child: Image.asset(
                  'assets/bonus.png',
                  height: 35,
                  width: 35,
                ),
              ),
            ],
          ),
        ),
      ),
      animation: animationController,
      builder: (BuildContext context, Widget child) {
        /*return Transform.rotate(
          child: child,
          angle: math.pi * 0.50 * animation.value -
              (math.pi * 0.50) +
              (math.pi * 0.25),
          origin: Offset(0, -137),
        );*/
        return Transform.rotate(
          child: child,
          angle: math.pi * 0.25 * animation.value - (math.pi * 0.12),
          origin: Offset(0, -25),
        );
      },
    );
    /* return Transform(
      transform: Matrix4.translation(_shake()),
      child: Image.asset(
        'assets/bonus.png',
        height: 35,
        width: 35,
      ),
    );*/
  }

  Vector3 _shake() {
    double progress = animationController.value;
    double offset = sin(progress * pi * 20.0);
    return Vector3(offset * 3, 0.0, 0.0);
  }
}
