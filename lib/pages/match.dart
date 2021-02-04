import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';

class MatchPage extends StatefulWidget {
  @override
  _MatchPageState createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("WeeMeet"),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: (){
              Navigator.pushNamed(context, "/messages");
            },
            icon: Icon(FeatherIcons.messageSquare),
          )
        ],
      ),
    );
  }
}