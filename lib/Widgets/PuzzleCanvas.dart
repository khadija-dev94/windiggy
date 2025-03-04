import 'package:flutter/material.dart';
import 'package:win_diggy/Models/CompletedWord.dart';
import 'package:win_diggy/Globals.dart' as globals;

class PuzzleGridPainter extends CustomPainter {
  List<Color> colors = [
    Colors.blue,
    Colors.pink,
    Colors.blue,
    Colors.pink,
    Colors.blue,
    Colors.pink,
    Colors.blue,
    Colors.pink,
    Colors.blue
  ];
  List<Color> colors2 = [
    Colors.red,
    Colors.yellow,
    Colors.red,
    Colors.yellow,
    Colors.red,
    Colors.yellow,
    Colors.red,
    Colors.yellow,
    Colors.red
  ];

  PuzzleGridPainter({
    this.alphabets,
  });
  List<Offset> centerPoints = List();
  List<Rect> boxes = new List();
  List<String> alphabets = new List();

  @override
  void paint(Canvas canvas, Size size) {
    double boxWidth = (size.width / 9);
    double boxHeight = (size.height / 9);
    final paint = Paint();
    final paint2 = Paint();
    paint2.color = Colors.orange;
    final paint3 = Paint();
    paint3.color = Colors.transparent;

    double left = 0.0;
    double top = 0.0;
    double right = boxWidth;
    double bottom = boxHeight;
    int pos = 0;

    for (int i = 0; i < 9; i++) {
      for (int i = 0; i < 9; i++) {
        if (pos == 0)
          paint.color = colors[i];
        else
          paint.color = colors2[i];

        Rect rect2 = Rect.fromLTRB(left, top, right, bottom);
        canvas.drawRect(rect2, paint3);

        Offset center = Offset(
            ((rect2.width / 2) + rect2.left), ((rect2.height / 2)) + rect2.top);
        canvas.drawCircle(center, 12, paint3);
        // print('BOX WIDTH: ${rect2.width}');
        //print('BOX HEIGHT: ${rect2.height}');
        centerPoints.add(center);
        boxes.add(rect2);
        left = rect2.right;
        right = (rect2.right + boxWidth);
        top = rect2.top;
        bottom = rect2.bottom;
      }
      if (pos == 0)
        pos = 1;
      else
        pos = 0;
      left = 0.0;
      right = boxWidth;

      top = top + boxHeight;
      bottom = bottom + boxHeight;
    }
  }

  @override
  bool hitTest(Offset position) {
    Path path;
    for (int i = 0; i < boxes.length; i++) {
      path = Path();
      path.addOval(Rect.fromLTRB(
          boxes[i].left, boxes[i].top, boxes[i].right, boxes[i].bottom));
      path.close();
      if (path.contains(position)) {
        globals.selectedRect = centerPoints[i];
        globals.index = i;
        return true;
      }
    }

    return false;
  }

  @override
  bool shouldRepaint(PuzzleGridPainter oldDelegate) => false;
}
