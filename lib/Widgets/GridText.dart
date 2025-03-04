import 'package:flutter/material.dart';
import 'package:win_diggy/Screen/DailyGames/WSGamePlayScreen.dart';

class GridAlphabet extends StatefulWidget {
  String alphabet;
  int index;
  List<int> completedIndices = new List();
  ValueNotifier<int> value;

  GridAlphabet(this.alphabet, this.index, this.completedIndices, this.value);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return GridAlphabetState();
  }
}

class GridAlphabetState extends State<GridAlphabet>
    with SingleTickerProviderStateMixin {
  Animation<double> textAnimation;

  AnimationController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );

    textAnimation = Tween(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
          parent: _controller, curve: Curves.ease, reverseCurve: Curves.easeIn),
    );
    widget.value.addListener(() async {
      if (widget.completedIndices.contains(widget.index)) {
        _controller.forward();

        textAnimation.addStatusListener((status) {
          if (status == AnimationStatus.completed) _controller.reverse();
        });
        await InnerView.of(context).pool.play(InnerView.of(context).soundID);

        // _controller.reverse(from: 1.2);

      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  Future reverseAnimator() async {
    if (widget.completedIndices.length != 0) {
      if (widget.completedIndices.contains(widget.index)) {
        _controller.forward();

        textAnimation.addStatusListener((status) {
          if (status == AnimationStatus.completed) _controller.reverse();
        });
        // _controller.reverse(from: 1.2);

        //reverseAnimator();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Transform.scale(
      scale: textAnimation.value,
      child: Text(
        widget.alphabet.toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 25,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
