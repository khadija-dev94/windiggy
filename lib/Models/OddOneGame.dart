import 'package:flutter/material.dart';
import 'package:win_diggy/Models/Box.dart';

import 'Center.dart';

class OddOneGame {
  String attempts;
  String image;
  List<Box> boxes;
  String answers;
  ValueNotifier<double> percentNotifier;
  ValueNotifier<int> attemptsNotifier;
  int diffFound;
  List<CenterPoint> centerPoints;
  int clueCount;

  OddOneGame(
    this.attempts,
    this.image,
    this.boxes,
    this.answers,
    this.percentNotifier,
    this.attemptsNotifier,
    this.diffFound,
    this.centerPoints,
    this.clueCount,
  );
}
