import 'package:auto_direction/auto_direction.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:win_diggy/Models/GlobalTranslations.dart';
import 'package:win_diggy/Models/Question.dart';
import 'package:win_diggy/Widgets/ScrollBarAlwaysVisible.dart';
import 'package:video_player/video_player.dart';
import 'PracticeQuizScreen.dart';

class MCQItem extends StatefulWidget {
  int position;
  Question singleQuestion;
  var currentQue;
  var total;

  MCQItem({
    this.position,
    this.singleQuestion,
    this.currentQue,
    this.total,
  });

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MCQCardState();
  }
}

class MCQCardState extends State<MCQItem> {
  var color1;
  var color2;
  var color3;
  var color4;
  String language = allTranslations.currentLanguage;
  VideoPlayerController _videoCont;
  VideoPlayerController _videoPlayerController1;
  ChewieController _chewieController;

  @override
  void initState() {
    // TODO: implement initState

    print('MCQ TYPE: ${widget.singleQuestion.MCQType}');
    if (widget.singleQuestion.MCQType == "video") {
      _videoPlayerController1 =
          VideoPlayerController.network(widget.singleQuestion.url);
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController1,
        aspectRatio: 3 / 1.8,
        autoPlay: true,
        looping: false,
      );
    }

    super.initState();
    color1 = Colors.white;
    color2 = Colors.white;
    color3 = Colors.white;
    color4 = Colors.white;
    print('CORRECT ANSWER: ${widget.singleQuestion.correctOptionEng}');
  }

  @override
  void dispose() {
    if (_chewieController != null) {
      //_videoCont.dispose();
      _videoPlayerController1.dispose();
      _chewieController.dispose();
    }

    super.dispose();
  }

  Future setTrueColor(var color) async {
    setState(() {
      if (color == 0) color1 = Colors.lightGreen;
      if (color == 1) color2 = Colors.lightGreen;
      if (color == 2) color3 = Colors.lightGreen;
      if (color == 3) color4 = Colors.lightGreen;
      widget.singleQuestion.answerSubmit = true;
    });
  }

  Future setFalseColor(var color) async {
    setState(() {
      if (color == 0) color1 = Colors.red;
      if (color == 1) color2 = Colors.red;
      if (color == 2) color3 = Colors.red;
      if (color == 3) color4 = Colors.red;
      widget.singleQuestion.answerSubmit = true;
    });
  }

  Future checkTrueAnswer(var pos) async {
    await setTrueColor(pos);
    MSQSView.of(context).setNextPage(true, widget.position);
  }

  Future checkFalseAnswer(var color) async {
    await setFalseColor(color);
    MSQSView.of(context).setNextPage(false, widget.position);
  }

  Widget checkWidget() {
    if (widget.singleQuestion.MCQType == 'video')
      return Container(
        child: Chewie(
          controller: _chewieController,
        ),
      );
    else if (widget.singleQuestion.MCQType == 'image')
      return Container(
        //color: Colors.blue[100],
        child: CachedNetworkImage(
          height: MediaQuery.of(context).size.height * 0.23,
          width: double.infinity,
          fit: BoxFit.fill,
          imageUrl: widget.singleQuestion.url,
          placeholder: (context, url) => Center(
            child: CircularProgressIndicator(),
          ),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
      );
    else
      return SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      alignment: Alignment.center,
      //color: Colors.blue[200],
      padding: EdgeInsets.only(left: 10, right: 10),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        margin: EdgeInsets.only(bottom: 5, top: 20),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: SingleChildScrollViewWithScrollbar(
                scrollbarColor: Color(0xffeccb58),
                scrollbarThickness: 7.0,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: viewportConstraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Container(
                      padding: EdgeInsets.only(
                        top: 10,
                        left: 10,
                        right: 10,
                        bottom: 20,
                      ),
                      child: Column(
                        // mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            alignment: Alignment.center,
                            //color: Colors.blue[100],
                            //padding: EdgeInsets.symmetric(horizontal: 20),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment(0.8, -2.0),
                                    end: Alignment(0.0, 2.8),
                                    colors: [
                                      // Colors are easy thanks to Flutter's Colors class.
                                      Color(0xff5c4710),
                                      Color(0xffeccb58),
                                      Color(0xff5c4710),

                                      // Color(0xff5c4710),
                                    ],
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 8),
                                  child: Text(
                                    widget.currentQue.toString() +
                                        " of " +
                                        widget.total.toString(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(top: 30),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  //mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    checkWidget(),
                                    Container(
                                      //color: Colors.blue[100],
                                      margin: EdgeInsets.only(
                                        top: 20,
                                        left: 12,
                                        right: 12,
                                      ),
                                      child: SizedBox(
                                        child: AutoDirection(
                                          text: language == 'ur'
                                              ? widget
                                                  .singleQuestion.questionUrd
                                              : widget
                                                  .singleQuestion.questionEng,
                                          child: Text(
                                            language == 'ur'
                                                ? widget
                                                    .singleQuestion.questionUrd
                                                : widget
                                                    .singleQuestion.questionEng,
                                            textAlign: TextAlign.justify,
                                            style: TextStyle(
                                              color: Colors.grey[800],
                                              fontSize: 16,
                                              height: 1.5,
                                              fontWeight: FontWeight.w700,
                                              fontFamily: 'Signika Semibold',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: 30),
                                      child: GestureDetector(
                                        onTap: () async {
                                          if (!widget
                                              .singleQuestion.answerSubmit) {
                                            if (language == 'ur') {
                                              if (widget.singleQuestion
                                                      .optionAUrd ==
                                                  widget.singleQuestion
                                                      .correctOptionUrd)
                                                checkTrueAnswer(0);
                                              else
                                                checkFalseAnswer(0);
                                            } else {
                                              if (widget.singleQuestion
                                                      .optionAEng ==
                                                  widget.singleQuestion
                                                      .correctOptionEng)
                                                checkTrueAnswer(0);
                                              else
                                                checkFalseAnswer(0);
                                            }
                                          }
                                        },
                                        child: Material(
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                                color: Colors.grey[500]),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          color: color1,
                                          child: Container(
                                            alignment: language == 'ur'
                                                ? Alignment.centerRight
                                                : Alignment.centerLeft,
                                            padding: EdgeInsets.symmetric(
                                              vertical: 15,
                                              horizontal: 25,
                                            ),
                                            child: SizedBox(
                                              child: AutoDirection(
                                                text: language == 'ur'
                                                    ? widget.singleQuestion
                                                        .optionAUrd
                                                    : widget.singleQuestion
                                                        .optionAEng,
                                                child: Text(
                                                  language == 'ur'
                                                      ? widget.singleQuestion
                                                          .optionAUrd
                                                      : widget.singleQuestion
                                                          .optionAEng,
                                                  //textAlign: TextAlign.right,
                                                  style: TextStyle(
                                                    color: Colors.grey[800],
                                                    fontSize: 15,
                                                    height: 1.2,
                                                    // fontWeight: FontWeight.w600,
                                                    fontFamily: 'Signika Light',
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: 10),
                                      child: GestureDetector(
                                        onTap: () async {
                                          if (!widget
                                              .singleQuestion.answerSubmit) {
                                            if (language == 'ur') {
                                              if (widget.singleQuestion
                                                      .optionBUrd ==
                                                  widget.singleQuestion
                                                      .correctOptionUrd)
                                                checkTrueAnswer(1);
                                              else
                                                checkFalseAnswer(1);
                                            } else {
                                              if (widget.singleQuestion
                                                      .optionBEng ==
                                                  widget.singleQuestion
                                                      .correctOptionEng)
                                                checkTrueAnswer(1);
                                              else
                                                checkFalseAnswer(1);
                                            }
                                          }
                                        },
                                        child: Material(
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                                color: Colors.grey[500]),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          color: color2,
                                          child: Container(
                                            alignment: language == 'ur'
                                                ? Alignment.centerRight
                                                : Alignment.centerLeft,
                                            padding: EdgeInsets.symmetric(
                                              vertical: 15,
                                              horizontal: 25,
                                            ),
                                            child: SizedBox(
                                              child: AutoDirection(
                                                text: language == 'ur'
                                                    ? widget.singleQuestion
                                                        .optionBUrd
                                                    : widget.singleQuestion
                                                        .optionBEng,
                                                child: Text(
                                                  language == 'ur'
                                                      ? widget.singleQuestion
                                                          .optionBUrd
                                                      : widget.singleQuestion
                                                          .optionBEng,
                                                  style: TextStyle(
                                                    color: Colors.grey[800],
                                                    fontSize: 15,
                                                    height: 1.2,
                                                    // fontWeight: FontWeight.w600,
                                                    fontFamily: 'Signika Light',
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: 10),
                                      child: GestureDetector(
                                        onTap: () async {
                                          if (!widget
                                              .singleQuestion.answerSubmit) {
                                            if (language == 'ur') {
                                              if (widget.singleQuestion
                                                      .optionCUrd ==
                                                  widget.singleQuestion
                                                      .correctOptionUrd)
                                                checkTrueAnswer(2);
                                              else
                                                checkFalseAnswer(2);
                                            } else {
                                              if (widget.singleQuestion
                                                      .optionCEng ==
                                                  widget.singleQuestion
                                                      .correctOptionEng)
                                                checkTrueAnswer(2);
                                              else
                                                checkFalseAnswer(2);
                                            }
                                          }
                                        },
                                        child: Material(
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                                color: Colors.grey[500]),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          color: color3,
                                          child: Container(
                                            alignment: language == 'ur'
                                                ? Alignment.centerRight
                                                : Alignment.centerLeft,
                                            padding: EdgeInsets.symmetric(
                                                vertical: 15, horizontal: 25),
                                            child: SizedBox(
                                              child: AutoDirection(
                                                text: language == 'ur'
                                                    ? widget.singleQuestion
                                                        .optionCUrd
                                                    : widget.singleQuestion
                                                        .optionCEng,
                                                child: Text(
                                                  language == 'ur'
                                                      ? widget.singleQuestion
                                                          .optionCUrd
                                                      : widget.singleQuestion
                                                          .optionCEng,
                                                  style: TextStyle(
                                                    color: Colors.grey[800],
                                                    fontSize: 15,
                                                    height: 1.2,
                                                    // fontWeight: FontWeight.w600,
                                                    fontFamily: 'Signika Light',
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: 10),
                                      child: GestureDetector(
                                        onTap: () async {
                                          print(
                                              '${widget.singleQuestion.optionDEng}');
                                          print(
                                              '${widget.singleQuestion.correctOptionEng}');
                                          if (!widget
                                              .singleQuestion.answerSubmit) {
                                            if (language == 'ur') {
                                              if (widget.singleQuestion
                                                      .optionDUrd ==
                                                  widget.singleQuestion
                                                      .correctOptionUrd)
                                                checkTrueAnswer(3);
                                              else
                                                checkFalseAnswer(3);
                                            } else {
                                              if (widget.singleQuestion
                                                      .optionDEng ==
                                                  widget.singleQuestion
                                                      .correctOptionEng)
                                                checkTrueAnswer(3);
                                              else
                                                checkFalseAnswer(3);
                                            }
                                          }
                                        },
                                        child: Material(
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                                color: Colors.grey[500]),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          color: color4,
                                          child: Container(
                                            alignment: language == 'ur'
                                                ? Alignment.centerRight
                                                : Alignment.centerLeft,
                                            padding: EdgeInsets.symmetric(
                                                vertical: 15, horizontal: 25),
                                            child: SizedBox(
                                              child: AutoDirection(
                                                text: language == 'ur'
                                                    ? widget.singleQuestion
                                                        .optionDUrd
                                                    : widget.singleQuestion
                                                        .optionDEng,
                                                child: Text(
                                                  language == 'ur'
                                                      ? widget.singleQuestion
                                                          .optionDUrd
                                                      : widget.singleQuestion
                                                          .optionDEng,
                                                  style: TextStyle(
                                                    color: Colors.grey[800],
                                                    fontSize: 15,
                                                    height: 1.2,
                                                    // fontWeight: FontWeight.w600,
                                                    fontFamily: 'Signika Light',
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
