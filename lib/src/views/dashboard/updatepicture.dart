import 'dart:convert';
import 'dart:io';

import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wemeet/src/blocs/bloc.dart';
import 'package:wemeet/src/resources/api_response.dart';
import 'package:wemeet/src/views/auth/kyc.dart';
import 'package:wemeet/src/views/auth/login.dart';
import 'package:wemeet/src/views/dashboard/home.dart';
import 'package:wemeet/src/views/dashboard/messages.dart';
import 'package:wemeet/src/views/dashboard/profile.dart';
import 'package:wemeet/values/values.dart';

class UpdatePhotos extends StatefulWidget {
  UpdatePhotos({Key key}) : super(key: key);

  @override
  _UpdatePhotosState createState() => _UpdatePhotosState();
}

class _UpdatePhotosState extends State<UpdatePhotos> {
  bool _isChecked = true;
  List<RadioModel> gender = new List<RadioModel>();
  List<RadioModel> interest = new List<RadioModel>();
  List<RadioModel> employStatus = new List<RadioModel>();
  String proImage;
  String addImage1;
  String addImage2;
  String error;
  String token;
  String addImage3;
  dynamic profile;
  String addImage4;
  String addImage5;
  PickedFile _picture0;
  PickedFile _picture1;
  List _tray = [];
  final ImagePicker _picker = ImagePicker();
  dynamic _pickImageError;

