import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wemeet/src/blocs/bloc.dart';
import 'package:wemeet/src/resources/api_response.dart';
import 'package:wemeet/src/views/auth/activate.dart';
import 'package:wemeet/src/views/auth/kyc.dart';
import 'package:intl/intl.dart';
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
  String pushToken;
  String token;
  dynamic userData;
  final phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  String deviceId;
  String parseDate;
  final dob = TextEditingController();
  Position _currentPosition;
  bool loading = false;
  DateTime date = DateTime.now();
  DateTime selectedDate = DateTime(
      DateTime.now().year - 18, DateTime.now().month, DateTime.now().day);

  bool _obscureText = true;
  final passwordController = TextEditingController();
  @override
  void initState() {
    super.initState();
    // initPlatformState();
    _getCurrentLocation();
    _getDevice();
  }

  _getDevice() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      pushToken = prefs.getString('pushToken');
    });
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1910),
        lastDate: DateTime(date.year - 18, date.month, date.day));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        parseDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
            .format(selectedDate.toLocal());
        dob.text = DateFormat('dd-MMM-yyyy').format(selectedDate.toLocal());
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
    CollectionReference users = FirebaseFirestore.instance.collection('users');

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
          stream: bloc.registerStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              switch (snapshot.data.status) {
                case Status.LOADING:
                  loading = true;
                  // return showCircularProgress();
                  break;
                case Status.ERROR:
                  bloc.registerSink.add(ApiResponse.idle('message'));
                  loading = false;
                  try {
                    Fluttertoast.showToast(
                        msg: json.decode(snapshot.data.message)['message']);
                  } on FormatException {
                    Fluttertoast.showToast(msg: snapshot.data.message);
                  }
                  break;
                case Status.ADDFB:
                  loading = false;
                  bloc.registerSink.add(ApiResponse.idle('message'));
                  users
                      .doc(userData.user.id.toString())
                      .set({
                        "pushToken": pushToken,
                        "chattingWith": null,
                        "firstName": userData.user.firstName,
                        "lastName": userData.user.lastName,
                        "profileImage": userData.user.profileImage,
                      })
                      .then((value) => bloc.getEmailToken(token))
                      .catchError(
                          (error) => print("Failed to add user: $error"));
                  loading = true;
                  break;
                case Status.DONE:
                  loading = false;
                  token = snapshot.data.data.data.tokenInfo.accessToken;
                  userData = snapshot.data.data.data;
                  bloc.registerSink.add(ApiResponse.addFB('snap'));
                  Fluttertoast.showToast(
                      msg: 'Account created, continue to activate.');
                  break;
                case Status.GETEMAILTOKEN:
                  print('object');
                  loading = false;
                  print('userData - ${userData.user}');
                  myCallback(() {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Activate(
                            token: token,
                            email: userData.user.email,
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
                            "Create Account",
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
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Colors.green, width: 2.0),
                                  ),
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
                                contentPadding:
                                    EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                hintText: "Phone Number",
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.green, width: 2.0),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: GestureDetector(
                              onTap: () => _selectDate(context),
                              child: AbsorbPointer(
                                child: TextFormField(
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Please select Date of Birth';
                                      }
                                      return null;
                                    },
                                    obscureText: false,
                                    controller: dob,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.calendar_today),
                                      contentPadding: EdgeInsets.fromLTRB(
                                          20.0, 15.0, 20.0, 15.0),
                                      hintText: "Date of Birth",
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.green, width: 2.0),
                                      ),
                                    )),
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
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Colors.green, width: 2.0),
                                  ),
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
                              obscureText: _obscureText,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                    icon: Icon(_obscureText
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                    onPressed: () => _toggle()),
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
                            child: loading
                                ? CircularProgressIndicator(
                                    backgroundColor: AppColors.secondaryElement,
                                  )
                                : InkWell(
                                    onTap: () {
                                      if (_formKey.currentState.validate() &&
                                          _isChecked) {
                                        final data = {
                                          "deviceId": pushToken,
                                          "dateOfBirth": parseDate,
                                          "email": emailController.text,
                                          "userName": emailController.text,
                                          "firstName": nameController.text
                                                      .split(' ')
                                                      .length >
                                                  0
                                              ? nameController.text
                                                  .split(' ')[0]
                                              : null,
                                          "lastName": nameController.text
                                                      .split(' ')
                                                      .length >
                                                  1
                                              ? nameController.text
                                                  .split(' ')[1]
                                              : null,
                                          "latitude": _currentPosition.latitude,
                                          "longitude":
                                              _currentPosition.longitude,
                                          "password": passwordController.text,
                                          "phone": phoneController.text
                                        };
                                        // print(parseDate);
                                        bloc.signup(data);
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
