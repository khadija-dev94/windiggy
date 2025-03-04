import 'package:flutter/material.dart';
import 'package:win_diggy/CustomIcons/puzzle_icons_icons.dart';
import 'package:win_diggy/Models/ConnectivityStatus.dart';
import 'package:provider/provider.dart';

class NetworkSensitive extends StatelessWidget {
  final Widget child;
  final double opacity;

  NetworkSensitive({
    this.child,
    this.opacity = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    var connectionStatus = Provider.of<ConnectivityStatus>(context);

    if (connectionStatus == ConnectivityStatus.WiFi) {
      return child;
    }

    if (connectionStatus == ConnectivityStatus.Cellular) {
      return child;
    }

    return Dialog(
      insetAnimationDuration: Duration(seconds: 1),
      insetAnimationCurve: Curves.elasticInOut,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Stack(
        children: <Widget>[
          Container(
            child: Container(
              padding: EdgeInsets.only(top: 45),
              child: Material(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.12,
                    left: 30,
                    right: 30,
                    bottom: 50,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(top: 5, bottom: 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              //color: Colors.blue[100],
                              alignment: Alignment.center,
                              margin: EdgeInsets.only(top: 0),
                              child: Text(
                                'No Internet Connection',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              //color: Colors.blue[100],
                              alignment: Alignment.center,
                              margin:
                                  EdgeInsets.only(top: 30, left: 20, right: 20),
                              child: Text(
                                'Please check your internet connection.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: MediaQuery.of(context).size.height * 0.07,
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child: SizedBox(
                      child: Icon(
                    PuzzleIcons.signal_wifi_off,
                    color: Colors.red,
                    size: MediaQuery.of(context).size.height * 0.08,
                  )),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
