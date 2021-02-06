import 'package:flutter/material.dart';

import 'package:wemeet/models/app.dart';

class CompleteProfilePage extends StatefulWidget {

  final AppModel model;
  const CompleteProfilePage({Key key, this.model}) : super(key: key);

  @override
  _CompleteProfilePageState createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {

  AppModel model;

  @override
  void initState() { 
    super.initState();
    model = widget.model;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
    );
  }
}