import 'dart:ui';

import 'package:flutter/material.dart';

class ClockPainter extends CustomPainter {
  double animValue;

  ClockPainter(this.animValue);

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    Paint paint = Paint()
      ..color = Colors.red
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15.0;

    Path path = Path();
    path.moveTo(size.width / 2, 0.0);
    double y = 0.0;
    if (!animValue.isNegative)
      y = -animValue * 0.10;
    else
      y = animValue * 0.10;
    path.relativeLineTo(animValue, size.height * 0.60 + y);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}
