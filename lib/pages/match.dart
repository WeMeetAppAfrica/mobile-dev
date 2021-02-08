import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:wemeet/components/media_player.dart';

class MatchPage extends StatefulWidget {
  @override
  _MatchPageState createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {

  Widget buildBody() {
    return Column(
      children: [
        Expanded(child: Container(),),
        WMEdiaPlayer()
      ],
    );
  }


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
      body: buildBody(),
    );
  }
}