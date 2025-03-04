import 'dart:async';

import 'package:flutter/material.dart';

class LoadingTimer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return LoadingTimerState();
  }
}

class LoadingTimerState extends State<LoadingTimer> {
  Stopwatch watch = new Stopwatch();
  Timer timer;
  Duration duration = new Duration(seconds: 10);
  String seconds;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    seconds = '';
    startTimer();
  }

  Future startTimer() {
    watch.start();
    timer = new Timer.periodic(new Duration(seconds: 1), reverseTimerCallback);
  }

  Future reverseTimerCallback(Timer t) {
    if (watch.isRunning) {
      duration = duration - Duration(seconds: 1);

      if (!duration.isNegative) {
        setState(() {
          seconds =
              (duration.inSeconds.remainder(60)).toString().padLeft(2, '0');
        });
      } else {
        watch.stop();
        if (timer != null) timer.cancel();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      alignment: Alignment.center,
      child: Text(
        seconds,
        style: TextStyle(color: Colors.white, fontSize: 40),
      ),
    );
  }
}
