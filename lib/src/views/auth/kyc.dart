import 'package:flutter/material.dart';
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
  RangeValues selectedRange = RangeValues(18, 30);
  List<RadioModel> employStatus = new List<RadioModel>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    gender.add(new RadioModel(false, 'Guy'));
    gender.add(new RadioModel(false, 'Lady'));
    interest.add(new RadioModel(false, 'Guys'));
    interest.add(new RadioModel(false, 'Ladies'));
    employStatus.add(new RadioModel(false, 'Working'));
    employStatus.add(new RadioModel(false, 'Self Employed'));
    employStatus.add(new RadioModel(false, 'Unemployed'));
    employStatus.add(new RadioModel(false, 'Student'));
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
                Container(
                  height: MediaQuery.of(context).size.height - 165,
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
                                });
                              },
                              child: new RadioItem(gender[index]),
                            );
                          },
                        ),
                      ),
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
                                  interest.forEach(
                                      (element) => element.isSelected = false);
                                  interest[index].isSelected = true;
                                });
                              },
                              child: new RadioItem(interest[index]),
                            );
                          },
                        ),
                      ),
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
                              });
                            },
                            child: new RadioItem(employStatus[3]),
                          ),
                        ],
                      ),
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
                        child: TextFormField(
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please select Date of Birth';
                              }
                              return null;
                            },
                            obscureText: false,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.calendar_today),
                              contentPadding:
                                  EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                              hintText: "Date of Birth",
                            )),
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
                          divisions: 81,
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Picture(),
                              ),
                            );
                          },
                          child: Container(
                            width: 72,
                            height: 72,
                            margin: EdgeInsets.only(bottom: 32),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBackground,
                              border:
                                  Border.fromBorderSide(Borders.primaryBorder),
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

  RadioModel(this.isSelected, this.buttonText);
}
