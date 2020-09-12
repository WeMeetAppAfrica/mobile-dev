import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wemeet/src/views/auth/login.dart';
import 'package:wemeet/src/views/auth/picture.dart';
import 'package:wemeet/values/values.dart';

class KYC extends StatefulWidget {
  KYC({Key key}) : super(key: key);

  @override
  _KYCState createState() => _KYCState();
}

class _KYCState extends State<KYC> {
  bool _isChecked = true;
  List<RadioModel> gender = new List<RadioModel>();
  List<RadioModel> interest = new List<RadioModel>();
  String selectedGender;
  List selectedInterest;
  String selectedEmploy;
  final _formKey = GlobalKey<FormState>();
  String token;
  dynamic user;
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
    // TODO: implement initState
    super.initState();
    gender.add(new RadioModel(false, 'Guy', 'MALE'));
    gender.add(new RadioModel(false, 'Lady', 'FEMALE'));
    interest.add(new RadioModel(false, 'Guys', 'MALE'));
    interest.add(new RadioModel(false, 'Ladies', 'FEMALE'));
    employStatus.add(new RadioModel(false, 'Working', 'WORKING'));
    employStatus.add(new RadioModel(false, 'Self Employed', 'SELFEMPLOYED'));
    employStatus.add(new RadioModel(false, 'Unemployed', 'UNEMPLOYED'));
    employStatus.add(new RadioModel(false, 'Student', 'STUDENT'));
    _getUser();
  }

  _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('accessToken');
    user = jsonDecode(prefs.getString('user'));
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
      body: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 255, 255, 255),
        ),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                          "Let's Know You",
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
                                    gender.forEach((element) =>
                                        element.isSelected = false);
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
                                    contentPadding: EdgeInsets.fromLTRB(
                                        20.0, 15.0, 20.0, 15.0),
                                    hintText: "Date of Birth",
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
                            min: 16,
                            divisions: 80,
                            max: 96,
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
                                  "dateOfBirth": selectedDate,
                                  "gender": selectedGender,
                                  "genderPreference": selectedInterest,
                                  "id": user['id'],
                                  "maxAge": selectedRange.end.toInt(),
                                  "minAge": selectedRange.start.toInt(),
                                  "swipeRadius": 0,
                                  "workStatus": selectedEmploy
                                };
                                if (showInterestError == false) {
                                  print(data);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Picture(kyc: data,),
                                    ),
                                  );
                                }
                              }
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
                      ],
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
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
