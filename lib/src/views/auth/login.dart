import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wemeet/src/blocs/bloc.dart';
import 'package:wemeet/src/resources/api_response.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wemeet/src/views/auth/activate.dart';
import 'package:wemeet/src/views/auth/forgot.dart';
import 'package:wemeet/src/views/auth/kyc.dart';
import 'package:wemeet/src/views/auth/register.dart';
import 'package:wemeet/src/views/dashboard/home.dart';

import 'package:wemeet/values/values.dart';

class Login extends StatefulWidget {
  Login({Key key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  Position _currentPosition;
  String deviceId;
  String pushToken;
  bool loading = false;
  bool _obscureText = true;
  String token;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String error = '';
  final _formKey = GlobalKey<FormState>();
  LatLng _center;
  Position currentLocation;
  @override
  void initState() {
    super.initState();
    // initPlatformState();
    print('asd');
    _getCurrentLocation();
    _getDevice();
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  _launchTerms() async {
    const url = 'https://wemeet.africa/termsandconditions.pdf';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _launchPrivacy() async {
    const url = 'https://wemeet.africa/privacypolicy.pdf';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _isLoc() async {
    print(await Geolocator.getLastKnownPosition());
  }

  login() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs?.setBool("isLoggedIn", true);
  }

  Future<Position> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
    });
    print(position);
    return position;
  }

  Future<String> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      // import 'dart:io'
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.androidId; // unique ID on Android
    }
  }

  _getDevice() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      pushToken = prefs.getString('pushToken');
    });
    print('push $pushToken');
  }

  _setUser(user, token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('accessToken', token);
    prefs.setString('id', user.id.toString());
    prefs.setString('profileImage', user.profileImage);
    prefs.setString('email', user.email);
    prefs.setString('firstName', user.firstName);
    prefs.setString('lastName', user.lastName);
    prefs.setBool('passKYC', user.profileImage == null ? false : true);
  }

  @override
  Widget build(BuildContext context) {
    _getId().then((id) {
      deviceId = id;
      print(deviceId);
    });
    return Scaffold(
        body: Container(
      constraints: BoxConstraints.expand(),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 255, 255, 255),
      ),
      child: StreamBuilder(
          stream: bloc.loginStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              switch (snapshot.data.status) {
                case Status.LOADING:
                  loading = true;

                  print(
                      'whyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy');
                  // return showCircularProgress();
                  break;
                case Status.IDLE:
                  loading = false;
                  break;
                case Status.DONE:
                  bloc.loginSink.add(ApiResponse.idle('message'));
                  login();
                  token = snapshot.data.data.data.tokenInfo.accessToken;
                  if (snapshot.data.data.data.user.active) {
                    print('to push $pushToken');
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(snapshot.data.data.data.user.id.toString())
                        .set({
                      "pushToken": pushToken,
                      "chattingWith": null,
                      "firstName": snapshot.data.data.data.user.firstName,
                      "lastName": snapshot.data.data.data.user.lastName,
                      "profileImage": snapshot.data.data.data.user.profileImage,
                    }).then((value) => print("User updated"));
                    // .catchError((error) => print("Failed to add user: $error"));
                    _setUser(snapshot.data.data.data.user,
                        snapshot.data.data.data.tokenInfo.accessToken);
                    if (snapshot.data.data.data.user.profileImage == null) {
                      Fluttertoast.showToast(
                          msg: 'Please complete your profile');
                    }
                    myCallback(() {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              snapshot.data.data.data.user.profileImage == null
                                  ? KYC()
                                  : Home(token: token),
                        ),
                      );
                    });
                  } else {
                    bloc.getLoginEmailToken(token);
                  }
                  break;
                case Status.ERROR:
                  bloc.loginSink.add(ApiResponse.idle('message'));
                  // print(snapshot.data);
                  try {
                    Fluttertoast.showToast(
                        msg: json.decode(snapshot.data.message)['message']);
                  } on FormatException {
                    Fluttertoast.showToast(msg: snapshot.data.message);
                  }
                  break;
                case Status.GETEMAILTOKEN:
                  print('getemailtoken');

                  Fluttertoast.showToast(
                      msg: "Your account has not been activated.");
                  myCallback(() {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Activate(
                            token: token,
                            email: emailController.text,
                            code: snapshot.data.data.data.token),
                      ),
                    );
                  });
                  break;
              }
            }
            return SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: 165,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          left: 0,
                          top: 0,
                          right: 0,
                          child: Image.asset(
                            "assets/images/redbg-top-2.png",
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          left: 27,
                          top: 90,
                          child: Text(
                            "Login",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontFamily: 'Berkshire Swash',
                              color: AppColors.secondaryText,
                              fontWeight: FontWeight.w400,
                              fontSize: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height - 165,
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        children: [
                          error != null
                              ? Text(
                                  error,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 16.0, color: Colors.red),
                                )
                              : Container(
                                  height: 0.0,
                                ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: TextFormField(
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter email address';
                                  }
                                  return null;
                                },
                                controller: emailController,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.mail_outline,
                                  ),
                                  contentPadding: EdgeInsets.fromLTRB(
                                      20.0, 15.0, 20.0, 15.0),
                                  hintText: "Email Address",
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Colors.green, width: 2.0),
                                  ),
                                )),
                          ),
                          SizedBox(height: 25.0),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: TextFormField(
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter password';
                                }
                                return null;
                              },
                              obscureText: _obscureText,
                              controller: passwordController,
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscureText
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                  focusColor: Colors.green,
                                  onPressed: () {
                                    _toggle();
                                  },
                                ),
                                contentPadding:
                                    EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                hintText: "Password",
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.green, width: 2.0),
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              margin: EdgeInsets.only(top: 17, right: 38),
                              child: InkWell(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ForgotPass(),
                                  ),
                                ),
                                child: Text(
                                  "Forgot Password",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: AppColors.accentText,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topCenter,
                            child: loading
                                ? CircularProgressIndicator(
                                    backgroundColor: AppColors.secondaryElement,
                                  )
                                : InkWell(
                                    onTap: () {
                                      if (_formKey.currentState.validate()) {
                                        final data = {
                                          "deviceId": pushToken,
                                          "email": emailController.text,
                                          "latitude": _currentPosition.latitude,
                                          "longitude":
                                              _currentPosition.longitude,
                                          "password": passwordController.text,
                                        };
                                        bloc.login(data);
                                      }
                                    },
                                    child: Container(
                                      width: 72,
                                      height: 72,
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryBackground,
                                        border: Border.fromBorderSide(
                                            Borders.primaryBorder),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(36)),
                                      ),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Positioned(
                                            left: 16,
                                            right: 16,
                                            child: Container(
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color:
                                                    AppColors.secondaryElement,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20)),
                                              ),
                                              child: Container(),
                                            ),
                                          ),
                                          Positioned(
                                            child: Image.asset(
                                              "assets/images/arrow-right.png",
                                              fit: BoxFit.none,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FlatButton(
                                onPressed: () => {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Register(),
                                    ),
                                  )
                                },
                                color: Color.fromARGB(255, 245, 253, 237),
                                textColor: Color.fromARGB(255, 141, 198, 63),
                                child: Text(
                                  "Don’t have an account? Click Here",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              width: 265,
                              margin: EdgeInsets.only(bottom: 58),
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: new TextSpan(
                                  children: [
                                    new TextSpan(
                                      text:
                                          'By using the We Meet platform, you agree to our ',
                                      style: new TextStyle(
                                          color: AppColors.accentText),
                                    ),
                                    new TextSpan(
                                      text: 'Terms of Use ',
                                      style: new TextStyle(color: Colors.green),
                                      recognizer: new TapGestureRecognizer()
                                        ..onTap = () {
                                          _launchTerms();
                                        },
                                    ),
                                    new TextSpan(
                                      text: '& ',
                                      style: new TextStyle(
                                          color: AppColors.accentText),
                                    ),
                                    new TextSpan(
                                      text: 'Privacy Policy',
                                      style: new TextStyle(color: Colors.green),
                                      recognizer: new TapGestureRecognizer()
                                        ..onTap = () {
                                          _launchPrivacy();
                                        },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
          }),
    ));
  }

  Widget showCircularProgress() {
    return Center(child: CircularProgressIndicator());
  }

  void myCallback(Function callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      callback();
    });
  }
}
