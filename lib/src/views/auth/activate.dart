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

class Activate extends StatefulWidget {
  final email;
  final token;
  final code;
  Activate({Key key, this.email, this.token, this.code}) : super(key: key);

  @override
  _ActivateState createState() => _ActivateState();
}

class _ActivateState extends State<Activate> {
  String deviceId;
  bool _obscureText = true;
  final emailController = TextEditingController();
  bool loading = false;
  final codeController = TextEditingController();
  String error = '';
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    // initPlatformState();
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
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
                  // return showCircularProgress();
                  break;
                case Status.ACTIVATED:
                  bloc.loginSink.add(ApiResponse.idle('message'));
                  loading = false;
                  print(widget.token);
                  _setUser(widget.token);
                  Fluttertoast.showToast(msg: 'Please complete your profile');

                  myCallback(() {
                    Navigator.pushReplacementNamed(context,"/kyc");
                  });
                  break;
                case Status.RESENDEMAILTOKEN:
                  bloc.loginSink.add(ApiResponse.idle('message'));
                  print('object');
                  loading = false;
                  Fluttertoast.showToast(msg: snapshot.data.data.message);

                  break;
                case Status.ERROR:
                  bloc.loginSink.add(ApiResponse.idle('message'));
                  loading = false;
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
                          top: 90,
                          child: Text(
                            "Activate",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontFamily: 'Berkshire Swash',
                              color: AppColors.secondaryText,
                              fontWeight: FontWeight.w400,
                              fontSize: 20,
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
                                      focusColor: Colors.green,
                                  onPressed: () {
                                    _toggle();
                                  },
                                ),
                                contentPadding:
                                    EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                hintText: "Code",
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
                                onTap: () => bloc.resendEmailToken(widget.token),
                                child: Text(
                                  "Resend Activation Code",
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
                          SizedBox(height: 20),
                          Align(
                            alignment: Alignment.topCenter,
                            child: loading
                                ? CircularProgressIndicator(
                                    backgroundColor: AppColors.secondaryElement,
                                  )
                                : InkWell(
                                    onTap: () {
                                      if (_formKey.currentState.validate()) {
                                        bloc.emailVerification(
                                            codeController.text, widget.token);
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
