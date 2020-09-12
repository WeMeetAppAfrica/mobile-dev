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

import 'package:wemeet/values/values.dart';

class Login extends StatefulWidget {
  Login({Key key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  Position _currentPosition;
  String deviceId;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String error = '';
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    // initPlatformState();
    _getCurrentLocation();
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

  _setUser(user, token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('accessToken', token);
    prefs.setString('user', jsonEncode(user));
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
                  return showCircularProgress();
                  break;
                case Status.DONE:
                bloc.loginSink.add(ApiResponse.idle('message'));
                  print(snapshot.data.data.data.tokenInfo.accessToken);
                  _setUser(snapshot.data.data.data.user,
                      snapshot.data.data.data.tokenInfo.accessToken);
                  myCallback(() {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => KYC(),
                      ),
                    );
                  });
                  break;
                case Status.ERROR:
                try{
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
                              "Login",
                              textAlign: TextAlign.left,
                              style: TextStyle(
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
                                  controller: emailController,
                                  obscureText: false,
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
                                    return 'Please enter password';
                                  }
                                  return null;
                                },
                                obscureText: true,
                                controller: passwordController,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.lock_outline),
                                  suffixIcon: Icon(Icons.visibility_off),
                                  contentPadding: EdgeInsets.fromLTRB(
                                      20.0, 15.0, 20.0, 15.0),
                                  hintText: "Password",
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                margin: EdgeInsets.only(top: 17, right: 38),
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
                            Align(
                              alignment: Alignment.topCenter,
                              child: InkWell(
                                onTap: () {
                                  if (_formKey.currentState.validate()) {
                                    final data = {
                                      "deviceId": deviceId,
                                      "email": emailController.text,
                                      "latitude": _currentPosition.latitude,
                                      "longitude": _currentPosition.longitude,
                                      "password": passwordController.text,
                                    };
                                    bloc.login(data);
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
                                child: Text(
                                  "By using the We Meet platform, you agree to our Terms of Use & Privacy Policy",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.accentText,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
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
