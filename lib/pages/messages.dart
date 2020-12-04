import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';

import 'package:wemeet/models/app.dart';
import 'package:wemeet/models/chat.dart';

import 'package:wemeet/services/message.dart';
import 'package:wemeet/src/views/dashboard/profile.dart';
import 'package:wemeet/utils/utils.dart';

import 'package:wemeet/components/error.dart';

class MessagesPage extends StatefulWidget {

  final AppModel model;

  const MessagesPage({Key key, this.model}) : super(key: key);

  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {

  bool isLoading = false;
  bool isError = false;
  String errorText;
  List<ChatModel> items = [];

  AppModel model;

  @override
  void initState() { 
    super.initState();
    
    model = widget.model;

    fetchChats();
  }

  void fetchChats() async {

    setState(() {
      isLoading = true;
      errorText = null;
    });

    try {
      var res = await MessageService.getChats();
      print(res);
      List data = res["data"]["messages"];
      setState(() {
        items = data.map((e) => ChatModel.fromMap(e));
      });

    } catch (e) {
      print(e);
      String err = kTranslateError(e);
      if(!err.toLowerCase().contains("token")) {
        setState(() {
          errorText = "Could not fetch chats";
        });
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<ChatModel> get chats {
    return items;
  }

  Widget buildList() {

    return ScopedModelDescendant<AppModel>(
      builder: (context, child, m) {
        return ListView.separated(
          itemBuilder: (context, index) {
            return ListTile();
          },
          separatorBuilder: (context, index) {
            return Divider(indent: 30.0,);
          },
          itemCount: chats.length,
        );
      }
    );    
  }

  Widget buildBody() {
    if(isLoading && chats.isEmpty) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if(isError && chats.isEmpty) {
      return ErrorComponent(text: errorText, callback: fetchChats,);
    }

    if(chats.isEmpty) {

      return Center(
        child: Icon(FeatherIcons.messageSquare, size: 60.0, color: Colors.black38),
      );
    }

    return buildList();
  }

  Widget buildMatches() {
    return ScopedModelDescendant<AppModel>(
      builder: (context, child, m) {

        List i = [];
        m.matchList.forEach((key, value){
          i.add({"id": key, "name": value["name"], "image": value["image"]});
        });

        return Column(
          children: i.map((e) {
            return Text(e["name"]);
          }).toList(),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Messages")
      ),
      backgroundColor: Colors.white,
      body: buildBody(),
    );
  }
}