import 'dart:convert';
import 'dart:io';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:win_diggy/Models/URLS.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:win_diggy/Globals.dart' as globals;
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:win_diggy/Models/GlobalTranslations.dart';
import 'package:win_diggy/Screen/PhoneVerifyScreen.dart';
import 'package:win_diggy/Widgets/EnsureVisibleWhenFocused.dart';
import 'package:win_diggy/Widgets/InputField.dart';

import 'PrivacyScreen.dart';
import 'TermsCondScreen.dart';

class PhoneNoScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return PhoneNoScreenState();
  }
}

class PhoneNoScreenState extends State<PhoneNoScreen> {
  String dialCode;
  String country;
  TextEditingController contactTxt = new TextEditingController();

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  FocusNode _focusNodeContact = new FocusNode();

  bool alreadRegistered;
  String buttonText;
  String phoneNumber;

  var isLoading;
  FirebaseMessaging _fcm = FirebaseMessaging();
  bool checkValue;

  var FCM;

  var valid;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    contactTxt.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    alreadRegistered = false;
    checkValue = false;
    phoneNumber = '';
    buttonText = allTranslations.text('verify');
    isLoading = false;
    dialCode = '+92';
    country = 'Pakistan';
    getFCMToken();
    valid = true;
  }

  getFCMToken() {
    _fcm.getToken().then((token) {
      print(token);
      FCM = token;
    });
  }

  void _onCountryChange(CountryCode countryCode) {
    //Todo : manipulate the selected country code here
    print("New Country selected: " + countryCode.toString());
    dialCode = countryCode.toString();
  }

  /////////////////////////////////////////////////////OPEN DIALOG
  Future openDialogAddItem() async {
    Navigator.of(context).push(
      new MaterialPageRoute(
          builder: (BuildContext context) {
            return VerifyScreenDialog(
              phone: contactTxt.text.toString(),
              dialCode: dialCode,
            );
          },
          fullscreenDialog: true),
    );
  }

  void verify() async {
    setState(() {
      isLoading = true;
    });
    Map userdata = {
      "phone": contactTxt.text.toString(),
    };
    http.Response response =
        await http.post(URLS.signupVerif, body: json.encode(userdata));

    print(userdata);
    print(response.body);
    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON
      Map mapobject = (json.decode(response.body));
      var succes = mapobject['success'];
      if (succes) {
        print('SIGNED UP');
        setState(() {
          isLoading = false;
          alreadRegistered = true;
        });
        globals.contact = contactTxt.text.toString();
        openDialogAddItem();
      } else {
        print('response code not 200');
        print(response.body);
      }
    }
  }

  void onPhoneNumberChanged(PhoneNumber phoneNumber) {
    print(phoneNumber);
    this.phoneNumber = phoneNumber.toString();
  }

  void onInputChanged(bool value) {
    print(value);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement buil

    Widget contactView() {
      return EnsureVisibleWhenFocused(
        focusNode: _focusNodeContact,
        child: Padding(
          padding: EdgeInsets.only(top: 10),
          child: Container(
            //color: Colors.amber,
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.08,
                minHeight: MediaQuery.of(context).size.height * 0.06),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(30),
            ),
            padding: EdgeInsets.only(left: 40, right: 20),
            child: TextFormField(
              /*onTap: () {
                setState(() {
                  contactTxt.text = '03';
                });
              },*/
              focusNode: _focusNodeContact,
              keyboardType: TextInputType.phone,
              textAlign: TextAlign.left,
              controller: contactTxt,
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w600,
                fontSize: 15,
                fontFamily: 'Roboto Regular',
              ),
              decoration: InputDecoration(
                //contentPadding: EdgeInsets.symmetric(horizontal: 30),
                hintText: '03XXXXXXXXX',
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  fontFamily: 'Roboto Regular',
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      );
    }

    Widget signupButton(BuildContext context) {
      return Container(
        margin: EdgeInsets.only(top: 30),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.07,
            minHeight: MediaQuery.of(context).size.height * 0.06,
          ),
          //width: MediaQuery.of(context).size.width * 0.60,
          width: double.infinity,
          child: RaisedButton(
            disabledColor: Colors.grey,
            padding: const EdgeInsets.all(0.0),
            elevation: 6,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            // color: Theme.of(context).primaryColor,
            onPressed: checkValue
                ? () {
                    FocusScope.of(context).requestFocus(FocusNode());

                    if (contactTxt.text.isEmpty)
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          duration: Duration(seconds: 2),
                          content: Text(
                            allTranslations.text('fill_fields'),
                          ),
                        ),
                      );
                    else {
                      verify();
                    }
                  }
                : null,
            child: checkValue
                ? ClipRRect(
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
                        buttonText,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      alignment: Alignment.center,
                      color: Colors.grey,
                      child: Text(
                        buttonText,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      );
    }

    Widget countryView() {
      return Container(
        //color: Colors.amber,
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.08,
            minHeight: MediaQuery.of(context).size.height * 0.06),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(30),
        ),
        padding: EdgeInsets.only(left: 40, right: 20),
        child: Row(
          children: <Widget>[
            Container(
              //  color: Colors.blue[100],
              child: Text(
                allTranslations.text('country'),
                style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: 10),
                //color: Colors.blue[200],
                child: new CountryCodePicker(
                  onChanged: (code) {
                    _onCountryChange(code);
                  },
                  padding: EdgeInsets.only(top: 15, bottom: 15),
                  initialSelection: 'PK',
                  showCountryOnly: false,
                  alignLeft: false,
                ),
              ),
            ),
          ],
        ),
      );
    }

    setCheckTrue() {
      if (!checkValue)
        setState(() {
          checkValue = true;
        });
      else
        setState(() {
          checkValue = false;
        });
    }

    ///////////////////////////////////////////////////////////////MAIN WIDGET TREE
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
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
        bottom: false,
        child: Builder(
          builder: (context) => ModalProgressHUD(
            child: LayoutBuilder(
              builder:
                  (BuildContext context, BoxConstraints viewportConstraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: viewportConstraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Container(
                        alignment: Alignment.topCenter,
                        color: Colors.white,
                        padding: EdgeInsets.only(
                          //top: 50,
                          //bottom: 50,
                          top: 50,
                          left: 15,
                          right: 15,
                          bottom: 10,
                        ),
                        child: Column(
                          children: <Widget>[
                            Container(
                              alignment: Alignment.center,
                              child: SizedBox(
                                child: CircleAvatar(
                                  radius:
                                      MediaQuery.of(context).size.height * 0.10,
                                  backgroundColor:
                                      Theme.of(context).accentColor,
                                  child: Padding(
                                    padding: EdgeInsets.all(30),
                                    child: SizedBox(
                                      child: SvgPicture.asset(
                                        'assets/smartphone.svg',
                                        color: Colors.white,
                                        semanticsLabel: 'A red up arrow',
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(top: 50),
                                alignment: Alignment.center,
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    // mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      countryView(),
                                      contactView(),
                                      /*InternationalPhoneNumberInput(
                              onInputChanged: onPhoneNumberChanged,
                              onInputValidated: onInputChanged,
                              initialCountry2LetterCode: 'PK',
                            ),*/
                                      signupButton(context),
                                      Expanded(
                                        child: Container(
                                          alignment: Alignment.bottomCenter,
                                          child: Container(
                                            alignment: Alignment.bottomCenter,
                                            //color: Colors.blue[100],
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                Container(
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  child: SizedBox(
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: <Widget>[
                                                        Container(
                                                          // color: Colors.blue[300],
                                                          alignment: Alignment
                                                              .bottomCenter,
                                                          child: SizedBox(
                                                            height: 40,
                                                            width: 40,
                                                            child: FittedBox(
                                                              child: Checkbox(
                                                                value:
                                                                    checkValue,
                                                                onChanged: (bool
                                                                    value) {
                                                                  setCheckTrue();
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: SizedBox(
                                                            child: Row(
                                                              children: <
                                                                  Widget>[
                                                                new Flexible(
                                                                  child: Text(
                                                                    allTranslations
                                                                        .text(
                                                                            'age_limit'),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    maxLines: 2,
                                                                    style:
                                                                        TextStyle(
                                                                      color: Theme.of(
                                                                              context)
                                                                          .accentColor,
                                                                      fontSize:
                                                                          12,

                                                                      //height: 1.5,
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
                                                Container(
                                                  margin: EdgeInsets.only(
                                                    top: 0,
                                                  ),
                                                  //  color: Colors.blue[100],
                                                  alignment: Alignment.center,
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: <Widget>[
                                                      Container(
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        Terms(),
                                                              ),
                                                            );
                                                          },
                                                          child: Text(
                                                            allTranslations.text(
                                                                'terms_cond'),
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .accentColor,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        child: Text(
                                                          ' and ',
                                                          style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .accentColor,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        Privacy(),
                                                              ),
                                                            );
                                                          },
                                                          child: Text(
                                                            allTranslations
                                                                .text(
                                                                    'privacy'),
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .accentColor,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
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
                );
              },
            ),
            inAsyncCall: isLoading,
          ),
        ),
      ),
    );
  }
}
