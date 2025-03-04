import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:win_diggy/Models/Box.dart';
import 'package:win_diggy/Models/GlobalTranslations.dart';
import 'package:win_diggy/Models/OddOneGame.dart';
import 'package:flutter/rendering.dart';
import 'package:win_diggy/Globals.dart' as globals;
import 'package:win_diggy/Screen/DailyGames/PickOddGameScreen.dart';
import 'package:win_diggy/Models/Center.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class SingleOddOne extends StatefulWidget {
  int position;
  OddOneGame singleQuestion;
  var currentQue;
  var total;
  String gameID;

  SingleOddOne({
    this.position,
    this.singleQuestion,
    this.currentQue,
    this.total,
    this.gameID,
  });

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SingleOddOneState();
  }
}

class SingleOddOneState extends State<SingleOddOne> {
  double percIncrement;

  bool pushedOnce;

  @override
  void initState() {
    super.initState();
    percIncrement = 0.0;
    pushedOnce = false;
    print('percent: ${widget.singleQuestion.percentNotifier}');
    print('attempts: ${widget.singleQuestion.attemptsNotifier}');

    calculatePercentInc();
  }

  Future calculatePercentInc() async {
    double per = 99 / int.parse(widget.singleQuestion.attempts);
    percIncrement = per / 100;
  }

  Future addData(CenterPoint center) async {
    widget.singleQuestion.centerPoints.add(center);
    setState(() {
      ++widget.singleQuestion.diffFound;
    });
    widget.singleQuestion.clueCount++;
    if (!pushedOnce) {
      FirebaseDatabase.instance
          .reference()
          .child('game-' + widget.gameID)
          .child('players_count')
          .child(globals.userID)
          .child('coordinates')
          .push();

      pushedOnce = true;
    }
    FirebaseDatabase.instance
        .reference()
        .child('game-' + widget.gameID)
        .child('players_count')
        .child(globals.userID)
        .child('coordinates')
        .child('clue-' + widget.singleQuestion.clueCount.toString())
        .push();

    await FirebaseDatabase.instance
        .reference()
        .child('game-' + widget.gameID)
        .child('players_count')
        .child(globals.userID)
        .child('coordinates')
        .child('clue-' + widget.singleQuestion.clueCount.toString())
        .set({
      'x': double.parse(center.centerOffset.dx.toStringAsFixed(1)),
      'y': double.parse(center.centerOffset.dy.toStringAsFixed(1)),
    });
    await FirebaseDatabase.instance
        .reference()
        .child('game-' + widget.gameID)
        .child('players_count')
        .child(globals.userID)
        .update({'answerFound': widget.singleQuestion.diffFound.toString()});
  }

  Future incrementCounter(CenterPoint center) async {
    var checkPoint = widget.singleQuestion.centerPoints.firstWhere(
        (product) => product.centerOffset == center.centerOffset,
        orElse: () => null);
    if (checkPoint != null) {
      print('THIS CLUE IS ALREADY FOUND');
    } else {
      print('CENTER POINT ADDED TO LIST: ${center.centerOffset}');
      Future.wait([addData(center)]).then((value) async {
        if (widget.singleQuestion.diffFound ==
            int.parse(widget.singleQuestion.answers)) {
          if (widget.currentQue == widget.total) {
            DrawingView.of(context).incrementCounter();
          } else {
            await DrawingView.of(context).setNextPage(true, widget.position);
            widget.singleQuestion.clueCount = 0;
          }
        }
      });
    }
  }

