import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:win_diggy/Models/GlobalTranslations.dart';
import 'package:win_diggy/Screen/DailyGames/FlipGameScreen.dart';

class FlipCard extends StatefulWidget {
  String value;
  int index;
  String type;

  FlipCard(this.value, this.index, this.type);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return CardFlipState();
  }
}

class CardFlipState extends State<FlipCard>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> _frontRotation;
  Animation<double> _backRotation;
  bool notMatched;
  bool isFront = true;
  bool animatedCompleted;

  Future toggleCard() async {
    checkMatch();
  }

  @override
  void initState() {
    super.initState();
    notMatched = false;
    animatedCompleted = false;

    controller =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    _frontRotation = TweenSequence(
      <TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: Tween(begin: 0.0, end: pi / 2)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 50.0,
        ),
        TweenSequenceItem<double>(
          tween: ConstantTween<double>(pi / 2),
          weight: 50.0,
        ),
      ],
    ).animate(controller);
    _backRotation = TweenSequence(
      <TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: ConstantTween<double>(pi / 2),
          weight: 50.0,
        ),
        TweenSequenceItem<double>(
          tween: Tween(begin: -pi / 2, end: 0.0)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 50.0,
        ),
      ],
    ).animate(controller);
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animatedCompleted = true;
        if (InnerViewFlip.of(context).checked.length ==
            InnerViewFlip.of(context).boxes.length) if (animatedCompleted) {
          InnerViewFlip.of(context).gameComplete();
          print('ALL CLEAR AFTER MATCHED');
        }
      }
    });
  }

  Future checkMatch() async {
    if (!InnerViewFlip.of(context).checked.contains(widget.index)) {
      if (!InnerViewFlip.of(context).currentIndices.contains(widget.index)) {
        await InnerViewFlip.of(context)
            .pool
            .play(InnerViewFlip.of(context).soundId1);

        setState(() {
          InnerViewFlip.of(context).currentIndices.add(widget.index);
          InnerViewFlip.of(context).values.add(widget.value);

          InnerViewFlip.of(context).controllers.add(controller);
        });
        print('NEW ITEM: ${InnerViewFlip.of(context).currentIndices.last}');

        if (InnerViewFlip.of(context).currentIndices.length == 2) {
          print(
              'MATCHED FIRST INDEX VALUE: ${InnerViewFlip.of(context).values[0]}');
          print(
              'MATCHED SEC INDEX VALUE: ${InnerViewFlip.of(context).values[1]}');

          if (InnerViewFlip.of(context).values[0] ==
              InnerViewFlip.of(context).values[1]) {
            await InnerViewFlip.of(context)
                .pool
                .play(InnerViewFlip.of(context).soundId2);

            setState(() {
              InnerViewFlip.of(context)
                  .checked
                  .add(InnerViewFlip.of(context).currentIndices[0]);
              InnerViewFlip.of(context)
                  .checked
                  .add(InnerViewFlip.of(context).currentIndices[1]);

              InnerViewFlip.of(context).values.clear();
              InnerViewFlip.of(context).currentIndices.clear();

              InnerViewFlip.of(context).controllers.clear();
            });
          }
        }
        if (InnerViewFlip.of(context).currentIndices.length <= 3) {
          if (InnerViewFlip.of(context).currentIndices.length == 3) {
            int index1 = InnerViewFlip.of(context).currentIndices[0];
            int index2 = InnerViewFlip.of(context).currentIndices[1];
            AnimationController cont1 =
                InnerViewFlip.of(context).controllers[0];
            AnimationController cont2 =
                InnerViewFlip.of(context).controllers[1];
            String firstVaue = InnerViewFlip.of(context).values[0];
            String secVaue = InnerViewFlip.of(context).values[1];

            print(
                'FIRST INDEX VALUE: ${InnerViewFlip.of(context).currentIndices[0]}');
            print(
                'SECOND INDEX VALUE: ${InnerViewFlip.of(context).currentIndices[1]}');
            controller.forward();

            InnerViewFlip.of(context).controllers[0].reverse();
            InnerViewFlip.of(context).controllers[1].reverse();
            setState(() {
              InnerViewFlip.of(context).controllers.remove(cont1);
              InnerViewFlip.of(context).controllers.remove(cont2);
              InnerViewFlip.of(context).currentIndices.remove(index1);
              InnerViewFlip.of(context).currentIndices.remove(index2);
              InnerViewFlip.of(context).values.remove(firstVaue);
              InnerViewFlip.of(context).values.remove(secVaue);
            });
            print(
                'LIST LENGTH AFTER CLEAR: ${InnerViewFlip.of(context).currentIndices.length}');

            print(
                'FIRST INDEX VALUE AFTER CLEAR: ${InnerViewFlip.of(context).currentIndices[0]}');
          } else {
            controller.forward();
          }
        }

        setState(() {
          isFront = !isFront;
        });
      }
    }
  }

  Widget _buildContent({@required bool front}) {
    // pointer events that would reach the backside of the card should be
    // ignored
    return IgnorePointer(
      // absorb the front card when the background is active (!isFront),
      // absorb the background when the front is active
      ignoring: front ? !isFront : isFront,
      child: AnimatedBuilder(
        animation: front ? _frontRotation : _backRotation,
        builder: (BuildContext context, Widget child) {
          var transform = Matrix4.identity();
          transform.setEntry(3, 2, 0.001);
          transform.rotateX(front ? _frontRotation.value : _backRotation.value);

          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: front
                ? Container(
                    color: Theme.of(context).accentColor,
                    alignment: Alignment.center,
                  )
                : Container(
                    color: Colors.white,
                    alignment: Alignment.center,
                    child: widget.type == 'text'
                        ? Text(
                            widget.value,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : CachedNetworkImage(
                            fit: BoxFit.fill,
                            imageUrl: widget.value,
                            placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                  ),
          );
        },
        child: front
            ? Container(
                color: Theme.of(context).accentColor,
                alignment: Alignment.center,
              )
            : Container(
                color: Colors.white,
                alignment: Alignment.center,
                child: widget.type == 'text'
                    ? Text(
                        widget.value,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : CachedNetworkImage(
                        fit: BoxFit.fill,
                        imageUrl: widget.value,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final child = Stack(
      fit: StackFit.passthrough,
      children: <Widget>[
        _buildContent(front: true),
        _buildContent(front: false),
      ],
    );

    // if we need to flip the card on taps, wrap the content
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: toggleCard,
      child: child,
    );

    return child;
  }
}
