import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:win_diggy/Models/CompletedWordOffsets.dart';

class PuzzleLinePainter extends CustomPainter {
  List<Offset> centerPoints = List();
  List<CompletedPoints> completedCenterPoints = List();

  PuzzleLinePainter({
    this.centerPoints,
    this.completedCenterPoints,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..color = Color(0x59000000)
      ..strokeWidth = 28;

    int pointsLength = 0;
    if (completedCenterPoints.length >= 1) {
      for (int i = 0; i < completedCenterPoints.length; i++) {
        pointsLength = completedCenterPoints[i].centers.length;
        if (pointsLength > 1) {
          canvas.drawLine(completedCenterPoints[i].centers[0],
              completedCenterPoints[i].centers[pointsLength - 1], paint);
        }
      }
    }
    if (centerPoints.length >= 2) {
      canvas.drawLine(centerPoints[0], centerPoints.last, paint);
    } else {
      canvas.drawPoints(PointMode.points, centerPoints, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}
