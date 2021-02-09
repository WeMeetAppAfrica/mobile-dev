import 'package:flutter/material.dart';

import 'package:wemeet/models/user.dart';

class UserDetailsPage extends StatefulWidget {

  final UserModel user;
  final ValueChanged<bool> onSwipe;

  const UserDetailsPage({Key key, this.user, this.onSwipe}) : super(key: key);

  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
    );
  }
}