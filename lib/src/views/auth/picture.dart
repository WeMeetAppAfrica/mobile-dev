import 'package:flutter/material.dart';
import 'package:wemeet/src/views/auth/kyc.dart';
import 'package:wemeet/src/views/auth/login.dart';
import 'package:wemeet/values/values.dart';

class Picture extends StatefulWidget {
  Picture({Key key}) : super(key: key);

  @override
  _PictureState createState() => _PictureState();
}

class _PictureState extends State<Picture> {
  bool _isChecked = true;
  List<RadioModel> gender = new List<RadioModel>();
  List<RadioModel> interest = new List<RadioModel>();
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
                        top: 65,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              child: Icon(Icons.arrow_back_ios,
                                  color: AppColors.secondaryText),
                              onTap: () => {
                                Navigator.pop(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => KYC(),
                                  ),
                                )
                              },
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              "Add Picture",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: AppColors.secondaryText,
                                fontWeight: FontWeight.w400,
                                fontSize: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height - 165,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Text(
                          "Profile Photo",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: AppColors.primaryText,
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: 20,
                        ),
                        child: InkWell(
                          onTap: () {
                            print('add photo');
                          },
                          child: Container(
                            height: 120.0,
                            width: 120,
                            child: Icon(Icons.photo_camera),
                            decoration: new BoxDecoration(
                              color: Color.fromARGB(255, 247, 247, 247),
                              border: new Border.all(
                                  width: 1.0,
                                  color: Color.fromARGB(255, 247, 247, 247)),
                              borderRadius: Radii.k8pxRadius,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Text(
                          "Additional Images (Optional)",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: AppColors.primaryText,
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        height: 120,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                left: 20,
                              ),
                              child: InkWell(
                                onTap: () {
                                  print('add photo');
                                },
                                child: Container(
                                  height: 120.0,
                                  width: 120,
                                  child: Icon(Icons.photo_camera),
                                  decoration: new BoxDecoration(
                                    color: Color.fromARGB(255, 247, 247, 247),
                                    border: new Border.all(
                                        width: 1.0,
                                        color:
                                            Color.fromARGB(255, 247, 247, 247)),
                                    borderRadius: Radii.k8pxRadius,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                left: 20,
                              ),
                              child: InkWell(
                                onTap: () {
                                  print('add photo');
                                },
                                child: Container(
                                  height: 120.0,
                                  width: 120,
                                  child: Icon(Icons.photo_camera),
                                  decoration: new BoxDecoration(
                                    color: Color.fromARGB(255, 247, 247, 247),
                                    border: new Border.all(
                                        width: 1.0,
                                        color:
                                            Color.fromARGB(255, 247, 247, 247)),
                                    borderRadius: Radii.k8pxRadius,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                left: 20,
                              ),
                              child: InkWell(
                                onTap: () {
                                  print('add photo');
                                },
                                child: Container(
                                  height: 120.0,
                                  width: 120,
                                  child: Icon(Icons.photo_camera),
                                  decoration: new BoxDecoration(
                                    color: Color.fromARGB(255, 247, 247, 247),
                                    border: new Border.all(
                                        width: 1.0,
                                        color:
                                            Color.fromARGB(255, 247, 247, 247)),
                                    borderRadius: Radii.k8pxRadius,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                left: 20,
                              ),
                              child: InkWell(
                                onTap: () {
                                  print('add photo');
                                },
                                child: Container(
                                  height: 120.0,
                                  width: 120,
                                  child: Icon(Icons.photo_camera),
                                  decoration: new BoxDecoration(
                                    color: Color.fromARGB(255, 247, 247, 247),
                                    border: new Border.all(
                                        width: 1.0,
                                        color:
                                            Color.fromARGB(255, 247, 247, 247)),
                                    borderRadius: Radii.k8pxRadius,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                left: 20,
                              ),
                              child: InkWell(
                                onTap: () {
                                  print('add photo');
                                },
                                child: Container(
                                  height: 120.0,
                                  width: 120,
                                  child: Icon(Icons.photo_camera),
                                  decoration: new BoxDecoration(
                                    color: Color.fromARGB(255, 247, 247, 247),
                                    border: new Border.all(
                                        width: 1.0,
                                        color:
                                            Color.fromARGB(255, 247, 247, 247)),
                                    borderRadius: Radii.k8pxRadius,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: InkWell(
                          onTap: () {
                            print("tapped on container");
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
