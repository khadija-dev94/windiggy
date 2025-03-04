import 'package:flutter/material.dart';
import 'package:win_diggy/Models/GlobalTranslations.dart';
import 'package:win_diggy/Globals.dart' as globals;

class SlideScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return InstructScreenState();
  }
}

class InstructScreenState extends State<SlideScreen> {
  List<String> images = new List();
  List<String> titles = new List();
  List<String> desc = new List();
  PageController controller = PageController(initialPage: 0);
  int currentPage;
  Color firstPage;
  Color secPage;
  Color thirdPage;
  Color fourthPage;
  Color fifthPage;
  Color sixthPage;
  bool slidesEnd;
  String rightBtnText;
  String leftBtnText;
  int currentRad;
  int inactiveRad;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    rightBtnText = 'NEXT';
    leftBtnText = 'SKIP';
    currentRad = 5;
    inactiveRad = 4;
    currentPage = 0;
    firstPage = Color(0xffeccb58);
    secPage = Colors.grey[300];
    thirdPage = Colors.grey[300];
    fourthPage = Colors.grey[300];
    fifthPage = Colors.grey[300];
    sixthPage = Colors.grey[300];
    slidesEnd = false;

    images = [
      'assets/road.png',
      'assets/Clock.png',
      'assets/Race.png',
      'assets/instant-reward.png',
      'assets/grow.png',
      'assets/logo.png',
    ];
    titles = [
      allTranslations.text('slide1_desc'),
      allTranslations.text('slide2_title'),
      allTranslations.text('slide3_title'),
      allTranslations.text('slide4_title'),
      allTranslations.text('slide5_title'),
      allTranslations.text('slide6_title'),
    ];
    desc = [
      '',
      allTranslations.text('slide2_desc'),
      allTranslations.text('slide3_desc'),
      allTranslations.text('slide4_desc'),
      allTranslations.text('slide5_desc'),
      allTranslations.text('slide6_desc'),
    ];
  }

  changeColor(pos) {
    setState(() {
      if (pos == 0) {
        firstPage = Color(0xffeccb58);
        secPage = Colors.grey[300];
        thirdPage = Colors.grey[300];
        fourthPage = Colors.grey[300];
        fifthPage = Colors.grey[300];
        sixthPage = Colors.grey[300];
      } else if (pos == 1) {
        secPage = Color(0xffeccb58);
        firstPage = Colors.grey[300];
        thirdPage = Colors.grey[300];
        fourthPage = Colors.grey[300];
        fifthPage = Colors.grey[300];
        sixthPage = Colors.grey[300];
      } else if (pos == 2) {
        thirdPage = Color(0xffeccb58);
        firstPage = Colors.grey[300];
        secPage = Colors.grey[300];
        fourthPage = Colors.grey[300];
        fifthPage = Colors.grey[300];
        sixthPage = Colors.grey[300];
      } else if (pos == 3) {
        fourthPage = Color(0xffeccb58);
        firstPage = Colors.grey[300];
        secPage = Colors.grey[300];
        thirdPage = Colors.grey[300];

        fifthPage = Colors.grey[300];
        sixthPage = Colors.grey[300];
      } else if (pos == 4) {
        fifthPage = Color(0xffeccb58);
        firstPage = Colors.grey[300];
        secPage = Colors.grey[300];
        thirdPage = Colors.grey[300];
        fourthPage = Colors.grey[300];
        sixthPage = Colors.grey[300];
      } else if (pos == 5) {
        sixthPage = Color(0xffeccb58);
        firstPage = Colors.grey[300];
        secPage = Colors.grey[300];
        thirdPage = Colors.grey[300];
        fourthPage = Colors.grey[300];
        fifthPage = Colors.grey[300];
      }
    });
  }

  changeText() {
    setState(() {
      leftBtnText = 'PREV';
      rightBtnText = "LET'S START";
    });
  }

  Future<bool> closeScreen(context) async {
    if (globals.LoggedIn) {
      globals.HOMEONFRONT = true;
      globals.onceInserted = false;
     // Navigator.of(context).pop();
      globals.resumeCalledOnce=false;
      Navigator.popAndPushNamed(context, '/dashboard');
    } else
      Navigator.of(context).pop();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    Widget page(String image, String title, String desc) {
      return Container(
        //  color: Colors.blue[100],
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.11,
                width: MediaQuery.of(context).size.height * 0.11,
                child: Image.asset(
                  'assets/logo.png',
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 20, left: 30, right: 30),
              alignment: Alignment.center,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    height: 1.3),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 10, left: 30, right: 30),
              alignment: Alignment.center,
              child: Text(
                desc,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[200],
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),
            Expanded(
              child: Container(
                // color: Colors.blue[100],
                alignment: Alignment.center,
                margin: title == allTranslations.text('slide6_title')
                    ? EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.10)
                    : EdgeInsets.all(0.0),
                child: Image.asset(
                  image,
                  fit: BoxFit.scaleDown,
                  height: title == allTranslations.text('slide6_title')
                      ? MediaQuery.of(context).size.height * 0.30
                      : MediaQuery.of(context).size.height * 0.40,
                  width: title == allTranslations.text('slide6_title')
                      ? MediaQuery.of(context).size.height * 0.30
                      : MediaQuery.of(context).size.height * 0.40,
                ),
              ),
            ),
            title == allTranslations.text('slide6_title')
                ? Container(
                    //color: Colors.blue[100],
                    margin: EdgeInsets.only(
                      bottom: MediaQuery.of(context).size.height * 0.20,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'WinDiggy',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 35,
                        height: 1.3,
                      ),
                    ),
                  )
                : SizedBox()
          ],
        ),
      );
    }

    // TODO: implement build
    return WillPopScope(
      onWillPop: () {
        return closeScreen(context);
      },
      child: Scaffold(
        body: SafeArea(
          top: false,
          child: Container(
            height: double.infinity,
            width: double.infinity,
            color: Colors.black,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: Container(
                    // color: Colors.blue,
                    margin: EdgeInsets.only(top: 40),
                    child: PageView.builder(
                      //physics: new NeverScrollableScrollPhysics(),
                      controller: controller,
                      itemBuilder: (context, position) {
                        return page(
                            images[position], titles[position], desc[position]);
                      },
                      itemCount: images.length,
                      onPageChanged: (pos) {
                        if (pos == 5) changeText();
                        print(pos);
                        currentPage = pos;
                        changeColor(pos);
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    iconTheme:
                        IconThemeData(color: Theme.of(context).accentColor),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 10,
                  right: 10,
                  child: Row(
                    children: <Widget>[
                      Container(
                        // color: Colors.blue[200],
                        child: GestureDetector(
                          onTap: () {
                            if (leftBtnText == 'SKIP')
                              closeScreen(context);
                            else if (leftBtnText == 'PREV') {
                              --currentPage;
                              controller.animateToPage(currentPage,
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeInOut);
                              changeColor(currentPage);
                            }
                          },
                          child: Material(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 3,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                width: 100,
                                height: 25,
                                alignment: Alignment.center,
                                /*decoration: BoxDecoration(
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
                            ),*/
                                color: Theme.of(context).accentColor,
                                padding: EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 5),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    leftBtnText == "PREV"
                                        ? FittedBox(
                                            child: Icon(
                                              Icons.keyboard_arrow_left,
                                              color: Colors.black,
                                              //size: 30,
                                            ),
                                          )
                                        : SizedBox(),
                                    Text(
                                      leftBtnText,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          // color: Colors.blue[100],
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                child: CircleAvatar(
                                  radius: 4,
                                  backgroundColor: firstPage,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                child: CircleAvatar(
                                  radius: 4,
                                  backgroundColor: secPage,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                child: CircleAvatar(
                                  radius: 4,
                                  backgroundColor: thirdPage,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                child: CircleAvatar(
                                  radius: 4,
                                  backgroundColor: fourthPage,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                child: CircleAvatar(
                                  radius: 4,
                                  backgroundColor: fifthPage,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                child: CircleAvatar(
                                  radius: 4,
                                  backgroundColor: sixthPage,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        //  color: Colors.blue[200],
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            if (rightBtnText == 'NEXT') {
                              ++currentPage;
                              controller.animateToPage(currentPage,
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeInOut);
                              changeColor(currentPage);
                            } else if (rightBtnText == "LET'S START")
                              closeScreen(context);
                          },
                          child: Material(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                width: 90,
                                height: 25,
                                alignment: Alignment.center,
                                /*decoration: BoxDecoration(
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
                            ),*/
                                color: Theme.of(context).accentColor,
                                padding: EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 5),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      rightBtnText,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12,
                                      ),
                                    ),
                                    rightBtnText == "LET'S START"
                                        ? SizedBox()
                                        : FittedBox(
                                            child: Icon(
                                              Icons.keyboard_arrow_right,
                                              color: Colors.black,
                                              //size: 20,
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                            ),
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
    );
  }
}
