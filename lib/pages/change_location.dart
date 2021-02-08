import 'package:flutter/material.dart';

import 'package:wemeet/models/app.dart';
import 'package:wemeet/models/user.dart';

class ChangeLocationPage extends StatefulWidget {

  final AppModel model;
  const ChangeLocationPage({Key key, this.model}) : super(key: key);

  @override
  _ChangeLocationPageState createState() => _ChangeLocationPageState();
}

class _ChangeLocationPageState extends State<ChangeLocationPage> {

  AppModel model;
  UserModel user;

  @override
  void initState() { 
    super.initState();
    
    model = widget.model;
    user = model.user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
    );
  }
}