import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:win_diggy/Models/GlobalTranslations.dart';
import 'package:win_diggy/Models/URLS.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:win_diggy/Globals.dart' as globals;
import 'package:flutter/services.dart';
import 'package:win_diggy/Widgets/ProfileDialog.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> fetchCountry(
  http.Client client,
) async {
  try {
    var url = URLS.profileInfo + globals.userID;
    final response = await client.get(url);

    if (response.statusCode == 200) {
      Map mapobject = (json.decode(response.body));
      var succes = mapobject['success'];
      print("PROFILE RESPONSE");
      print(response.body);
      if (succes) {
        return compute(parseData, response.body);
      } else {
        print("success false");
        return null;
      }
    } else {
      // If that call was not successful, throw an error.
      print("response code not 200");
      return null;
    }
  } finally {
    client.close();
    print("CONNECTION CLOSED");
  }
}

// A function that will convert a response body into a List<Country>
Map<String, dynamic> parseData(String responseBody) {
  final parsed = json.decode(responseBody);

  Map<String, dynamic> data = {
    'username': parsed['user']['username'],
    'country': parsed['user']['country'],
    'contact': parsed['user']['phone'],
    'email': parsed['user']['email'],
    'address': parsed['user']['address'],
    'id': parsed['user']['id'],
    'profilePic': parsed['user']['profilePicture'],
    'setOneTime': parsed['user']['set_one_time'],
  };
  return data;
}

class ProfileScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ProfileScreenState();
  }
}

class ProfileScreenState extends State<ProfileScreen> {
  String userID;
  String countryInit;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userID = '';
    countryInit = '';
    retrieveData();
  }

  retrieveData() async {
    setValues();
  }

  void setValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userID = prefs.getString('id');
    print('USERID: $userID');

    String code = prefs.getString('country_code');
    if (code == null || code == '')
      countryInit = 'PK';
    else
      countryInit = code;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(color: Theme.of(context).accentColor),
          title: Text(
            allTranslations.text('my_profile'),
            style: TextStyle(color: Theme.of(context).accentColor),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          top: false,
          child: Stack(
            children: <Widget>[
              Container(
                color: Colors.black,
              ),
              Container(
                child: new FutureBuilder<Map<String, dynamic>>(
                  future: fetchCountry(new http.Client()),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) print(snapshot.error);

                    return snapshot.hasData
                        ? new ProfileScreenInner(
                            userData: snapshot.data,
                            country: countryInit,
                          )
                        : new Center(child: new CircularProgressIndicator());
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      onWillPop: () {
        return closeScreen(context);
      },
    );
  }

  Future<bool> closeScreen(context) async {
    globals.HOMEONFRONT = true;
    globals.onceInserted = false;
    // Navigator.of(context).pop();
    globals.resumeCalledOnce = false;

    Navigator.popAndPushNamed(context, '/dashboard');
    return false;
  }
}

class ProfileScreenInner extends StatefulWidget {
  Map<String, dynamic> userData;
  String country;

  ProfileScreenInner({this.userData, this.country});

  static ProfileScreenInnerState of(BuildContext context) =>
      context.ancestorStateOfType(const TypeMatcher<ProfileScreenInnerState>());
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ProfileScreenInnerState();
  }
}

class ProfileScreenInnerState extends State<ProfileScreenInner> {
  bool username;
  bool contact;
  bool country;
  bool emailID;
  bool userAddress;
  String text;
  TextInputType textType;
  String name;
  String email;
  String address;
  String countryName;
  String contactNo;
  var isLoading;
  File _image;
  var image;
  bool imageSelected;
  ValueNotifier<String> nameNotifier;
  ValueNotifier<String> countryNotifier;
  ValueNotifier<String> emailNotifier;
  ValueNotifier<String> addressNotifier;
  String userID;
  String base64Image;
  String imageURL;
  File temImage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userID = '';
    name = '';
    countryName = '';
    contactNo = '';
    email = '';
    address = '';
    imageURL = '';
    retrieveData();

