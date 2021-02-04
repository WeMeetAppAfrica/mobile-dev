import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:wemeet/models/app.dart';
import 'package:wemeet/models/user.dart';

class ChatPage extends StatefulWidget {

  final String uid;
  const ChatPage({Key key, this.uid}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  String uid;
  AppModel model;
  UserModel user;

  @override
  void initState() { 
    super.initState();
    
    uid = widget.uid;

    getUid(true);
    fetchChats(true);
  }

  void fetchChats([bool delay = false]) async {
    if(delay) {
      await Future.delayed(Duration(milliseconds: 200));
    }

    getUid(); 
  }

  void getUid([bool delay = false]) async {
    if(!uid.contains("_")) return;
    if(delay) {
      await Future.delayed(Duration(milliseconds: 100));
    }
    List uL = uid.split("_");
    setState(() {
      uid = (uL.first == user.id) ? "uL.last" : uL.first;
    });
  }

  Widget buildAppBar() {
    print(uid);
    Map u = model.matchList["$uid"] ?? {};
    print(u);
    return AppBar(
      centerTitle: false,
      elevation: 1.0,
      title: Wrap(
        spacing: 10.0,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(u["image"]),
            radius: 17.0,
          ),
          Text(
            u["name"] ?? "User",
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w400,
              fontSize: 16.0
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return ScopedModelDescendant<AppModel>(
      builder: (context, child, m) {
        model = m;
        user = model.user;

        return Scaffold(
          appBar: buildAppBar(),
        );
      },
    );
  }
}