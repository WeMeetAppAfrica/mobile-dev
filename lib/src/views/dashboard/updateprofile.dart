import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wemeet/src/blocs/bloc.dart';
import 'package:wemeet/src/resources/api_response.dart';
import 'package:wemeet/src/views/auth/login.dart';
import 'package:wemeet/src/views/auth/picture.dart';
import 'package:wemeet/src/views/dashboard/profile.dart';
import 'package:wemeet/src/views/dashboard/updatepicture.dart';
import 'package:wemeet/values/values.dart';

class UpdateProfile extends StatefulWidget {
  UpdateProfile({Key key}) : super(key: key);

  @override
  _UpdateProfileState createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  bool _isChecked = true;
  List<RadioModel> gender = new List<RadioModel>();
  List<RadioModel> interest = new List<RadioModel>();
  String selectedGender;
  double maxDist = 1.0;
  List selectedInterest;
  String selectedEmploy;
  final _formKey = GlobalKey<FormState>();
  String token;
  dynamic user;
  String profileImage;
  List additionalImages;
  bool showInterestError = false;
  bool showGenderError = false;
  bool showWorkError = false;
  final bioController = TextEditingController();
  final dob = TextEditingController();
  RangeValues selectedRange = RangeValues(18, 30);
  List<RadioModel> employStatus = new List<RadioModel>();
  DateTime date = DateTime.now();
  DateTime selectedDate = DateTime(
      DateTime.now().year - 18, DateTime.now().month, DateTime.now().day);

  @override
  void initState() {
    super.initState();
    gender.add(new RadioModel(false, 'Guy', 'MALE'));
    gender.add(new RadioModel(false, 'Lady', 'FEMALE'));
    interest.add(new RadioModel(false, 'Guys', 'MALE'));
    interest.add(new RadioModel(false, 'Ladies', 'FEMALE'));
    employStatus.add(new RadioModel(false, 'Working', 'WORKING'));
    employStatus.add(new RadioModel(false, 'Self Employed', 'SELF_EMPLOYED'));
    employStatus.add(new RadioModel(false, 'Unemployed', 'UNEMPLOYED'));
    employStatus.add(new RadioModel(false, 'Student', 'STUDENT'));
    _getUser();
  }