  Widget drawCanvas() {
    return GestureDetector(
      onTapDown: (TapDownDetails details) async {
        print('CALLED');

        final RenderBox box = context.findRenderObject();
        final Offset localOffset = box.globalToLocal(details.globalPosition);
        final result = BoxHitTestResult();
        if (box.hitTest(result, position: localOffset)) {
          // print('CALLED');
          Rect rect = Rect.fromLTRB(
            widget.singleQuestion.boxes[globals.boxPosition].x1 * globals.width,
            widget.singleQuestion.boxes[globals.boxPosition].y1 *
                globals.height,
            widget.singleQuestion.boxes[globals.boxPosition].x2 * globals.width,
            (widget.singleQuestion.boxes[globals.boxPosition].y2 *
                globals.height),
          );

          incrementCounter(CenterPoint(centerOffset: rect.center));
        } else {
          print('ELSE CALLED IN GESTURE DET. YOU HIT OUT OF BOX');
        }
      },
      child: Container(
        // color: Colors.blue,
        child: CustomPaint(
          foregroundPainter:
              Circle(centerPoints: widget.singleQuestion.centerPoints),
          painter: PicturePainter(
            boxes: widget.singleQuestion.boxes,
            percentNotifier: widget.singleQuestion.percentNotifier,
            attemptsNotifier: widget.singleQuestion.attemptsNotifier,
            incValue: percIncrement,
            onCountSelected: () async {
              await Future.delayed(Duration(seconds: 1));
              DrawingView.of(context).gameLooseDialog();
            },
            onWrongSelected: () async {
              await FirebaseDatabase.instance
                  .reference()
                  .child('game-' + widget.gameID)
                  .child('players_count')
                  .child(globals.userID)
                  .update({
                'falseCount':
                    widget.singleQuestion.attemptsNotifier.value.toString(),
                'falsePerc':
                    widget.singleQuestion.percentNotifier.value.toString(),
              });
            },
          ),
          child: Container(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      alignment: Alignment.center,
      //color: Colors.blue[200],
      padding: EdgeInsets.only(left: 10, right: 10),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        margin: EdgeInsets.only(bottom: 5, top: 10),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 0),
                child: Column(
                  // mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
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
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 8),
                            child: Text(
                              widget.currentQue.toString() +
                                  " of " +
                                  widget.total.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(top: 30),
                        width: double.infinity,
                        height: double.infinity,
                        child: Stack(
                          //fit: StackFit.expand,
                          children: <Widget>[
                            Container(
                              //color: Colors.blue[100],
                              width: double.infinity,
                              height: double.infinity,
                              child: CachedNetworkImage(
                                fit: BoxFit.fill,
                                imageUrl: widget.singleQuestion.image,
                                placeholder: (context, url) => Center(
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                            ),
                            drawCanvas(),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.10,
                      margin: EdgeInsets.only(top: 10),
                      padding: EdgeInsets.only(left: 20, right: 20),
                      alignment: Alignment.bottomCenter,
                      child: Row(
                        // mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Container(
                            alignment: Alignment.centerLeft,
                            //color: Colors.blue[100],
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.05,
                              alignment: Alignment.centerLeft,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(30),
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
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Container(
                                        //color: Colors.blue[100],
                                        child: SizedBox(
                                          child: Text(
                                            allTranslations.text('odds'),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 13,
                                              fontFamily: 'Futura',
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(left: 10),
                                        child: Text(
                                          widget.singleQuestion.diffFound
                                                  .toString() +
                                              '\/' +
                                              widget.singleQuestion.answers,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13,
                                            fontFamily: 'Futura',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              // color: Colors.blue[100],
                              alignment: Alignment.centerRight,
                              child: CircularPercentIndicator(
                                radius: 43.0,
                                lineWidth: 8.0,
                                animation: true,
                                percent:
                                    widget.singleQuestion.percentNotifier.value,
                                animationDuration: 450,
                                animateFromLastPercent: true,
                                backgroundColor: Colors.grey,
                                center: new Text(
                                  widget.singleQuestion.attemptsNotifier.value
                                          .toString() +
                                      '\/' +
                                      widget.singleQuestion.attempts.toString(),
                                  style: new TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 9.0,
                                    color: Colors.black,
                                  ),
                                ),
                                circularStrokeCap: CircularStrokeCap.round,
                                progressColor: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class PicturePainter extends CustomPainter {
  List<Box> boxes = new List();
  ValueNotifier<double> percentNotifier;
  ValueNotifier<int> attemptsNotifier;
  double incValue;
  VoidCallback onCountSelected;
  VoidCallback onWrongSelected;

  PicturePainter({
    this.boxes,
    this.percentNotifier,
    this.attemptsNotifier,
    this.incValue,
    this.onCountSelected,
    this.onWrongSelected,
  });
  List<Offset> centerPoints = new List();
  bool valueChanged = false;

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint

    double height = (size.height / 1000);
    double width = (size.width / 1000);
    globals.height = height;
    globals.width = width;
    for (int i = 0; i < boxes.length; i++) {
      final paint = Paint();
      paint.color = Colors.transparent;
      canvas.drawRect(
        new Rect.fromLTRB(
            boxes[i].x1 * globals.width,
            (boxes[i].y1 * globals.height),
            boxes[i].x2 * globals.width,
            ((boxes[i].y2 * globals.height))),
        paint,
      );
      double centerx =
          (((boxes[i].x2 * globals.width) - (boxes[i].x1 * globals.width)) /
                  2) +
              (boxes[i].x1 * globals.width);
      double centery =
          ((((boxes[i].y2 * globals.height)) - (boxes[i].y1 * globals.height)) /
                  2) +
              (boxes[i].y1 * globals.height);

      // print(Offset(centerx, centery));
      centerPoints.add(
        Offset(centerx, centery),
      );
    }
  }

  @override
  bool hitTest(Offset position) {
    Path path;
    for (int i = 0; i < boxes.length; i++) {
      double boxwidth =
          ((boxes[i].x2 * globals.width) - (boxes[i].x1 * globals.width));
      double boxheight =
          (((boxes[i].y2 * globals.height)) - (boxes[i].y1 * globals.height));
      path = Path();
      path.addRect(
        Rect.fromCenter(
          center: centerPoints[i],
          width: (boxwidth),
          height: (boxheight),
        ),
      );
      path.close();
      if (path.contains(position)) {
        globals.boxPosition = i;
        return true;
      }
    }
    if (percentNotifier.value < 0.9) {
      percentNotifier.value = percentNotifier.value + incValue;
      attemptsNotifier.value++;
      onWrongSelected();
      if (percentNotifier.value > 0.9 ||
          percentNotifier.value.truncate() == 1.0) onCountSelected();
    }
    return false;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }
}

class Circle extends CustomPainter {
  List<CenterPoint> centerPoints;
  Circle({
    this.centerPoints,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    for (int i = 0; i < centerPoints.length; i++) {
      final paint = Paint()
        ..color = Colors.green
        ..strokeWidth = 7
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(centerPoints[i].centerOffset, 20, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }
}
