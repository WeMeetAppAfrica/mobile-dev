import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:wemeet/components/wide_button.dart';

import 'package:wemeet/models/app.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  AppModel model;

  Widget buildBody() {
    return ListView(
      children: [
        WWideButton(
          title: "Logout",
          onTap: (){
            Navigator.of(context).pushNamedAndRemoveUntil("/login", (route) => false);
            model.logOut();
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    return ScopedModelDescendant<AppModel>(
      builder: (context, child, m) {
        model = m;

        return Scaffold(
          appBar: AppBar(
            title: Text("Settings"),
          ),
          body: buildBody(),
        );
      },
    );  
  }
}