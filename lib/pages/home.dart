import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';

import 'package:wemeet/models/user.dart';
import 'package:wemeet/models/app.dart';

import 'package:wemeet/components/home_drawer.dart';

import 'package:wemeet/src/views/dashboard/messages.dart';

import 'package:wemeet/providers/data.dart';
import 'package:wemeet/services/match.dart';
import 'package:wemeet/services/message.dart';
import 'package:wemeet/services/socket.dart';
import 'package:wemeet/values/values.dart';

class HomePage extends StatefulWidget {
  final AppModel model;
  const HomePage({Key key, this.model}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  AppModel model;
  UserModel user;

  DataProvider _dataProvider = DataProvider();

  @override
  void initState() { 
    super.initState();
    model = widget.model;
    user = model.user;

    setIdentifier();

    // fetch user matches
    updateMatches();

    // get message token
    getMessageToken();

    // initSocket
    initSocket();
  }

  void initSocket() {
    // SocketService()..init();
  }

  void updateMatches() {
    MatchService.getMatches().then((res){
      List data = res["data"]["content"] as List;

      Map matches = {};

      data.map((e) => UserModel.fromMap(e)).toList().forEach((u) {
        matches["${u.id}"] = {"name": u.fullName, "image": u.profileImage};
      });

      model.setMatchList(matches);
    });
  }

  void getMessageToken() {
    MessageService.postLogin().then((res){
      String data = res["data"]["accessToken"] as String;
      print("Message Token: $data");
      model.setMessageToken(data);
    });
  }

  void setIdentifier() {
    FirebaseCrashlytics.instance.setUserIdentifier(_dataProvider.user.id.toString());
  }

  void gotoPage(Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => page)
    );
  }

  void routeTo(String route) {
    Navigator.pushNamed(context, route);
  }

  Widget buildBody() {
    return Center(
      child: Text(model.token),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        brightness: Brightness.light,
        iconTheme: new IconThemeData(color: AppColors.primaryText),
        elevation: 0.0,
        title: Text(
          "Meet Someone",
          style: TextStyle(
            fontFamily: 'Berkshire Swash',
            color: AppColors.primaryText,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              FeatherIcons.messageSquare,
              color: AppColors.primaryText,
            ), 
            onPressed: () => routeTo("/messages")
          )
        ],
      ),
      drawer: HomeDrawer(),
      body: buildBody(),
    );
  }
}