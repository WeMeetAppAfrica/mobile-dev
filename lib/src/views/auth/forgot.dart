import 'dart:convert';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wemeet/src/blocs/bloc.dart';
import 'package:wemeet/src/resources/api_response.dart';
import 'package:wemeet/src/views/auth/kyc.dart';
import 'package:wemeet/src/views/auth/register.dart';
import 'package:wemeet/src/views/dashboard/home.dart';

import 'package:wemeet/values/values.dart';

class ForgotPass extends StatefulWidget {
  final email;
  final token;
  final code;
  ForgotPass({Key key, this.email, this.token, this.code}) : super(key: key);

  @override
  _ForgotPassState createState() => _ForgotPassState();
}

class _ForgotPassState extends State<ForgotPass> {
  Position _currentPosition;
  String deviceId;
  bool _obscureText = true;
  bool _obscureConText = true;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool loading = false;
  bool showToken = false;
  bool showPassword = false;
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

  void _toggleCon() {
    setState(() {
      _obscureConText = !_obscureConText;
    });
  }

  _getCurrentLocation() {
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
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
                  break;
                case Status.IDLE:
                  loading = false;
                  break;
                case Status.FORGOTPASS:
                  bloc.loginSink.add(ApiResponse.idle('message'));
                  showToken = true;
                  Fluttertoast.showToast(msg: snapshot.data.data.message);

                  break;
                case Status.VERIFYFORGOTTOKEN:
                  bloc.loginSink.add(ApiResponse.idle('message'));
                  showPassword = true;
                  Fluttertoast.showToast(msg: snapshot.data.data.message);

                  break;
                case Status.RESETPASSWORD:
                  bloc.loginSink.add(ApiResponse.idle('message'));
                  Fluttertoast.showToast(msg: snapshot.data.data.message);
                    myCallback(() {
                      Navigator.pop(context);
                    });

                  break;
                case Status.ERROR:
                  bloc.loginSink.add(ApiResponse.idle('message'));
                  try {
                    Fluttertoast.showToast(
                        msg: json.decode(snapshot.data.message)['message']);
                  } on FormatException {
                    Fluttertoast.showToast(msg: snapshot.data.message);
                  }
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
                          top: 65,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                child: Icon(Icons.arrow_back_ios,
                                    color: AppColors.secondaryText),
                                onTap: () => {Navigator.pop(context)},
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                "Forgot Password",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontFamily: 'Berkshire Swash',
                                  color: AppColors.secondaryText,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 20,
                                ),
                              ),
                            ],
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
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.mail_outline),
                                  contentPadding: EdgeInsets.fromLTRB(
                                      20.0, 15.0, 20.0, 15.0),
                                  hintText: "Email",
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Colors.green, width: 2.0),
                                  ),
                                )),
                          ),
                          showToken
                              ? Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: TextFormField(
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Please enter token';
                                        }
                                        return null;
                                      },
                                      controller: codeController,
                                      decoration: InputDecoration(
                                        prefixIcon: Icon(Icons.lock),
                                        contentPadding: EdgeInsets.fromLTRB(
                                            20.0, 15.0, 20.0, 15.0),
                                        hintText: "Token",
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.green, width: 2.0),
                                        ),
                                      )),
                                )
                              : Container(),
                          showPassword
                              ? Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: TextFormField(
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Please enter new password';
                                        }
                                        return null;
                                      },
                                      controller: passwordController,
                                      obscureText: _obscureText,
                                      decoration: InputDecoration(
                                        prefixIcon: Icon(Icons.lock),
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
                                        hintText: "New Password",
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.green, width: 2.0),
                                        ),
                                      )),
                                )
                              : Container(),
                          showPassword
                              ? Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: TextFormField(
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Please confirm new password';
                                        }
                                        return null;
                                      },
                                      controller: confirmPasswordController,
                                      obscureText: _obscureConText,
                                      decoration: InputDecoration(
                                        prefixIcon: Icon(Icons.lock),
                                        suffixIcon: IconButton(
                                          icon: Icon(_obscureConText
                                              ? Icons.visibility
                                              : Icons.visibility_off),
                                          onPressed: () {
                                            _toggleCon();
                                          },
                                        ),
                                        contentPadding: EdgeInsets.fromLTRB(
                                            20.0, 15.0, 20.0, 15.0),
                                        hintText: "Confirm Password",
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.green, width: 2.0),
                                        ),
                                      )),
                                )
                              : Container(),
                          SizedBox(height: 25.0),
                          Align(
                            alignment: Alignment.topCenter,
                            child: loading
                                ? CircularProgressIndicator(
                                    backgroundColor: AppColors.secondaryElement,
                                  )
                                : InkWell(
                                    onTap: () {
                                      if (showPassword) {
                                        var request = {
                                          "confirmPassword":
                                              confirmPasswordController.text,
                                          "email": emailController.text,
                                          "password": passwordController.text,
                                          "token": codeController.text
                                        };
                                        bloc.resetPassword(request);
                                        return;
                                      }
                                      if (showToken) {
                                        bloc.verifyForgotToken(
                                            emailController.text,
                                            codeController.text);
                                        return;
                                      }
                                      if (_formKey.currentState.validate()) {
                                        bloc.getForgotPass(
                                            emailController.text);
                                        return;
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
