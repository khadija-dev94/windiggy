import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:win_diggy/CustomIcons/puzzle_icons_icons.dart';
import 'package:win_diggy/Models/GlobalTranslations.dart';
import 'package:win_diggy/Screen/ContactUsScreen.dart';
import 'package:win_diggy/Screen/FBMessagesScreen.dart';
import 'package:win_diggy/Screen/GameRulesScreen.dart';
import 'package:win_diggy/Screen/DailyContestScreen.dart';
import 'package:win_diggy/Screen/LeaderBoardScreen.dart';
import 'package:win_diggy/Screen/MyScoreBoardScreen.dart';
import 'package:win_diggy/Screen/PracticeGames/PracticeGamesScreen.dart';
import 'package:win_diggy/Screen/ProfileScreen.dart';
import 'package:win_diggy/Screen/PublicMessagesScreen.dart';
import 'package:win_diggy/Screen/SlideScreen.dart';
import 'package:win_diggy/Screen/TermsCondScreen.dart';
import 'package:win_diggy/Screen/PrivacyScreen.dart';

import 'package:win_diggy/Screen/WinnersScreen.dart';
import 'package:win_diggy/Globals.dart' as globals;
import 'package:flutter_svg/flutter_svg.dart';

class SideDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.75,
      height: MediaQuery.of(context).size.height, //20.0,
      child: Container(
        alignment: Alignment.center,
        color: Colors.white,
        child: new ListView(
          padding: const EdgeInsets.only(top: 0, left: 0, right: 0),
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(0.08, -2.8),
                  end: Alignment(0.0, 2.8),
                  colors: [
                    Color(0xff5c4710),
                    Color(0xffeccb58),
                    Color(0xff5c4710),
                  ],
                ),
              ),
              padding: EdgeInsets.only(left: 20, right: 16, bottom: 0, top: 30),
              alignment: Alignment.bottomCenter,
              //color: Colors.blue[100],
              height: MediaQuery.of(context).size.height * 0.30,
              child: Row(
                children: <Widget>[
                  Container(
                    alignment: Alignment.bottomLeft,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.centerLeft,
                          child: globals.temImage != null
                              ? CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius:
                                      MediaQuery.of(context).size.height * 0.07,
                                  backgroundImage: FileImage(globals.temImage),
                                )
                              : CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius:
                                      MediaQuery.of(context).size.height * 0.07,
                                  backgroundImage: globals.profileURL == ''
                                      ? ExactAssetImage('assets/defaultImg.png')
                                      : new CachedNetworkImageProvider(
                                          globals.profileURL,
                                        ),
                                ),
                        ),
                        Container(
                          padding: EdgeInsets.only(
                              left: 10, right: 16, bottom: 15, top: 10),
                          alignment: Alignment.centerLeft,
                          //color: Colors.blue[100],
                          //height: MediaQuery.of(context).size.height * 0.25,
                          child: Text(
                            globals.username,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(top: 10),
                      alignment: Alignment.topRight,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  alignment: Alignment.centerLeft,
                                  child: SvgPicture.asset(
                                    'assets/star.svg',
                                    height: 17,
                                    width: 17,
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  margin: EdgeInsets.only(left: 8),
                                  child: Text(
                                    globals.userScore,
                                    style: TextStyle(
                                      color: Colors.grey[800],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          globals.userPosition != ''
                              ? Container(
                                  margin: EdgeInsets.only(top: 5),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        child: SvgPicture.asset(
                                          'assets/rank.svg',
                                          height: 25,
                                          width: 25,
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        margin: EdgeInsets.only(left: 5),
                                        child: Text(
                                          globals.userPosition,
                                          style: TextStyle(
                                            color: Colors.grey[800],
                                            fontWeight: FontWeight.w600,
                                            fontSize: 35,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : SizedBox()
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              padding: EdgeInsets.only(left: 10),
              child: Column(
                children: <Widget>[
                  new ListTile(
                    leading: new Icon(
                      Icons.account_circle,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: new Text(
                      allTranslations.text('profile'),
                      style: TextStyle(fontSize: 15),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      globals.HOMEONFRONT = false;
                      if (globals.updateListener != null)
                        globals.updateListener.cancel();
                      globals.updateCalledOnce = false;
                      globals.updateCalledOnce = false;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(),
                        ),
                      );
                    },
                  ),
                  new ListTile(
                    leading: new Icon(
                      Icons.speaker_notes,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: new Text(
                      allTranslations.text('game_rules'),
                      style: TextStyle(fontSize: 15),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      globals.HOMEONFRONT = false;
                      if (globals.updateListener != null)
                        globals.updateListener.cancel();
                      globals.updateCalledOnce = false;
                      globals.updateCalledOnce = false;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GameRules(),
                        ),
                      );
                    },
                  ),
                  new ListTile(
                    leading: new Icon(
                      PuzzleIcons.cup,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: new Text(
                      allTranslations.text('winners'),
                      style: TextStyle(fontSize: 15),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      globals.HOMEONFRONT = false;
                      if (globals.updateListener != null)
                        globals.updateListener.cancel();
                      globals.updateCalledOnce = false;
                      globals.updateCalledOnce = false;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WinnersScreen(),
                        ),
                      );
                    },
                  ),
                  new ListTile(
                    leading: new Icon(
                      PuzzleIcons.score,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: new Text(
                      allTranslations.text('leaderboard'),
                      style: TextStyle(fontSize: 15),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      globals.HOMEONFRONT = false;
                      if (globals.updateListener != null)
                        globals.updateListener.cancel();
                      globals.updateCalledOnce = false;
                      globals.updateCalledOnce = false;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ScoreBoardScreen(),
                        ),
                      );
                    },
                  ),
                  new ListTile(
                    leading: new Icon(
                      PuzzleIcons.scoreboard,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: new Text(
                      allTranslations.text('scoreboard'),
                      style: TextStyle(fontSize: 15),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      globals.HOMEONFRONT = false;
                      if (globals.updateListener != null)
                        globals.updateListener.cancel();
                      globals.updateCalledOnce = false;
                      globals.updateCalledOnce = false;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyScoreBoardScreen(),
                        ),
                      );
                    },
                  ),
                  new ListTile(
                    leading: new Icon(
                      PuzzleIcons.cup,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: new Text(
                      allTranslations.text('practice'),
                      style: TextStyle(fontSize: 15),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      globals.HOMEONFRONT = false;
                      if (globals.updateListener != null)
                        globals.updateListener.cancel();
                      globals.updateCalledOnce = false;
                      globals.updateCalledOnce = false;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PracticeGameScreen(),
                        ),
                      );
                    },
                  ),
                  new ListTile(
                    leading: new Icon(
                      PuzzleIcons.live_chat,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: new Text(
                      allTranslations.text('live_chat'),
                      style: TextStyle(fontSize: 15),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      globals.HOMEONFRONT = false;
                      if (globals.updateListener != null)
                        globals.updateListener.cancel();
                      globals.updateCalledOnce = false;
                      globals.updateCalledOnce = false;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FBMessagesScreen(),
                        ),
                      );
                    },
                  ),
                  new ListTile(
                    leading: new Icon(
                      PuzzleIcons.live_chat,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: new Text(
                      allTranslations.text('public_chat'),
                      style: TextStyle(fontSize: 15),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      globals.HOMEONFRONT = false;
                      if (globals.updateListener != null)
                        globals.updateListener.cancel();
                      globals.updateCalledOnce = false;
                      globals.updateCalledOnce = false;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PublicMessagesScreen(),
                        ),
                      );
                    },
                  ),
                  new ListTile(
                    leading: new Icon(
                      Icons.settings,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: new Text(
                      allTranslations.text('how_it_works'),
                      style: TextStyle(fontSize: 15),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      globals.HOMEONFRONT = false;

                      if (globals.updateListener != null)
                        globals.updateListener.cancel();
                      globals.updateCalledOnce = false;
                      globals.updateCalledOnce = false;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SlideScreen(),
                        ),
                      );
                    },
                  ),
                  new ListTile(
                    leading: new Icon(
                      Icons.phone,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: new Text(
                      allTranslations.text('contact_us'),
                      style: TextStyle(fontSize: 15),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      globals.HOMEONFRONT = false;
                      if (globals.updateListener != null)
                        globals.updateListener.cancel();
                      globals.updateCalledOnce = false;
                      globals.updateCalledOnce = false;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ContactUsScreen(),
                        ),
                      );
                    },
                  ),
                  /*new ListTile(
                    leading: new Icon(
                      Icons.description,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: new Text(
                      allTranslations.text('terms_cond'),
                      style: TextStyle(fontSize: 15),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      globals.HOMEONFRONT = false;
                      if (globals.updateListener != null)
                        globals.updateListener.cancel();

                      globals.LoggedIn=true;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TermsCond(),
                        ),
                      );
                    },
                  ),*/

                  new ListTile(
                    leading: new Icon(
                      Icons.description,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: new Text(
                      allTranslations.text('privacy'),
                      style: TextStyle(fontSize: 15),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      globals.HOMEONFRONT = false;

                      if (globals.updateListener != null)
                        globals.updateListener.cancel();
                      globals.updateCalledOnce = false;
                      globals.updateCalledOnce = false;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Privacy(),
                        ),
                      );
                    },
                  ),
                  new ListTile(
                    leading: new Icon(
                      Icons.description,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: new Text(
                      allTranslations.text('terms_cond'),
                      style: TextStyle(fontSize: 15),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      globals.HOMEONFRONT = false;

                      if (globals.updateListener != null)
                        globals.updateListener.cancel();
                      globals.updateCalledOnce = false;
                      globals.updateCalledOnce = false;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Terms(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
