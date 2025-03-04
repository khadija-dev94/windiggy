
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class CounterListenableProvider extends InheritedWidget {
  final ValueListenable<int> hour;
  final ValueListenable<int> min;
  final ValueListenable<int> sec;
  final ValueListenable<int> milsec;


  CounterListenableProvider({Key key, @required this.hour,this.min,this.sec,this.milsec, Widget child})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }

  static ValueListenable<int> of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(CounterListenableProvider)
    as CounterListenableProvider)
        .hour;
  }
}