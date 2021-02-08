import 'package:flutter/material.dart';

import 'package:wemeet/models/app.dart';

class BlockedUsersPage extends StatefulWidget {

  final AppModel model;
  const BlockedUsersPage({Key key, this.model}) : super(key: key);

  @override
  _BlockedUsersPageState createState() => _BlockedUsersPageState();
}

class _BlockedUsersPageState extends State<BlockedUsersPage> {

  @override
  void initState() { 
    super.initState();
    
    fetchData();
  }

  void fetchData() async {

  }

  void updateDatabase() {
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
    );
  }
}