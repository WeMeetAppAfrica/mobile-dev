import 'dart:convert';

import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:wemeet/src/blocs/bloc.dart';
import 'package:wemeet/src/resources/api_response.dart';
import 'package:wemeet/src/views/dashboard/profile.dart';
import 'package:wemeet/values/values.dart';

class UpdateLocation extends StatefulWidget {
  final token;
  UpdateLocation({Key key, this.token}) : super(key: key);

  @override
  _UpdateLocationState createState() => _UpdateLocationState();
}

class _UpdateLocationState extends State<UpdateLocation> {
  bool _obscureText = true;
  static final kInitialPosition = LatLng(-33.8567844, 151.213108);

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
          'Change Location',
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
                    child: CircularProgressIndicator(),
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlacePicker(
                              apiKey:
                                  'AIzaSyBj-o7zMuXghnp0gLzZvZy7Bh1IE-TAB9M', // Put YOUR OWN KEY here.
                              onPlacePicked: (result) {
                                print(result);
                                Navigator.of(context).pop();
                              },
                              initialPosition: LatLng(-33.8567844, 151.213108),
                              useCurrentLocation: true,
                            ),
                          ),
                        );
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter location';
                        }
                        return null;
                      },
                      controller: passController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(FeatherIcons.mapPin),
                        contentPadding:
                            EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        hintText: "Location",
                      ),
                      obscureText: _obscureText,
                    ),
                    SizedBox(
                      height: 20,
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
