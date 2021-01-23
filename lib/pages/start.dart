import 'package:flutter/material.dart';

import 'package:wemeet/models/app.dart';
import 'package:wemeet/models/user.dart';

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




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
    );
  }
}