  _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('accessToken');
    user = jsonDecode(prefs.getString('user'));
    bloc.getProfile(token);
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
        dob.text = DateFormat('dd-MMM-yyyy').format(selectedDate.toLocal());
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
          'Update Profile',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontFamily: 'Berkshire Swash',
            color: AppColors.primaryText,
            fontWeight: FontWeight.w400,
            fontSize: 24,
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.only(top: 16),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 255, 255, 255),
        ),
        child: StreamBuilder(
            stream: bloc.profileStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                switch (snapshot.data.status) {
                  case Status.LOADING:
                    return Center(child: CircularProgressIndicator());
                    break;
                  case Status.GETPROFILE:
                    bloc.profileSink.add(ApiResponse.idle('message'));
                    gender.forEach((element) => {
                          if (element.buttonValue ==
                              snapshot.data.data.data.gender)
                            element.isSelected = true
                        });
                    selectedGender = snapshot.data.data.data.gender;
                    employStatus.forEach((element) => {
                          if (element.buttonValue ==
                              snapshot.data.data.data.workStatus)
                            element.isSelected = true
                        });
                    maxDist = snapshot.data.data.data.swipeRadius.toDouble() >
                                0 &&
                            snapshot.data.data.data.swipeRadius.toDouble() < 101
                        ? snapshot.data.data.data.swipeRadius.toDouble()
                        : 1;
                    dob.text = DateFormat('dd-MMM-yyyy').format(
                        DateTime.fromMillisecondsSinceEpoch(
                            snapshot.data.data.data.dateOfBirth));
                    selectedEmploy = snapshot.data.data.data.workStatus;
                    if (snapshot.data.data.data.genderPreference != null) {
                      snapshot.data.data.data.genderPreference
                          .forEach((gPref) => {
                                interest.forEach((element) => {
                                      if (element.buttonValue == gPref)
                                        element.isSelected = true
                                    })
                              });
                    }
                    bioController.text = snapshot.data.data.data.bio;
                    profileImage = snapshot.data.data.data.profileImage;
                    additionalImages = snapshot.data.data.data.additionalImages;
                    if (snapshot.data.data.data.minAge != null &&
                        snapshot.data.data.data.maxAge != null) {
                      selectedRange = RangeValues(
                          snapshot.data.data.data.minAge.toDouble(),
                          snapshot.data.data.data.maxAge.toDouble());
                    }
                    break;
                  case Status.ERROR:
                    try {
                      Fluttertoast.showToast(
                          msg: json.decode(snapshot.data.message)['message']);
                    } on FormatException {
                      Fluttertoast.showToast(msg: snapshot.data.message);
                    }
                    Navigator.pop(context);
                    break;
                  case Status.DONE:
                    bloc.profileSink.add(ApiResponse.idle('message'));
                    Fluttertoast.showToast(msg: 'Profile Updated');
                    myCallback(() {
                      Navigator.pop(context);
                    });
                    break;
                  default:
                }
              }
              return Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        "I am a",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: AppColors.primaryText,
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Container(
                      height: 72,
                      child: ListView.builder(
                        itemCount: gender.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (BuildContext context, int index) {
                          return new InkWell(
                            //highlightColor: Colors.red,
                            splashColor: AppColors.secondaryElement,
                            onTap: () {
                              setState(() {
                                gender.forEach(
                                    (element) => element.isSelected = false);
                                gender[index].isSelected = true;
                                selectedGender = gender[index].buttonValue;
                              });
                            },
                            child: new RadioItem(gender[index]),
                          );
                        },
                      ),
                    ),
                    showGenderError
                        ? Padding(
                            padding: EdgeInsets.only(left: 20),
                            child: Text(
                              "Please select gender",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                              ),
                            ),
                          )
                        : Container(),
                    SizedBox(
                      height: 25,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        "I am interested in",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: AppColors.primaryText,
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Container(
                      height: 72,
                      child: ListView.builder(
                        itemCount: interest.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (BuildContext context, int index) {
                          return new InkWell(
                            //highlightColor: Colors.red,
                            splashColor: AppColors.secondaryElement,
                            onTap: () {
                              setState(() {
                                showInterestError = false;
                                interest[index].isSelected =
                                    !interest[index].isSelected;
                              });
                            },
                            child: new RadioItem(interest[index]),
                          );
                        },
                      ),
                    ),
                    showInterestError
                        ? Padding(
                            padding: EdgeInsets.only(left: 20),
                            child: Text(
                              "Please select atleast one interest",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                              ),
                            ),
                          )
                        : Container(),
                    SizedBox(
                      height: 25,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20, bottom: 10),
                      child: Text(
                        "I am currently",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: AppColors.primaryText,
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        InkWell(
                          //highlightColor: Colors.red,
                          splashColor: AppColors.secondaryElement,
                          onTap: () {
                            setState(() {
                              employStatus.forEach(
                                  (element) => element.isSelected = false);
                              employStatus[0].isSelected = true;
                              selectedEmploy = employStatus[0].buttonValue;
                            });
                          },
                          child: new RadioItem(employStatus[0]),
                        ),
                        InkWell(
                          //highlightColor: Colors.red,
                          splashColor: AppColors.secondaryElement,
                          onTap: () {
                            setState(() {
                              employStatus.forEach(
                                  (element) => element.isSelected = false);
                              employStatus[1].isSelected = true;
                              selectedEmploy = employStatus[1].buttonValue;
                            });
                          },
                          child: new RadioItem(employStatus[1]),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        InkWell(
                          //highlightColor: Colors.red,
                          splashColor: AppColors.secondaryElement,
                          onTap: () {
                            setState(() {
                              employStatus.forEach(
                                  (element) => element.isSelected = false);
                              employStatus[2].isSelected = true;
                              selectedEmploy = employStatus[2].buttonValue;
                            });
                          },
                          child: new RadioItem(employStatus[2]),
                        ),
                        InkWell(
                          //highlightColor: Colors.red,
                          splashColor: AppColors.secondaryElement,
                          onTap: () {
                            setState(() {
                              employStatus.forEach(
                                  (element) => element.isSelected = false);
                              employStatus[3].isSelected = true;
                              selectedEmploy = employStatus[3].buttonValue;
                            });
                          },
                          child: new RadioItem(employStatus[3]),
                        ),
                      ],
                    ),
                    showWorkError
                        ? Padding(
                            padding: EdgeInsets.only(left: 20, top: 10),
                            child: Text(
                              "Please select work status",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                              ),
                            ),
                          )
                        : Container(),
                    // Container(
                    //   height: 72,
                    //   child: ListView.builder(
                    //     itemCount: employStatus.length,
                    //     scrollDirection: Axis.horizontal,
                    //     itemBuilder: (BuildContext context, int index) {
                    //       return new InkWell(
                    //         //highlightColor: Colors.red,
                    //         splashColor: AppColors.secondaryElement,
                    //         onTap: () {
                    //           setState(() {
                    //             employStatus.forEach(
                    //                 (element) => element.isSelected = false);
                    //             employStatus[index].isSelected = true;
                    //           });
                    //         },
                    //         child: new RadioItem(employStatus[index]),
                    //       );
                    //     },
                    //   ),
                    // ),
                    SizedBox(
                      height: 25,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        "What's your age?",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: AppColors.primaryText,
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
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
                                contentPadding:
                                    EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                hintText: "Date of Birth",
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.green, width: 2.0),
                                ),
                              )),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        "Talk About Yourself",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: AppColors.primaryText,
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter Bio';
                            }
                            return null;
                          },
                          obscureText: false,
                          controller: bioController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person_outline),
                            contentPadding:
                                EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                            hintText: "Bio",
                            focusedBorder: UnderlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.green, width: 2.0),
                            ),
                          )),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        "What age range interests you?",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: AppColors.primaryText,
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.secondaryElement,
                        thumbColor: AppColors.secondaryElement,
                        inactiveTrackColor: AppColors.primaryElement,
                        trackShape: RectangularSliderTrackShape(),
                        trackHeight: 1.0,
                        valueIndicatorColor: AppColors.secondaryElement,
                        thumbShape:
                            RoundSliderThumbShape(enabledThumbRadius: 12.0),
                        overlayColor: Colors.red.withAlpha(32),
                        overlayShape:
                            RoundSliderOverlayShape(overlayRadius: 28.0),
                      ),
                      child: RangeSlider(
                        min: 18,
                        divisions: 42,
                        max: 60,
                        labels: RangeLabels(
                          selectedRange.start.round().toString(),
                          selectedRange.end.round().toString(),
                        ),
                        values: selectedRange,
                        onChanged: (RangeValues newRange) =>
                            {setState(() => selectedRange = newRange)},
                      ),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    ListTile(
                      onTap: () {},
                      title: Text('Maximum Distance'),
                      subtitle: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppColors.secondaryElement,
                          thumbColor: AppColors.secondaryElement,
                          inactiveTrackColor: AppColors.primaryElement,
                          trackShape: RectangularSliderTrackShape(),
                          trackHeight: 1.0,
                          valueIndicatorColor: AppColors.secondaryElement,
                          thumbShape:
                              RoundSliderThumbShape(enabledThumbRadius: 12.0),
                          overlayColor: Colors.red.withAlpha(32),
                          overlayShape:
                              RoundSliderOverlayShape(overlayRadius: 28.0),
                        ),
                        child: Slider(
                          min: 1,
                          divisions: 99,
                          max: 100,
                          value: maxDist,
                          onChanged: (double value) {
                            setState(() {
                              maxDist = value;
                            });
                          },
                        ),
                      ),
                      trailing: Text('${maxDist.toInt()} mi'),
                    ),

                    SizedBox(
                      height: 25,
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            showGenderError = false;
                            showInterestError = false;
                            showWorkError = false;
                          });
                          if (selectedEmploy == null) {
                            setState(() {
                              showWorkError = true;
                            });
                          }
                          if (selectedGender == null) {
                            setState(() {
                              showGenderError = true;
                            });
                          }
                          if (_formKey.currentState.validate()) {
                            selectedInterest = [];
                            interest.forEach((element) {
                              if (element.isSelected) {
                                selectedInterest.add(element.buttonValue);
                              }
                            });

                            if (selectedInterest.isEmpty) {
                              setState(() {
                                showInterestError = true;
                              });
                            }
                            final data = {
                              "bio": bioController.text,
                              // "dateOfBirth": selectedDate,
                              "gender": selectedGender,
                              "genderPreference": selectedInterest,
                              "maxAge": selectedRange.end.toInt(),
                              "minAge": selectedRange.start.toInt(),
                              "swipeRadius": maxDist.toInt(),
                              "workStatus": selectedEmploy
                            };
                            if (showInterestError == false) {
                              print(selectedDate.toString());
                              bloc.updateProfile(data, token);
                            }
                          }
                        },
                        child: Container(
                          width: 72,
                          height: 72,
                          margin: EdgeInsets.only(bottom: 32),
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
              );
            }),
      ),
    );
  }
}

class RadioItem extends StatelessWidget {
  final RadioModel _item;
  RadioItem(this._item);
  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: new EdgeInsets.only(left: 15.0),
      child: new Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          new Container(
            height: 50.0,
            child: new Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: new Text(_item.buttonText,
                    style: new TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: _item.isSelected
                          ? AppColors.secondaryText
                          : AppColors.accentText,
                      //fontWeight: FontWeight.bold,
                    )),
              ),
            ),
            decoration: new BoxDecoration(
              color: _item.isSelected
                  ? AppColors.secondaryElement
                  : Color.fromARGB(255, 247, 247, 247),
              border: new Border.all(
                  width: 1.0,
                  color: _item.isSelected
                      ? AppColors.secondaryElement
                      : Color.fromARGB(255, 247, 247, 247)),
              borderRadius: Radii.k8pxRadius,
            ),
          )
        ],
      ),
    );
  }
}

class RadioModel {
  bool isSelected;
  final String buttonText;
  final String buttonValue;

  RadioModel(this.isSelected, this.buttonText, this.buttonValue);
}

void myCallback(Function callback) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    callback();
  });
}
