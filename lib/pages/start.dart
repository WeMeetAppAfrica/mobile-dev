import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:device_info/device_info.dart';
import 'package:location_permissions/location_permissions.dart' as ph;
import 'package:location/location.dart';
import 'dart:io';


import 'package:wemeet/models/app.dart';
import 'package:wemeet/models/user.dart';
import 'package:wemeet/providers/data.dart';
import 'package:wemeet/services/push.dart';
import 'package:wemeet/services/user.dart';

import 'package:wemeet/components/loader.dart';

import 'package:wemeet/utils/colors.dart';
import 'package:wemeet/utils/errors.dart';
import 'package:wemeet/utils/toast.dart';
import 'package:wemeet/utils/svg_content.dart';

class StartPage extends StatefulWidget {

  final AppModel model;
  const StartPage({Key key, this.model}) : super(key: key);


  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {

  bool isLoading = false;
  String errorText;

  Location location = Location();

  AppModel model;
  UserModel user;

  @override
  void initState() { 
    super.initState();
    
    model = widget.model;
    user = model?.user;

    created();

  }

  void created() async {

    setState(() {
      isLoading = true;  
      errorText = null;    
    });

    // Get device id
    getDeviceId();

    // Configure Push
    PushService().configure(model);

    // get location
    getLocation();

    if(model.token == null || model.token.isEmpty) {
      // if first launch got to walkthrough
      if (model.firstLaunch == "yes") {
        model.setFirstLaunch("no");
        routeTo("/on-boarding");
        return;
      }

      routeTo("/login");
      return;
    }

    fetchProfile();
    return;

  }

  void routeTo(String route, [bool delay = true]) async {
    if (delay) {
      await Future.delayed(Duration(seconds: 2));
    }
    Navigator.of(context).pushNamedAndRemoveUntil(route, (route) => false);
  }

  void getDeviceId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      // import 'dart:io'
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      DataProvider().setDeviceId(iosDeviceInfo.identifierForVendor);
    } else {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
      DataProvider().setDeviceId(androidDeviceInfo.androidId);
    }
  }

  void getLocation() async {
    // Check permission
    PermissionStatus ps = await location.requestPermission();

    if(ps != PermissionStatus.granted) {
      WeMeetToast.toast("Location persmission is required");
      await Future.delayed(Duration(seconds: 1));
      await ph.LocationPermissions().openAppSettings();

      // Start the app again

      return;
    }

    setLocation(ps);
  }

  void setLocation(PermissionStatus status) async {
    if(status == PermissionStatus.granted) {
      location.getLocation().then((val) {
        DataProvider().setLocation(val);
      });
    }
  }

  void fetchProfile() {

    setState(() {
      isLoading = true;
      errorText = null;      
    });
    UserService.getProfile().then((res){
      Map data = res["data"] as Map;
      model.setUserMap(data);
      user = UserModel.fromMap(data);

      // if user has not activated account
      if (!user.active) {
        routeTo("/activate");
        return;
      }

      // if user has not completed profile
      if (user.profileImage == null) {
        routeTo("/complete-profile");
        return;
      }

      routeTo("/home");
      return;

    }).catchError((e){
      String err = kTranslateError(e);
      WeMeetToast.toast(err, true);
      if(err.contains("session has expired")) {
        routeTo("/login");
        return;
      } else {
        setState(() {
          errorText = err;          
        });
      }

    }).whenComplete((){
      setState((){
        isLoading = false;
      });
    });
  }

  Widget buildBody() {

    if(isLoading) {
      return WeMeetLoader.showBusyLoader();
    }

    // TODO Handle error
    if(errorText != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.string(WemeetSvgContent.logoWY),
            SizedBox(height: 30.0),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
              child: Text(
                errorText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white
                ),
              ),
            ),
            FlatButton(
              onPressed: fetchProfile,
              child: Text("Try again"),
              textColor: Colors.yellowAccent,
            )
          ],
        ),
      );
    }

    return Center(
      child: SvgPicture.string(WemeetSvgContent.logoWY),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: AppColors.color1
        ),
        child: buildBody(),
      ),
    );
  }
}