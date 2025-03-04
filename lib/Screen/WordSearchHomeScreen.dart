import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rect_getter/rect_getter.dart';
import 'package:win_diggy/Screen/DailyGames/WSGamePlayScreen.dart';

class WSHomePage extends StatefulWidget {
  int position;

  WSHomePage({this.position});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return WSHomePageState();
  }
}

class WSHomePageState extends State<WSHomePage>
    with SingleTickerProviderStateMixin {
  final Duration animationDuration = Duration(milliseconds: 350);
  final Duration delay = Duration(milliseconds: 305);
  GlobalKey rectGetterKey = RectGetter.createGlobalKey();
  Rect rect;
  Animation _fabAnimation;
  Animation<double> _cardAnimation;
  Animation<double> _contentAnimation;
  Animation<double> _sizeAnimation;

  AnimationController _controller;

  void _onTap() async {
    setState(() => rect = RectGetter.getRectFromKey(rectGetterKey));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() =>
          rect = rect.inflate(1.3 * MediaQuery.of(context).size.longestSide));
    });
    Future.delayed(delay, _goToNextPage);
  }

  void _goToNextPage() {
    Navigator.of(context)
        .push(FadeRouteBuilder(page: WSGamePlayPage()))
        .then((_) => setState(() => rect = null));
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2500));

    _controller.forward();
    _controller.addListener(() {
      setState(() {});
    });

    // Fab Size goes from size * 0.0 to size * 1.0
    _fabAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(0.55, 0.70, curve: Curves.decelerate)));

    // Fab Size goes from size * 0.0 to size * 1.0
    _cardAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.30, 0.55, curve: Curves.easeOut),
      ),
    );
    _contentAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.50, 0.80, curve: Curves.easeOut),
      ),
    );

    _sizeAnimation = Tween(begin: 0.0, end: 20.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.15, 0.40, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    Widget _ripple() {
      if (rect == null) {
        return Container();
      }
      return AnimatedPositioned(
        duration: animationDuration,
        left: rect.left, //<-- Margin from left
        right: MediaQuery.of(context).size.width -
            rect.right, //<-- Margin from right
        top: rect.top, //<-- Margin from top
        bottom: MediaQuery.of(context).size.height -
            rect.bottom, //<-- Margin from bottom
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).primaryColor,
          ),
        ),
      );
    }

    return Stack(
      children: <Widget>[
        Scaffold(
          body: SafeArea(
            top: false,
            child: Container(
              padding: EdgeInsets.only(top: 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [
                    0.0,
                    0.8
                  ], // 10% of the width, so there are ten blinds.
                  colors: [
                    const Color(0xFF86316A),
                    const Color(0xFF6A0792)
                  ], // whitish to gray
                  // repeats the gradient over the canvas
                ),
              ),
              child: Column(
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height * 0.20,
                    alignment: Alignment.center,
                    child: Container(
                      alignment: Alignment.center,
                      child: Hero(
                        tag: widget.position,
                        transitionOnUserGestures: true,
                        child: CircleAvatar(
                          radius: MediaQuery.of(context).size.height * 0.08,
                          child: SvgPicture.asset('assets/puzzle.svg',
                              semanticsLabel: 'A red up arrow'),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    //width: _sizeAnimation.value,
                    margin: EdgeInsets.only(top: 10),
                    child: Text(
                      'WORD SEARCH',
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontWeight: FontWeight.bold,
                        fontSize: _sizeAnimation.value,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Expanded(
                    child: Container(
                      //color: Colors.blue[500],
                      padding: EdgeInsets.only(
                          left: 10, right: 10, top: 30, bottom: 5),
                      alignment: Alignment.topCenter,
                      child: Stack(
                        children: <Widget>[
                          SizeTransition(
                            axis: Axis.vertical,
                            sizeFactor: _cardAnimation,
                            child: Material(
                              borderRadius: BorderRadius.circular(15),
                              color: Color(0xe6ffffff),
                              elevation: 3,
                              child: FadeTransition(
                                opacity: _contentAnimation,
                                child: Container(
                                  padding: EdgeInsets.only(
                                      top: 30, left: 25, right: 16, bottom: 20),
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Your Recent Scores',
                                          style: TextStyle(
                                            color: Colors.grey[800],
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Divider(
                                        height: 1,
                                        thickness: 1,
                                        color: Colors.grey[700],
                                      ),
                                      Container(
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: 5,
                                          itemBuilder: (context, index) {
                                            return Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.07,
                                              child: Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    child: Container(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                        '1300',
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        '6 days ago',
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),

                              //color: Colors.amber,
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            right: 50,
                            left: 50,
                            child: RectGetter(
                              //<-- Wrap Fab with RectGetter
                              key: rectGetterKey, //<-- Passing the key
                              child: Transform.scale(
                                scale: _fabAnimation.value,
                                child: FloatingActionButton(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  onPressed: () {
                                    _onTap();
                                  },
                                  child: Icon(Icons.play_arrow),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        _ripple()
      ],
    );
  }
}

class FadeRouteBuilder<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadeRouteBuilder({@required this.page})
      : super(
          pageBuilder: (context, animation1, animation2) => page,
          transitionsBuilder: (context, animation1, animation2, child) {
            return FadeTransition(opacity: animation1, child: child);
          },
        );
}
