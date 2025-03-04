import 'dart:convert';
import 'package:auto_direction/auto_direction.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_picker_dropdown.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:win_diggy/Globals.dart' as globals;
import 'package:win_diggy/Models/GlobalTranslations.dart';
import 'package:win_diggy/Models/URLS.dart';
import 'package:shared_preferences/shared_preferences.dart';

/////////////////////////FULL SCREEN DIALOG CONTENT
class ProfileDialog extends StatefulWidget {
  TextInputType textType;
  String text;
  String userID;
  ValueNotifier<String> value;
  String countryCode;

  ProfileDialog(
      {this.value, this.textType, this.text, this.userID, this.countryCode});

  @override
  _DialogAddItemState createState() => new _DialogAddItemState();
}

class _DialogAddItemState extends State<ProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController textCont = new TextEditingController();
  TextEditingController verifyCode = new TextEditingController();
  var code;
  bool enableField;
  String verificationId;
  ValueNotifier<String> valueNotifier;
  var isLoading = false;
  String country;
  String countryInit;
  String cc;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //getPhoneCode();
    enableField = false;
    countryInit = widget.countryCode;
    valueNotifier = widget.value;
    textCont.text = valueNotifier.value.toString();
    country = valueNotifier.value.toString();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    textCont.dispose();
    verifyCode.dispose();
    super.dispose();
  }

  updateProfile(String value) async {
    Map userdata;
    if (value == 'username')
      userdata = {
        value: textCont.text.toString(),
        'set_one_time': true,
      };
    else if (value == 'country')
      userdata = {
        'country': country,
      };
    else if (value == 'email') {
      userdata = {
        'email': textCont.text.toString(),
      };
    } else
      userdata = {
        'address': textCont.text.toString(),
      };

    http.Response response = await http.post(URLS.profileUpdate + widget.userID,
        body: json.encode(userdata));

    print(userdata);
    print(response.body);
    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON
      Map mapobject = (json.decode(response.body));
      var succes = mapobject['success'];
      if (succes) {
        setState(() {
          isLoading = false;
        });
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('country_code', countryInit);
        Navigator.of(context).pop();
        Navigator.popAndPushNamed(context, '/profile');
      } else {
        succes = false;
        setState(() {
          isLoading = false;
        });
        Navigator.pop(context);
        Navigator.popAndPushNamed(context, '/profile');
      }
    } else {
      print('response code not 200');
      print(response.body);
    }
  }

  void changeCountry(CountryCode countryCode) {
    print("New Country selected: " + countryCode.name);
    country = countryCode.name.toString();
    setState(() {
      countryInit = countryCode.code.toString();
    });
    print('${countryCode.code}');
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: new AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Theme.of(context).accentColor),
      ),
      body: Builder(
        builder: (context) => ModalProgressHUD(
          child: Container(
            height: double.infinity,
            width: double.infinity,
            color: Colors.white,
            padding: EdgeInsets.only(left: 16, bottom: 16, right: 16, top: 20),
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  widget.text == 'Username'
                      ? Container(
                          child: AutoDirection(
                            text: allTranslations.text('username_notice'),
                            child: Text(
                              allTranslations.text('username_notice'),
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        )
                      : SizedBox(),
                  Container(
                    padding: EdgeInsets.only(top: 30, bottom: 0),
                    child: Column(
                      children: <Widget>[
                        Container(
                          alignment: Alignment.center,
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: <Widget>[
                                widget.text == 'Username'
                                    ? Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 30, vertical: 5),
                                        // margin: EdgeInsets.symmetric(horizontal: 10),
                                        alignment: Alignment.centerLeft,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        child: TextFormField(
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              return 'Enter ' + widget.text;
                                            }
                                            return null;
                                          },
                                          keyboardType: widget.textType,
                                          textAlign: TextAlign.left,
                                          controller: textCont,
                                          style: TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                            fontFamily: 'Roboto Regular',
                                          ),
                                          decoration: InputDecoration(
                                            hintText: widget.text,
                                            hintStyle: TextStyle(
                                              color: Colors.grey[500],
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                              fontFamily: 'Roboto Regular',
                                            ),
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      )
                                    : SizedBox(),
                                widget.text == 'Email'
                                    ? Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 30, vertical: 5),
                                        // margin: EdgeInsets.symmetric(horizontal: 10),
                                        alignment: Alignment.centerLeft,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        child: TextFormField(
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              return 'Enter ' + widget.text;
                                            }
                                            return null;
                                          },
                                          keyboardType: widget.textType,
                                          textAlign: TextAlign.left,
                                          controller: textCont,
                                          style: TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                            fontFamily: 'Roboto Regular',
                                          ),
                                          decoration: InputDecoration(
                                            hintText: widget.text,
                                            hintStyle: TextStyle(
                                              color: Colors.grey[500],
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                              fontFamily: 'Roboto Regular',
                                            ),
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      )
                                    : SizedBox(),
                                widget.text == 'Address'
                                    ? Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 30, vertical: 5),
                                        // margin: EdgeInsets.symmetric(horizontal: 10),
                                        alignment: Alignment.centerLeft,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        child: TextFormField(
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              return 'Enter ' + widget.text;
                                            }
                                            return null;
                                          },
                                          keyboardType: widget.textType,
                                          textAlign: TextAlign.left,
                                          controller: textCont,
                                          style: TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                            fontFamily: 'Roboto Regular',
                                          ),
                                          decoration: InputDecoration(
                                            hintText: widget.text,
                                            hintStyle: TextStyle(
                                              color: Colors.grey[500],
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                              fontFamily: 'Roboto Regular',
                                            ),
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      )
                                    : SizedBox(),
                                widget.text == 'Country'
                                    ? Container(
                                        margin: EdgeInsets.only(top: 10),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 30, vertical: 5),
                                        // margin: EdgeInsets.symmetric(horizontal: 10),
                                        alignment: Alignment.centerLeft,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        child: new CountryCodePicker(
                                          padding: EdgeInsets.only(
                                              right: 145,
                                              left: 0,
                                              top: 0,
                                              bottom: 0),
                                          onChanged: (country) {
                                            changeCountry(country);
                                          },
                                          initialSelection: countryInit,
                                          showCountryOnly: true,
                                          showOnlyCountryWhenClosed: true,
                                          alignLeft: false,
                                        ),
                                      )
                                    : SizedBox()
                              ],
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 30),
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              RaisedButton(
                                padding: const EdgeInsets.all(0.0),
                                color: Colors.transparent,
                                elevation: 6,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                                onPressed: () {
                                  if (widget.text == 'Country') {
                                    valueNotifier.value = country;
                                    //Navigator.of(context).pop();
                                    updateProfile('country');
                                  } else if (widget.text == 'Username') {
                                    if (_formKey.currentState.validate()) {
                                      valueNotifier.value =
                                          textCont.text.toString();
                                      //Navigator.of(context).pop();

                                      updateProfile('username');
                                    }
                                  } else if (widget.text == 'Email') {
                                    if (_formKey.currentState.validate()) {
                                      valueNotifier.value =
                                          textCont.text.toString();
                                      //Navigator.of(context).pop();

                                      updateProfile('email');
                                    }
                                  } else if (widget.text == 'Address') {
                                    if (_formKey.currentState.validate()) {
                                      valueNotifier.value =
                                          textCont.text.toString();
                                      //Navigator.of(context).pop();

                                      updateProfile('address');
                                    }
                                  }
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.25,
                                    height: MediaQuery.of(context).size.height *
                                        0.05,
                                    alignment: Alignment.center,
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
                                    child: Text(
                                      allTranslations.text('save'),
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 10),
                                child: RaisedButton(
                                  padding: const EdgeInsets.all(0.0),
                                  color: Colors.transparent,
                                  elevation: 6,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(30),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.25,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.05,
                                      alignment: Alignment.center,
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
                                      child: Text(
                                        allTranslations.text('cancel'),
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
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
    );
  }
}