    _image = null;
    imageSelected = false;
    isLoading = false;
    username = false;
    country = false;
    contact = false;
    emailID = false;
    userAddress = false;
    text = '';
  }

  retrieveData() async {
    await setValues();
  }

  void setValues() async {
    temImage = globals.temImage;
    setState(() {
      if (widget.userData['username'] == null ||
          widget.userData['username'] == '')
        name = "username";
      else
        name = widget.userData['username'];

      if (widget.userData['contact'] == null ||
          widget.userData['contact'] == '')
        contactNo = "contact";
      else
        contactNo = widget.userData['contact'];

      if (widget.userData['country'] == null ||
          widget.userData['country'] == '')
        countryName = "country";
      else
        countryName = widget.userData['country'];

      if (widget.userData['email'] == null || widget.userData['email'] == '')
        email = "email id";
      else
        email = widget.userData['email'];
      if (widget.userData['address'] == null ||
          widget.userData['address'] == '')
        address = "address";
      else
        address = widget.userData['address'];

      if (widget.userData['profilePic'] == null ||
          widget.userData['profilePic'] == '')
        imageURL = "";
      else
        imageURL = widget.userData['profilePic'];

      userID = widget.userData['id'];
    });

    print(userID);
    nameNotifier = new ValueNotifier<String>(name);
    emailNotifier = new ValueNotifier<String>(email);
    addressNotifier = new ValueNotifier<String>(address);
    countryNotifier = new ValueNotifier<String>(countryName);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('username', name);
    prefs.setString('contact', contactNo);
    prefs.setString('country', countryName);
    prefs.setString('email', email);
    prefs.setString('address', address);
    prefs.setString('id', userID);
    prefs.setString('profilePic', imageURL);
    globals.username = name;
    globals.country = countryName;
  }

  Future<void> _optionsDialogBox(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: new SingleChildScrollView(
              child: new ListBody(
                children: <Widget>[
                  GestureDetector(
                    child: new Text('Take a picture'),
                    onTap: () async {
                      image = await ImagePicker.pickImage(
                          source: ImageSource.camera);
                      Navigator.of(context).pop();

                      await getImage();
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  GestureDetector(
                    child: new Text('Select from gallery'),
                    onTap: () async {
                      image = await ImagePicker.pickImage(
                          source: ImageSource.gallery);
                      Navigator.of(context).pop();

                      await getImage();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  // 1. compress file and get a List<int>
  Future<List<int>> testCompressFile(File file) async {
    var result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      quality: 60,
    );
    print(file.lengthSync());
    print(result.length);
    return result;
  }

  Future _upload() async {
    if (temImage == null) return;
    setState(() {
      isLoading = true;
    });

    List<int> compress = await testCompressFile(temImage);
    base64Image = base64Encode(compress);
  }

  Future getImage() async {
    setState(() {
      _image = image;
    });
    if (_image != null) {
      setState(() {
        imageSelected = true;
        temImage = _image;
      });
    }
    await _upload();
    updateProfile();
  }

  Future updateProfile() async {
    print('PROFILE PIC UPLOAD');

    setState(() {
      isLoading = true;
    });
    Map userdata;

    userdata = {
      'picture': base64Image,
    };

    http.Response response = await http.post(
        URLS.profilePicUpdate + globals.userID,
        body: json.encode(userdata));

    print('PROFILE PIC UPLOAD SERVER RESPONSE');
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
        // Navigator.popAndPushNamed(context, '/profile');
        globals.temImage = temImage;
      } else {
        succes = false;
        setState(() {
          isLoading = false;
          imageSelected = false;
        });
      }
    } else {
      print('response code not 200');
      print(response.body);
    }
  }

  /////////////////////////////////////////////////////OPEN DIALOG
  Future openDialogAddItem() async {
    ValueNotifier<String> notifier;
    if (username) {
      notifier = nameNotifier;
      textType = TextInputType.text;
    } else if (country) {
      notifier = countryNotifier;
      textType = TextInputType.text;
    } else if (emailID) {
      notifier = emailNotifier;
      textType = TextInputType.emailAddress;
    } else {
      notifier = addressNotifier;
      textType = TextInputType.text;
    }

    Navigator.of(context).push(
      new MaterialPageRoute(
        builder: (BuildContext context) {
          return ProfileDialog(
            value: notifier,
            text: text,
            textType: textType,
            userID: userID,
            countryCode: widget.country,
          );
        },
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return ModalProgressHUD(
      child: Container(
        padding: EdgeInsets.only(bottom: 20),
        color: Colors.black,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                //color: Colors.blue[100],
                height: MediaQuery.of(context).size.height * 0.30,
                margin: EdgeInsets.only(top: 20),
                alignment: Alignment.center,
                child: Stack(
                  children: <Widget>[
                    Container(
                      // color: Colors.blue,
                      // margin: EdgeInsets.only(top: 80),
                      alignment: Alignment.center,
                      child: SizedBox(
                        child: imageSelected
                            ? CircleAvatar(
                                backgroundColor: Colors.white,
                                radius:
                                    MediaQuery.of(context).size.height * 0.11,
                                backgroundImage: FileImage(temImage),
                              )
                            : CircleAvatar(
                                backgroundColor: Colors.white,
                                radius:
                                    MediaQuery.of(context).size.height * 0.11,
                                backgroundImage: imageURL == ""
                                    ? ExactAssetImage('assets/defaultImg.png')
                                    : new CachedNetworkImageProvider(
                                        imageURL,
                                      ),
                              ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.14,
                        left: MediaQuery.of(context).size.width * 0.28,
                      ),
                      child: Align(
                        child: Container(
                          //color: Colors.blue,
                          constraints: BoxConstraints(
                            minWidth: MediaQuery.of(context).size.width * 0.30,
                            maxWidth: MediaQuery.of(context).size.width * 0.60,
                          ),
                          //width: MediaQuery.of(context).size.width * 0.30,

                          child: FloatingActionButton(
                            elevation: 3,
                            backgroundColor: Theme.of(context).accentColor,
                            mini: true,
                            onPressed: () {
                              if (_image != null) _image = null;
                              _optionsDialogBox(context);
                            },
                            child: Icon(
                              Icons.edit,
                              color: Colors.black,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                alignment: Alignment.bottomCenter,
                padding: EdgeInsets.only(left: 10, right: 10),
                margin: EdgeInsets.only(top: 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: GestureDetector(
                        onTap: () async {
                          username = true;
                          emailID = false;
                          userAddress = false;
                          country = false;
                          text = 'Username';
                          if (widget.userData['setOneTime'] == "0")
                            openDialogAddItem();
                        },
                        child: Container(
                          //color: Colors.amber,
                          //height: MediaQuery.of(context).size.height * 0.10,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment(0.08, -2.8),
                                  end: Alignment(0.0, 2.8),
                                  //stops: [0.0, 0.6, 1.0],
                                  colors: [
                                    // Colors are easy thanks to Flutter's Colors class.
                                    Color(0xff5c4710),
                                    Color(0xffeccb58),
                                    Color(0xff5c4710),

                                    // Color(0xff5c4710),
                                  ],
                                ),
                              ),
                              padding: EdgeInsets.only(
                                  left: 15, right: 10, top: 5, bottom: 5),
                              child: Row(
                                //crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  Container(
                                    child: Icon(
                                      Icons.account_circle,
                                      color: Colors.black,
                                      size: MediaQuery.of(context).size.height *
                                          0.04,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 5,
                                    child: Container(
                                      alignment: Alignment.centerLeft,
                                      padding: EdgeInsets.only(
                                          left: 30, top: 7, bottom: 5),
                                      //color: Colors.blue[500],
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            padding: EdgeInsets.only(right: 5),
                                            child: Text(
                                              allTranslations.text('username'),
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(top: 5),
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              name,
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      alignment: Alignment.centerRight,
                                      //padding: EdgeInsets.only(left: 25),
                                      //color: Colors.blue[500],
                                      child: Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.black,
                                        size: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: GestureDetector(
                        onTap: () async {
                          emailID = true;
                          username = false;
                          userAddress = false;
                          country = false;
                          text = 'Email';
                          openDialogAddItem();
                        },
                        child: Container(
                          //color: Colors.amber,
                          //height: MediaQuery.of(context).size.height * 0.10,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment(0.08, -2.8),
                                  end: Alignment(0.0, 2.8),
                                  //stops: [0.0, 0.6, 1.0],
                                  colors: [
                                    // Colors are easy thanks to Flutter's Colors class.
                                    Color(0xff5c4710),
                                    Color(0xffeccb58),
                                    Color(0xff5c4710),

                                    // Color(0xff5c4710),
                                  ],
                                ),
                              ),
                              padding: EdgeInsets.only(
                                  left: 15, right: 10, top: 5, bottom: 5),
                              child: Row(
                                // crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  Container(
                                    child: Icon(
                                      Icons.email,
                                      color: Colors.black,
                                      size: MediaQuery.of(context).size.height *
                                          0.04,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 5,
                                    child: Container(
                                      alignment: Alignment.centerLeft,
                                      padding: EdgeInsets.only(
                                          left: 30, top: 7, bottom: 5),
                                      //color: Colors.blue[500],
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            padding: EdgeInsets.only(right: 5),
                                            child: Text(
                                              allTranslations.text('email'),
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(top: 5),
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              email,
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      alignment: Alignment.centerRight,
                                      //padding: EdgeInsets.only(left: 25),
                                      //color: Colors.blue[500],
                                      child: Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.black,
                                        size: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: GestureDetector(
                        onTap: () async {},
                        child: Container(
                          //color: Colors.amber,
                          // height: MediaQuery.of(context).size.height * 0.10,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment(0.08, -2.8),
                                  end: Alignment(0.0, 2.8),
                                  //stops: [0.0, 0.6, 1.0],
                                  colors: [
                                    // Colors are easy thanks to Flutter's Colors class.
                                    Color(0xff5c4710),
                                    Color(0xffeccb58),
                                    Color(0xff5c4710),

                                    // Color(0xff5c4710),
                                  ],
                                ),
                              ),
                              padding: EdgeInsets.only(
                                left: 15,
                                right: 10,
                                top: 5,
                                bottom: 5,
                              ),
                              child: Row(
                                //crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  Container(
                                    child: Icon(
                                      Icons.phone,
                                      color: Colors.black,
                                      size: MediaQuery.of(context).size.height *
                                          0.04,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 5,
                                    child: Container(
                                      alignment: Alignment.centerLeft,
                                      padding: EdgeInsets.only(
                                          left: 30, top: 7, bottom: 5),
                                      //color: Colors.blue[500],
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              allTranslations
                                                  .text('contact_no'),
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(top: 5),
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              contactNo,
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      alignment: Alignment.centerRight,
                                      //padding: EdgeInsets.only(left: 25),
                                      //color: Colors.blue[500],
                                      child: Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.black,
                                        size: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: GestureDetector(
                        onTap: () async {
                          userAddress = true;
                          username = false;
                          country = false;
                          emailID = false;
                          text = 'Address';
                          openDialogAddItem();
                        },
                        child: Container(
                          //color: Colors.amber,
                          //height: MediaQuery.of(context).size.height * 0.10,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment(0.08, -2.8),
                                  end: Alignment(0.0, 2.8),
                                  //stops: [0.0, 0.6, 1.0],
                                  colors: [
                                    // Colors are easy thanks to Flutter's Colors class.
                                    Color(0xff5c4710),
                                    Color(0xffeccb58),
                                    Color(0xff5c4710),

                                    // Color(0xff5c4710),
                                  ],
                                ),
                              ),
                              padding: EdgeInsets.only(
                                left: 15,
                                right: 10,
                                top: 5,
                                bottom: 5,
                              ),
                              child: Row(
                                //crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  Container(
                                    child: Icon(
                                      Icons.home,
                                      color: Colors.black,
                                      size: MediaQuery.of(context).size.height *
                                          0.04,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 5,
                                    child: Container(
                                      alignment: Alignment.centerLeft,
                                      padding: EdgeInsets.only(
                                          left: 30, top: 7, bottom: 5),
                                      //color: Colors.blue[500],
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              allTranslations.text('address'),
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(top: 5),
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              address,
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      alignment: Alignment.centerRight,
                                      //padding: EdgeInsets.only(left: 25),
                                      //color: Colors.blue[500],
                                      child: Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.black,
                                        size: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: GestureDetector(
                        onTap: () async {
                          country = true;
                          username = false;
                          emailID = false;
                          userAddress = false;
                          text = 'Country';
                          openDialogAddItem();
                        },
                        child: Container(
                          //color: Colors.amber,
                          //height: MediaQuery.of(context).size.height * 0.10,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment(0.08, -2.8),
                                  end: Alignment(0.0, 2.8),
                                  //stops: [0.0, 0.6, 1.0],
                                  colors: [
                                    // Colors are easy thanks to Flutter's Colors class.
                                    Color(0xff5c4710),
                                    Color(0xffeccb58),
                                    Color(0xff5c4710),

                                    // Color(0xff5c4710),
                                  ],
                                ),
                              ),
                              padding: EdgeInsets.only(
                                left: 15,
                                right: 10,
                                top: 5,
                                bottom: 5,
                              ),
                              child: Row(
                                // crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  Container(
                                    child: Icon(
                                      Icons.home,
                                      color: Colors.black,
                                      size: MediaQuery.of(context).size.height *
                                          0.04,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 5,
                                    child: Container(
                                      alignment: Alignment.centerLeft,
                                      padding: EdgeInsets.only(
                                          left: 30, top: 7, bottom: 5),
                                      //color: Colors.blue[500],
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              allTranslations.text('country'),
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(top: 5),
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              countryName,
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      alignment: Alignment.centerRight,
                                      //padding: EdgeInsets.only(left: 25),
                                      //color: Colors.blue[500],
                                      child: Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.black,
                                        size: 15,
                                      ),
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
      inAsyncCall: isLoading,
    );
  }
}
