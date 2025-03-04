import 'dart:async';
import 'dart:convert';
import 'package:countdown/countdown.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:win_diggy/Models/URLS.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:pin_entry_text_field/pin_entry_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:win_diggy/Globals.dart' as globals;
import 'package:win_diggy/Models/GlobalTranslations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/////////////////////////FULL SCREEN DIALOG CONTENT
class VerifyScreenDialog extends StatefulWidget {
  String phone;
  String username;
  String email;
  String password;
  String dialCode;

  VerifyScreenDialog({
    this.phone,
    this.username,
    this.email,
    this.password,
    this.dialCode,
  });

  @override
  VerifyScreenState createState() => new VerifyScreenState();
}

class VerifyScreenState extends State<VerifyScreenDialog> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController phoneTxt = new TextEditingController();
  var isLoading = false;
  var succes = false;
  String verificationId;
  //var time;
  bool timerFinished;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String verCode;
  FirebaseMessaging _fcm = FirebaseMessaging();
  FirebaseAuth _auth = FirebaseAuth.instance;
  var FCM;
  String contact;
  Stopwatch watch = new Stopwatch();
  Timer timer;
  Duration timerDuration = new Duration(minutes: 1);
  String min;
  String sec;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    verCode = '';
    //time = '00:00';
    min = '00';
    sec = '00';
    verifyPhone();
    startTimer();
    timerFinished = false;
    getFCMToken();
    contact = widget.phone.substring(0, 0) +
        widget.dialCode +
        widget.phone.substring(0 + 1);
    print(contact);
  }

  getFCMToken() {
    _fcm.getToken().then((token) {
      print(token);
      FCM = token;
    });
  }

  void dispose() {
    // TODO: implement dispose
    phoneTxt.dispose();
    super.dispose();

    watch.stop();
    if (timer != null) timer.cancel();
  }

  startTimer() {
    ////////////////////////////////////////////////////START REVERSE TIMER
    watch.start();
    timer = new Timer.periodic(new Duration(seconds: 1), reverseTimerCallback);
  }

  Future reverseTimerCallback(Timer t) {
    if (watch.isRunning) {
      timerDuration = timerDuration - Duration(seconds: 1);

      if (!timerDuration.isNegative) {
        setState(() {
          min =
              timerDuration.inMinutes.remainder(60).toString().padLeft(2, '0');
          sec = (timerDuration.inSeconds.remainder(60))
              .toString()
              .padLeft(2, '0');
        });
      } else {
        watch.stop();
        if (timer != null) timer.cancel();
        setState(() {
          timerFinished = true;
        });
      }
    }
  }

  void signup(BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    Map userdata = {
      'fcmtoken': FCM,
      'country': 'Pakistan',
      'phone': widget.phone,
    };
    print(userdata);
    http.Response response =
        await http.post(URLS.customLogin, body: json.encode(userdata));

    print('CUSTOM LOGGIN');
    print(userdata);
    print(response.body);
    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON
      Map mapobject = (json.decode(response.body));
      var succes = mapobject['success'];
      if (succes) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('username', mapobject['user']['username']);
        prefs.setString('id', mapobject['user']['id'].toString());
        prefs.setString('profilePic', mapobject['user']['profilePicture']);
        prefs.setString('email', mapobject['user']['email']);
        prefs.setString('address', mapobject['user']['address']);
        prefs.setString('contact', mapobject['user']['phone']);
        prefs.setString('country', mapobject['user']['country']);
        prefs.setBool('loggedIn', true);
        globals.userID = mapobject['user']['id'].toString();
        globals.country = prefs.getString('country');
        globals.username = prefs.getString('username');
        globals.profileURL = mapobject['user']['profilePicture'];
        List<String> myName = new List();
        myName = globals.username.split(" ");
        String initials = '';
        for (int i = 0; i < myName.length; i++) {
          initials = initials + myName[i].substring(0, 1);
        }
        globals.initials = initials;

        setState(() {
          isLoading = false;
        });
        ///////////////////////////////////CLEARROUTES FROM STACK AND MOVE TO HOME SCREEN
        Navigator.of(context).pushNamedAndRemoveUntil(
            '/dashboard', (Route<dynamic> route) => false);
      } else {
        succes = false;
        print(response.body);
        setState(() {
          isLoading = false;
        });
      }
    } else {
      print('response code not 200');
      print(response.body);
    }
  }

  //////////////////////////////////////////////////VERIFY PHONE NUMBER
  Future<void> verifyPhone() async {
    setState(() {
      isLoading = true;
    });

    /*final PhoneVerificationCompleted verifiedSuccess =
        (AuthCredential credential) {
      print('VERIFIED');
      setState(() {
        isLoading = false;
      });
      // sub.cancel();

      final PhoneVerificationCompleted verificationCompleted =
          (AuthCredential auth) {
            setState(() {
              isLoading = false;
            });
        _auth.signInWithCredential(credential).then((AuthResult value) {
          if (value.user != null) {
            print('AUTO VERIFIED SUCCESSFULL');
            signup(context);
          } else {
            print('NOT VERIFIED');
          }
        }).catchError((error) {
          print('SOMETHING WENT WRON');
          handleError(error, context);
        });
      };
    };*/

    /*final PhoneVerificationCompleted verifiedSuccess =
        (AuthCredential credential) {
      print('VERIFIED');
      setState(() {
        isLoading = false;
      });
      // sub.cancel();
    };*/

    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential credential) {
      setState(() {
        isLoading = false;
      });
      _auth.signInWithCredential(credential).then((AuthResult value) {
        if (value.user != null) {
          print('AUTO VERIFIED SUCCESSFULL');
          signup(context);
        } else {
          print('NOT VERIFIED');
        }
      }).catchError((error) {
        print('SOMETHING WENT WRON');
        handleError(error, context);
      });
    };

    final PhoneVerificationFailed veriFailed = (AuthException exception) {
      print('VERIFICATION FAILED');
      print('${exception.message}');
      print('EXCEPTION CODE :${exception.code}');

      setState(() {
        isLoading = false;
      });
      watch.stop();
      if (timer != null) timer.cancel();
      switch (exception.code) {
        case 'invalidCredential':
          _scaffoldKey.currentState.showSnackBar(
            SnackBar(
              content: Text('Invalid Phone number'),
              duration: Duration(seconds: 2),
            ),
          );

          break;
        default:
          _scaffoldKey.currentState.showSnackBar(
            SnackBar(
              content: Text('Please try again later'),
              duration: Duration(seconds: 2),
            ),
          );
          Crashlytics.instance
              .log('VER FAILED EXCEPTION: ${exception.message}');
          Crashlytics.instance.setString('MOBILE', contact);

          break;
      }
    };

    final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResend]) {
      this.verificationId = verId;
      setState(() {
        isLoading = false;
      });
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text('Code has been sent.'),
          duration: Duration(seconds: 2),
        ),
      );
      // sub.cancel();
    };

    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      this.verificationId = verId;
      setState(() {
        isLoading = false;
      });
    };

    try {
      await _auth.verifyPhoneNumber(
          phoneNumber: widget.phone.substring(0, 0) +
              widget.dialCode +
              widget.phone.substring(0 + 1),
          codeAutoRetrievalTimeout: autoRetrieve,
          codeSent: smsCodeSent,
          timeout: const Duration(seconds: 60),
          verificationCompleted: verificationCompleted,
          verificationFailed: veriFailed);
    } catch (e) {
      print('ERROR: $e');
    }
  }

  void _signInWithPhoneNumber(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    AuthCredential _authCredential = await PhoneAuthProvider.getCredential(
        verificationId: this.verificationId, smsCode: verCode);
    _auth.signInWithCredential(_authCredential).then((AuthResult value) {
      if (value.user != null) {
        print('VERIFIED SUCCESSFULL');
        watch.stop();
        if (timer != null) timer.cancel();
        signup(context);
      } else {
        print('NOT VERIFIED');
      }
    }).catchError((error) {
      print('SOMETHING WENT WRON');
      handleError(error, context);
    });

    /*try {
      final AuthCredential credential = PhoneAuthProvider.getCredential(
        verificationId: this.verificationId,
        smsCode: verCode,
      );

      final AuthResult authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);
      //FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
      if (authResult.user != null) {
        // signup();
        /*Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SignupScreen(),
          ),
        );*/
        signup(context);
      } else
        print("INVALID USER");
    } catch (e) {
      handleError(e, context);
    }*/
  }

  handleError(PlatformException error, BuildContext context) {
    print(error);
    setState(() {
      isLoading = false;
    });
    switch (error.code) {
      case 'ERROR_INVALID_VERIFICATION_CODE':
        //FocusScope.of(context).requestFocus(new FocusNode());
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid Verification Code'),
          ),
        );
        break;
      default:
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text('SMS code has expired.'),
          ),
        );
        Crashlytics.instance
            .log('VER FAILED EXCEPTION IN handleError METHOD: $error');
        Crashlytics.instance.setString('MOBILE', contact);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor,
        ),
        title: Text(
          allTranslations.text('phone_ver'),
          style: TextStyle(
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Builder(
          builder: (context) => ModalProgressHUD(
            child: SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: double.infinity,
                color: Colors.white,
                padding:
                    EdgeInsets.only(left: 30, bottom: 10, right: 30, top: 50),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Container(
                      child: SizedBox(
                        child: CircleAvatar(
                          radius: MediaQuery.of(context).size.height * 0.10,
                          backgroundColor: Theme.of(context).accentColor,
                          child: Padding(
                            padding: EdgeInsets.all(30),
                            child: SizedBox(
                              child: SvgPicture.asset(
                                'assets/OTP_ver.svg',
                                color: Colors.white,
                                semanticsLabel: 'A red up arrow',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      // color: Colors.blue[100],
                      margin: EdgeInsets.only(top: 50),
                      alignment: Alignment.center,

                      child: Text(
                        'Enter the 6-Digit code sent to the number ' + contact,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      // color: Colors.blue[100],
                      margin: EdgeInsets.only(top: 10),
                      alignment: Alignment.center,

                      child: Container(
                        // color: Colors.blue[200],
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        alignment: Alignment.center,
                        child: PinCodeTextField(
                          autofocus: false,
                          hideCharacter: false,
                          pinBoxHeight: 55,
                          highlight: true,
                          pinBoxWidth: 30,
                          wrapAlignment: WrapAlignment.center,
                          highlightColor: Theme.of(context).primaryColor,
                          defaultBorderColor: Colors.grey,
                          hasTextBorderColor: Theme.of(context).primaryColor,
                          maxLength: 6,
                          onDone: (text) {
                            print("DONE $text");
                            verCode = text;
                          },
                          pinBoxDecoration: ProvidedPinBoxDecoration
                              .underlinedPinBoxDecoration,
                          pinTextStyle: TextStyle(fontSize: 25.0),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10),

                      constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.07,
                          minHeight: MediaQuery.of(context).size.height * 0.06),
                      //width: MediaQuery.of(context).size.width * 0.60,
                      width: double.infinity,
                      child: RaisedButton(
                        padding: const EdgeInsets.all(0.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        color: Theme.of(context).primaryColor,
                        onPressed: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                          if (verCode != '') {
                            _signInWithPhoneNumber(context);
                          } else
                            Scaffold.of(context).showSnackBar(
                              SnackBar(
                                duration: Duration(seconds: 2),
                                content: Text(
                                  allTranslations.text('fill_ver_code'),
                                ),
                              ),
                            );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            alignment: Alignment.center,
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
                            child: Text(
                              allTranslations.text('verify'),
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      // flex: 3,
                      child: Container(
                        //color: Colors.blue[200],
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Container(
                                // color: Colors.blue[200],
                                alignment: Alignment.bottomCenter,
                                width: 50,
                                child: Text(
                                  min.toString(),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 30,
                                    //fontWeight: FontWeight.w600,
                                    fontFamily: 'Pacifico',
                                  ),
                                ),
                              ),
                              Text(
                                ':',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 30,
                                  // fontWeight: FontWeight.bold,
                                  fontFamily: 'Pacifico',
                                ),
                              ),
                              Container(
                                //  color: Colors.blue[300],
                                alignment: Alignment.bottomCenter,
                                width: 50,
                                child: Text(
                                  sec.toString(),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 30,
                                    // fontWeight: FontWeight.bold,
                                    fontFamily: 'Pacifico',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      // color: Colors.blue[100],
                      alignment: Alignment.bottomCenter,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            child: Text(
                              allTranslations.text('ver_code_not_received'),
                              style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FontStyle.italic),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 10),
                            // padding: EdgeInsets.only(top: 8),
                            //alignment: Alignment.center,
                            constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.04,
                              minHeight:
                                  MediaQuery.of(context).size.height * 0.04,
                            ),
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                              color: Theme.of(context).primaryColor,
                              onPressed: timerFinished
                                  ? () {
                                      verifyPhone();
                                      timerDuration = Duration(minutes: 1);
                                      startTimer();
                                    }
                                  : null,
                              child: Text(
                                allTranslations.text('resend'),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
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
            inAsyncCall: isLoading,
          ),
        ),
      ),
    );
  }
}
