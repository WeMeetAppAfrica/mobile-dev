import 'package:flutter/material.dart';

import 'package:wemeet/models/app.dart';
import 'package:wemeet/models/user.dart';
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

    if(model.token == null || model.token.isEmpty) {
      // // if first launch got to walkthrough
      // if (model.firstLaunch == "yes") {
      //   model.setFirstLaunch("no");
      //   routeTo("/on-boarding");
      //   return;
      // }

      // routeTo("/login");
      routeTo("/on-boarding");
      return;
    }

  }

  void routeTo(String route, [bool delay = true]) async {
    if (delay) {
      await Future.delayed(Duration(seconds: 2));
    }
    Navigator.of(context).pushNamedAndRemoveUntil(route, (route) => false);
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