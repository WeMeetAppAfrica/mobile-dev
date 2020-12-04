
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:wemeet/models/app.dart';
import 'package:wemeet/models/user.dart';

class StartPage extends StatefulWidget {

  final AppModel model;
  const StartPage({Key key, this.model}) : super(key: key);

  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {

  final firebaseMessaging = FirebaseMessaging();
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  bool isLoading = false;

  AppModel model;
  UserModel user;

  @override
  void initState() { 
    super.initState();

    model = widget.model;
    user = model.user;

    created();
    
  }

  void created() async {

    // if there is no token go to login
    if(model.token == null || model.token.isEmpty) {
      routeTo("/login");
      return;
    }

  }

  void routeTo(String route, [bool delay = false]) async {

    if(delay) {
      await Future.delayed(Duration(seconds: 1));
    }

    Navigator.of(context).pushNamedAndRemoveUntil(route, (route) => false);
  }

  Widget buildBody() {

    if(isLoading) {
      return Center(
        child: SizedBox(
          width: 25.0,
          height: 25.0,
          child: CircularProgressIndicator(strokeWidth: 2.0,)
        ),
      );
    }

    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

      ),
      body: buildBody(),
    );
  }
}