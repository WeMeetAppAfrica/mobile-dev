import 'package:flutter/material.dart';
import 'dart:io';
import 'package:device_info/device_info.dart';

import 'package:wemeet/models/app.dart';
import 'package:wemeet/models/user.dart';
import 'package:wemeet/providers/data.dart';
import 'package:wemeet/utils/colors.dart';

class StartPage extends StatefulWidget {

  final AppModel model;
  const StartPage({Key key, this.model}) : super(key: key);


  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {

  bool isLoading = false;

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
      isLoading = false;      
    });

    // Get device id
    getDeviceId();

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

  void fetchProfile() {

  }

  Widget buildBody() {
    return Container();
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