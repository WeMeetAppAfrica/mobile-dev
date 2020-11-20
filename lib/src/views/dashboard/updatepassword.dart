import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:wemeet/src/blocs/bloc.dart';
import 'package:wemeet/src/resources/api_response.dart';
import 'package:wemeet/src/views/dashboard/profile.dart';
import 'package:wemeet/values/values.dart';

class UpdatePassword extends StatefulWidget {
  final token;
  UpdatePassword({Key key, this.token}) : super(key: key);

  @override
  _UpdatePasswordState createState() => _UpdatePasswordState();
}

class _UpdatePasswordState extends State<UpdatePassword> {
  bool _obscureText = true;
  final passController = TextEditingController();
  final confirmPassController = TextEditingController();
  final newPassController = TextEditingController();
  bool _obscureNewText = true;
  final _formKey = GlobalKey<FormState>();
  bool _obscureConText = true;
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _toggleNew() {
    setState(() {
      _obscureNewText = !_obscureNewText;
    });
  }

  void _toggleCon() {
    setState(() {
      _obscureConText = !_obscureConText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: new IconThemeData(color: AppColors.primaryText),
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: Text(
          'Update Password',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontFamily: 'Berkshire Swash',
            color: AppColors.primaryText,
            fontWeight: FontWeight.w400,
            fontSize: 24,
          ),
        ),
      ),
      body: StreamBuilder(
          stream: bloc.userStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              switch (snapshot.data.status) {
                case Status.LOADING:
                  return Center(
                    child: Container(),
                  );
                  break;
                case Status.DONE:
                  bloc.userSink.add(ApiResponse.idle('message'));
                  Fluttertoast.showToast(msg: 'Password changed');
                  myCallback(() {
                    Navigator.pop(context);
                  });
                  break;
                  case Status.ERROR:
                  bloc.userSink.add(ApiResponse.idle('message'));
                    try {
                      Fluttertoast.showToast(
                          msg: json.decode(snapshot.data.message)['message']);
                    } on FormatException {
                      Fluttertoast.showToast(msg: snapshot.data.message);
                    }
                    break;
                default:
              }
            }
            return Container(
              color: Colors.white,
              padding: const EdgeInsets.all(12.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(
                      height: 8,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter current password';
                        }
                        return null;
                      },
                      controller: passController,
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
                        contentPadding:
                            EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        hintText: "Current Password",
                            focusedBorder: UnderlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.green, width: 2.0),),
                      ),
                      obscureText: _obscureText,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter new password';
                        }
                        return null;
                      },
                      controller: newPassController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureNewText
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            _toggleNew();
                          },
                        ),
                        contentPadding:
                            EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        hintText: "New Password",
                            focusedBorder: UnderlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.green, width: 2.0),),
                      ),
                      obscureText: _obscureNewText,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter new password again';
                        }
                        return null;
                      },
                      controller: confirmPassController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConText
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            _toggleCon();
                          },
                        ),
                        contentPadding:
                            EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        hintText: "Confirm New Password",
                            focusedBorder: UnderlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.green, width: 2.0),),
                      ),
                      obscureText: _obscureConText,
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: InkWell(
                        onTap: () {
                          if (_formKey.currentState.validate()) {
                            var data = {
                              "confirmPassword": confirmPassController.text,
                              "newPassword": newPassController.text,
                              "oldPassword": passController.text
                            };
                            bloc.changePassword(data, widget.token);
                          }
                        },
                        child: Container(
                          width: 72,
                          height: 72,
                          margin: EdgeInsets.only(top: 72),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBackground,
                            border:
                                Border.fromBorderSide(Borders.primaryBorder),
                            borderRadius: BorderRadius.all(Radius.circular(36)),
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
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
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
            );
          }),
    );
  }
}

void myCallback(Function callback) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    callback();
  });
}
