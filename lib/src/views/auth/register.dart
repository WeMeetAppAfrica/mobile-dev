import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wemeet/src/blocs/bloc.dart';
import 'package:wemeet/src/resources/api_response.dart';
import 'package:wemeet/src/views/auth/kyc.dart';
import 'package:wemeet/src/views/auth/login.dart';
import 'package:wemeet/values/values.dart';
import 'package:device_info/device_info.dart';

class Register extends StatefulWidget {
  Register({Key key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};
  bool _isChecked = true;
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  String deviceId;
  Position _currentPosition;
  final passwordController = TextEditingController();
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
          stream: bloc.userStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              switch (snapshot.data.status) {
                case Status.LOADING:
                  return showCircularProgress();
                  break;
                case Status.DONE:
                  myCallback(() {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => KYC(),
                      ),
                    );
                  });
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
                              "Create Account",
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
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: TextFormField(
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please enter full name';
                                    }
                                    return null;
                                  },
                                  controller: nameController,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.person_outline),
                                    contentPadding: EdgeInsets.fromLTRB(
                                        20.0, 15.0, 20.0, 15.0),
                                    hintText: "Your Name",
                                  )),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: TextFormField(
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter phone number';
                                  }
                                  return null;
                                },
                                controller: phoneController,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.phone),
                                  contentPadding: EdgeInsets.fromLTRB(
                                      20.0, 15.0, 20.0, 15.0),
                                  hintText: "Phone Number",
                                ),
                              ),
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
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: TextFormField(
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter password';
                                  }
                                  return null;
                                },
                                controller: passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.lock_outline),
                                  suffixIcon: Icon(Icons.visibility_off),
                                  contentPadding: EdgeInsets.fromLTRB(
                                      20.0, 15.0, 20.0, 15.0),
                                  hintText: "Password",
                                ),
                              ),
                            ),
                            CheckboxListTile(
                              controlAffinity: ListTileControlAffinity.leading,
                              title: Text(
                                "I agree to the terms & privacy policy",
                              ),
                              value: _isChecked,
                              onChanged: (val) {
                                setState(() {
                                  _isChecked = val;
                                });
                              },
                            ),
                            Align(
                              alignment: Alignment.topCenter,
                              child: InkWell(
                                onTap: () {
                                  if (_formKey.currentState.validate() &&
                                      _isChecked) {
                                    final data = {
                                      "dateOfBirth": "2000-09-08T17:43:25.164Z",
                                      "deviceId": deviceId,
                                      "email": emailController.text,
                                      "firstName": nameController.text,
                                      "lastName": nameController.text,
                                      "latitude": _currentPosition.latitude,
                                      "longitude": _currentPosition.longitude,
                                      "password": passwordController.text,
                                      "phone": phoneController.text
                                    };
                                    bloc.signup(data);
                                  }
                                  print(_isChecked);
                                },
                                child: Container(
                                  width: 72,
                                  height: 72,
                                  margin: EdgeInsets.only(bottom: 32),
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
                                Navigator.pop(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Login(),
                                  ),
                                )
                              },
                              color: Color.fromARGB(255, 245, 253, 237),
                              textColor: Color.fromARGB(255, 141, 198, 63),
                              child: Text(
                                "I have an account",
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                              ],
                            ),
                            
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
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
