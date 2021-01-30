import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        actions: [
          IconButton(
            icon: Icon(Ionicons.cog_outline),
            onPressed: (){
              Navigator.pushNamed(context, "/settings");
            }
          )
        ],
      ),
    );
  }
}