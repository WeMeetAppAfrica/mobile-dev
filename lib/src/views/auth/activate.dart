import 'dart:convert';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wemeet/src/blocs/bloc.dart';
import 'package:wemeet/src/resources/api_response.dart';
import 'package:wemeet/src/views/auth/kyc.dart';
import 'package:wemeet/src/views/auth/register.dart';
import 'package:wemeet/src/views/dashboard/home.dart';

import 'package:wemeet/values/values.dart';

class Activate extends StatefulWidget {
  final email;
  final token;
  final code;
  Activate({Key key, this.email, this.token, this.code}) : super(key: key);

  @override
  _ActivateState createState() => _ActivateState();
}

class _ActivateState extends State<Activate> {
  Position _currentPosition;
  String deviceId;
  bool _obscureText = true;
  final emailController = TextEditingController();
  final codeController = TextEditingController();
  String error = '';
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    // initPlatformState();
    _getCurrentLocation();
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  _getCurrentLocation() {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });
    }).catchError((e) {
      print(e);
    });
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

  _setUser(token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('accessToken', token);
    prefs.setBool('passKYC', false);
  }

  @override
  Widget build(BuildContext context) {
    emailController.text = widget.email;
    codeController.text = widget.code;
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
                  return showCircularProgress();
                  break;
                case Status.DONE:
                  bloc.loginSink.add(ApiResponse.idle('message'));
                  print(widget.token);
                  _setUser(widget.token);
                  myCallback(() {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            snapshot.data.data.data.user.profileImage == null
                                ? KYC()
                                : Home(token: widget.token),
                      ),
                    );
                  });
                  break;
                case Status.ERROR:
                  try {
                    error = json.decode(snapshot.data.message)['message'];
                  } on FormatException {
                    print(snapshot.data.message);
                  }
                  // error = json.decode(snapshot.data.message)['message'];
                  break;
              }
            }
            return Stack(
              alignment: Alignment.topCenter,
              children: [
                Column(
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
                              "Activate",
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
                                      return 'Please enter email';
                                    }
                                    return null;
                                  },
                                  enabled: false,
                                  controller: emailController,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.mail_outline),
                                    contentPadding: EdgeInsets.fromLTRB(
                                        20.0, 15.0, 20.0, 15.0),
                                    hintText: "Email",
                                  )),
                            ),
                            SizedBox(height: 25.0),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: TextFormField(
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter validation code';
                                  }
                                  return null;
                                },
                                obscureText: _obscureText,
                                controller: codeController,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscureText
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                    onPressed: () {
                                      _toggle();
                                    },
                                  ),
                                  contentPadding: EdgeInsets.fromLTRB(
                                      20.0, 15.0, 20.0, 15.0),
                                  hintText: "Code",
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.topCenter,
                              child: InkWell(
                                onTap: () {
                                  if (_formKey.currentState.validate()) {
                                    bloc.emailVerification(
                                        codeController.text, widget.token);
                                  }
                                },
                                child: Container(
                                  width: 72,
                                  height: 72,
                                  margin: EdgeInsets.only(top: 72),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryBackground,
                                    border: Border.fromBorderSide(
                                        Borders.primaryBorder),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(36)),
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
                                            color: AppColors.secondaryElement,
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
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ],
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
