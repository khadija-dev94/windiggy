import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

class InstructScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return InstructScreenState();
  }
}

class InstructScreenState extends State<InstructScreen> {
  List<String> images = new List();
  List<String> titles = new List();
  List<String> desc = new List();
  String rightBtnText;
  String leftBtnText;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    rightBtnText = 'NEXT';
    leftBtnText = 'SKIP';
    images = [
      'assets/road.png',
      'assets/Clock.png',
      'assets/Icons.png',
      'assets/grow.png',
      'assets/Race.png',
      'assets/goodluck.png',
    ];
    titles = [
      'Money Gali where you Win',
      'WAIT FOR GAME TO BEGIN',
      'INSTANT REWARDS',
      'AS WE GROW THE PRIZES GROW',
      'RACE TO WIN',
      'GOOD LUCK',
    ];
    desc = [
      '',
      'Wait for the game to begin',
      'A Message will be sent ot the user. To receive cash there is an option of EasyPaisa and DIrect Deposit.',
      'Cash Ammount and Prizes will become BIGGER and BIGGER as our community grow.',
      'The fastest one to complete the game Wins.',
      'Get Rich and Keep trying',
    ];
  }

  changeText() {
    setState(() {
      leftBtnText = 'PREV';
      rightBtnText = 'HOME';
    });
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
                height: MediaQuery.of(context).size.height * 0.12,
                width: MediaQuery.of(context).size.height * 0.12,
                child: SvgPicture.asset(
                  'assets/logo.svg',
                  semanticsLabel: 'A red up arrow',
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 20, left: 30, right: 30),
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 10, left: 30, right: 30),
              child: Text(
                desc,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),
            Expanded(
              child: Container(
                //color: Colors.blue[100],
                alignment: Alignment.center,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.40,
                  width: MediaQuery.of(context).size.height * 0.40,
                  child: Image.asset(
                    image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // TODO: implement build
    return Scaffold(
      body: SafeArea(
        top: false,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Container(
                // color: Colors.blue,
                padding: EdgeInsets.only(top: 50),
                child: Swiper(
                  itemBuilder: (BuildContext context, int index) {
                    return page(images[index], titles[index], desc[index]);
                  },
                  curve: Curves.easeInOut,
                  itemCount: images.length,
                  pagination: new SwiperPagination(),
                  onIndexChanged: (pos) {
                    if (pos == 5) changeText();
                  },
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                child: FlatButton(
                  onPressed: () {},
                  child: Text(
                    leftBtnText,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                child: FlatButton(
                  onPressed: () {},
                  child: Text(
                    rightBtnText,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