  File _image;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      _image = File(pickedFile.path);
    });
  }

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('accessToken');
    bloc.getProfile(token);
  }

  void _onImageButtonPressed(ImageSource source, picture) async {
    try {
      final pickedFile = await _picker.getImage(
        source: source,
      );
      switch (picture) {
        case 'picture0':
          setState(() {
            _picture0 = pickedFile;
            profile.profileImage = null;
          });
          print(_picture0.path);
          bloc.uploadProPhoto(_picture0.path, token);
          break;
        case 'picture1':
          setState(() {
            _tray.add({
              'file': pickedFile,
              'status': 'pending',
            });
          });

          bloc.uploadAddPhoto(
              pickedFile.path, token, (_tray.length - 1).toString());
          break;
      }
    } catch (e) {
      setState(() {
        _pickImageError = e;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    void _showPicker(context, picture) {
      showModalBottomSheet(
          context: context,
          builder: (BuildContext bc) {
            return SafeArea(
              child: Container(
                child: new Wrap(
                  children: <Widget>[
                    new ListTile(
                        leading: new Icon(Icons.photo_library),
                        title: new Text('Photo Library'),
                        onTap: () {
                          _onImageButtonPressed(ImageSource.gallery, picture);
                          Navigator.of(context).pop();
                        }),
                    new ListTile(
                      leading: new Icon(Icons.photo_camera),
                      title: new Text('Camera'),
                      onTap: () {
                        _onImageButtonPressed(ImageSource.camera, picture);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            );
          });
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: new IconThemeData(color: AppColors.primaryText),
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: Text(
          'Update Photos',
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
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 255, 255, 255),
        ),
        child: Container(
          height: MediaQuery.of(context).size.height - 165,
          child: StreamBuilder(
              stream: bloc.profileStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  switch (snapshot.data.status) {
                    case Status.LOADING:
                      return Center(child: CircularProgressIndicator());
                      break;
                    case Status.ERROR:
                      try {
                        error = json.decode(snapshot.data.message)['message'];
                      } on FormatException {
                        error = snapshot.data.message;
                      }
                      Fluttertoast.showToast(msg: error);
                      break;
                    case Status.GETPROFILE:
                      bloc.profileSink.add(ApiResponse.idle('message'));
                      profile = snapshot.data.data.data;
                      proImage = profile.profileImage;
                      profile.additionalImages.forEach((element) => {
                            print(element),
                            _tray.add({
                              'url': element,
                              'status': 'done',
                            })
                          });
                      break;
                    case Status.DONE:
                      bloc.profileSink.add(ApiResponse.idle('message'));
                      // _setPassKYC();
                      Fluttertoast.showToast(msg: 'Photos Updated');
                      myCallback(() {
                        Navigator.pop(context);
                      });
                      // myCallback(() {
                      //   Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //       builder: (context) => Messages(),
                      //     ),
                      //   );
                      // });
                      break;
                    default:
                  }
                }
                return profile != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          error != null
                              ? Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Text(
                                      error,
                                      style: TextStyle(
                                        color: AppColors.secondaryElement,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                )
                              : Container(),
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
                                _showPicker(context, 'picture0');
                              },
                              child: profile.profileImage == null
                                  ? _picture0 == null
                                      ? Container(
                                          height: 120.0,
                                          width: 120,
                                          child: Icon(Icons.photo_camera),
                                          decoration: new BoxDecoration(
                                            color: Color.fromARGB(
                                                255, 247, 247, 247),
                                            border: new Border.all(
                                                width: 1.0,
                                                color: Color.fromARGB(
                                                    255, 247, 247, 247)),
                                            borderRadius: Radii.k8pxRadius,
                                          ),
                                        )
                                      : StreamBuilder(
                                          stream: bloc.uploadStream,
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              switch (snapshot.data.status) {
                                                case Status
                                                    .PROIMAGELOADING:
                                                  return Stack(
                                                    children: [
                                                      Container(
                                                        height: 120.0,
                                                        width: 120,
                                                        child: Image(
                                                          image: FileImage(File(
                                                              _picture0.path)),
                                                          fit: BoxFit.cover,
                                                        ),
                                                        decoration:
                                                            new BoxDecoration(
                                                          color: Color.fromARGB(
                                                              255,
                                                              247,
                                                              247,
                                                              247),
                                                          border:
                                                              new Border.all(
                                                                  width: 1.0,
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          247,
                                                                          247,
                                                                          247)),
                                                          borderRadius:
                                                              Radii.k8pxRadius,
                                                        ),
                                                      ),
                                                      Container(
                                                        height: 120.0,
                                                        width: 120,
                                                        child: Center(
                                                            child:
                                                                CircularProgressIndicator()),
                                                        color: Color.fromRGBO(
                                                            255, 255, 255, 0.6),
                                                      ),
                                                    ],
                                                  );
                                                  break;
                                                case Status.ERROR:
                                                  try {
                                                    error = json.decode(snapshot
                                                        .data
                                                        .message)['message'];
                                                  } on FormatException {
                                                    error =
                                                        snapshot.data.message;
                                                  }
                                                  myCallback(() {
                                                    _picture0 = null;
                                                  });
                                                  bloc.uploadSink.add(
                                                      ApiResponse.idle(
                                                          'message'));
                                                  break;
                                                case Status.PROIMAGEDONE:
                                                  proImage = snapshot
                                                      .data.data.data.imageUrl;
                                                  return Container(
                                                    height: 120.0,
                                                    width: 120,
                                                    child: Image(
                                                      image: FileImage(
                                                          File(_picture0.path)),
                                                      fit: BoxFit.cover,
                                                    ),
                                                    decoration:
                                                        new BoxDecoration(
                                                      color: Color.fromARGB(
                                                          255, 247, 247, 247),
                                                      border: new Border.all(
                                                          width: 1.0,
                                                          color: Color.fromARGB(
                                                              255,
                                                              247,
                                                              247,
                                                              247)),
                                                      borderRadius:
                                                          Radii.k8pxRadius,
                                                    ),
                                                  );
                                                  break;
                                                default:
                                              }
                                            }
                                            return profile.profileImage == null
                                                ? Container(
                                                    height: 120.0,
                                                    width: 120,
                                                    child: Icon(
                                                        Icons.photo_camera),
                                                    decoration:
                                                        new BoxDecoration(
                                                      color: Color.fromARGB(
                                                          255, 247, 247, 247),
                                                      border: new Border.all(
                                                          width: 1.0,
                                                          color: Color.fromARGB(
                                                              255,
                                                              247,
                                                              247,
                                                              247)),
                                                      borderRadius:
                                                          Radii.k8pxRadius,
                                                    ),
                                                  )
                                                : Container(
                                                    height: 120.0,
                                                    width: 120,
                                                    child: Image(
                                                      image: NetworkImage(
                                                          profile.profileImage),
                                                      fit: BoxFit.cover,
                                                    ),
                                                    decoration:
                                                        new BoxDecoration(
                                                      color: Color.fromARGB(
                                                          255, 247, 247, 247),
                                                      border: new Border.all(
                                                          width: 1.0,
                                                          color: Color.fromARGB(
                                                              255,
                                                              247,
                                                              247,
                                                              247)),
                                                      borderRadius:
                                                          Radii.k8pxRadius,
                                                    ),
                                                  );
                                          })
                                  : Container(
                                      height: 120.0,
                                      width: 120,
                                      child: Image(
                                        image:
                                            NetworkImage(profile.profileImage),
                                        fit: BoxFit.cover,
                                      ),
                                      decoration: new BoxDecoration(
                                        color:
                                            Color.fromARGB(255, 247, 247, 247),
                                        border: new Border.all(
                                            width: 1.0,
                                            color: Color.fromARGB(
                                                255, 247, 247, 247)),
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
                            height: 150,
                            child: StreamBuilder(
                                stream: bloc.uploadStream,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    switch (snapshot.data.status) {
                                      case Status.ADDIMAGELOADING:
                                        print('index ${snapshot.data.message}');
                                        _tray[int.parse(snapshot.data.message)]
                                            ['status'] = 'loading';
                                        break;
                                      case Status.ADDIMAGEDONE:
                                        bloc.uploadSink
                                            .add(ApiResponse.idle('message'));
                                        print('index ${snapshot.data.message}');
                                        _tray[int.parse(snapshot.data.message)]
                                            ['status'] = 'done';
                                        _tray[int.parse(snapshot.data.message)]
                                                ['url'] =
                                            snapshot.data.data.data.imageUrl;
                                        break;
                                      default:
                                    }
                                  }
                                  return ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    padding: EdgeInsets.only(left: 20),
                                    itemCount: _tray.length + 1,
                                    itemBuilder: (context, index) {
                                      // checking if the index item is the last item of the list or not
                                      if (index == _tray.length) {
                                        return Padding(
                                          padding: EdgeInsets.only(right: 20),
                                          child: InkWell(
                                              onTap: () {
                                                print('add photo');
                                                _showPicker(
                                                    context, 'picture1');
                                              },
                                              child: Container(
                                                height: 120.0,
                                                width: 120,
                                                margin: EdgeInsets.only(
                                                    right: 10,
                                                    top: 10,
                                                    bottom: 10),
                                                child: Icon(Icons.photo_camera),
                                                decoration: new BoxDecoration(
                                                  color: Color.fromARGB(
                                                      255, 247, 247, 247),
                                                  border: new Border.all(
                                                      width: 1.0,
                                                      color: Color.fromARGB(
                                                          255, 247, 247, 247)),
                                                  borderRadius:
                                                      Radii.k8pxRadius,
                                                ),
                                              )),
                                        );
                                      }

                                      return Stack(
                                        children: [
                                          Container(
                                            margin: EdgeInsets.only(
                                                right: 10, top: 10),
                                            height: 120.0,
                                            width: 120,
                                            child: Image(
                                              image: _tray[index]['status'] !=
                                                      'done'
                                                  ? FileImage(File(_tray[index]
                                                          ['file']
                                                      .path))
                                                  : NetworkImage(
                                                      _tray[index]['url']),
                                              fit: BoxFit.cover,
                                            ),
                                            decoration: new BoxDecoration(
                                              color: Color.fromARGB(
                                                  255, 247, 247, 247),
                                              border: new Border.all(
                                                  width: 1.0,
                                                  color: Color.fromARGB(
                                                      255, 247, 247, 247)),
                                              borderRadius: Radii.k8pxRadius,
                                            ),
                                          ),
                                          _tray[index]['status'] == 'loading'
                                              ? Container(
                                                  height: 130.0,
                                                  width: 120,
                                                  child: Center(
                                                      child:
                                                          CircularProgressIndicator()),
                                                  color: Color.fromRGBO(
                                                      255, 255, 255, 0.6),
                                                )
                                              : Container(),
                                          _tray[index]['status'] == 'done'
                                              ? Positioned(
                                                  right: -20,
                                                  top: -5,
                                                  child: RawMaterialButton(
                                                    onPressed: () {
                                                      print('remove $index');
                                                      setState(() {
                                                        _tray.removeAt(index);
                                                      });
                                                    },
                                                    elevation: 2.0,
                                                    fillColor: AppColors
                                                        .secondaryElement,
                                                    child: Icon(
                                                      FeatherIcons.x,
                                                      color: AppColors
                                                          .secondaryText,
                                                    ),
                                                    shape: CircleBorder(),
                                                  ),
                                                )
                                              : Container(),
                                        ],
                                      );
                                    },
                                  );
                                }),
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Align(
                            alignment: Alignment.topCenter,
                            child: InkWell(
                              onTap: () {
                                // bloc.uploadPhoto(_picture0.path, 'PROFILE_IMAGE', token);

                                if (proImage != null) {
                                  print("tapped on container");

                                  var additionalImages = [];
                                  _tray.forEach((element) {
                                    additionalImages.add(element['url']);
                                  });
                                  var data = {
                                    "profileImage": proImage,
                                    "additionalImages": additionalImages,
                                  };
                                  // print(data);
                                  bloc.updateProfileImage(data, token);
                                } else {
                                  bloc.profileSink.add(ApiResponse.error(
                                      'Profile picture must be uploaded.'));
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
                      )
                    : Center(child: CircularProgressIndicator());
              }),
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

void myCallback(Function callback) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    callback();
  });
}
