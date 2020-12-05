import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';

import 'package:wemeet/models/app.dart';
import 'package:wemeet/models/chat.dart';
import 'package:wemeet/models/user.dart';

import 'package:wemeet/services/message.dart';
import 'package:wemeet/services/match.dart';
import 'package:wemeet/services/socket.dart';
import 'package:wemeet/providers/data.dart';
import 'package:wemeet/src/views/dashboard/chat-page.dart';
import 'package:wemeet/utils/utils.dart';

import 'package:wemeet/values/colors.dart';

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

  SocketService socketService = SocketService();
  DataProvider _dataProvider = DataProvider();

  StreamSubscription<ChatModel> onChatMessage;
  StreamSubscription<String> onRoom;

  AppModel model;
  UserModel user;

  @override
  void initState() { 
    super.initState();
    
    model = widget.model;
    user = model.user;

    onChatMessage = socketService?.onChatReceived?.listen(onChatReceive);
    onRoom = socketService?.onRoomChanged?.listen(onRoomChanged);

    fetchChats();
  }

  @override
  void dispose() {
    onChatMessage?.cancel();
    onRoom?.cancel();
    super.dispose();
  }

  void fetchChats() async {

    setState(() {
      isLoading = true;
      errorText = null;
    });

    try {
      var res = await MessageService.getChats();
      List data = res["data"]["messages"];
      setState(() {
        items = data.map((e) => ChatModel.fromMap(e)).toList();
      });
      _prepareChatList();

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

  void getMatch(int id) {
    if(id == user.id) {
      return;
    }

    if(model.matchList.containsKey("$id")) {
      return;
    }

    MatchService.getMatches().then((res){
      List data = res["data"]["content"] as List;

      Map mtL = model.matchList ?? {};
      Map matches = {};

      data.map((e) => UserModel.fromMap(e)).toList().forEach((u) {
        matches["${u.id}"] = {"name": u.fullName, "image": u.profileImage};
      });

      mtL.addAll(matches);

      model.setMatchList(mtL);
    });
  }

  void _prepareChatList() {

    Map cL = model.chatList ?? {};

    items.forEach((e) { 
      if(!cL.containsKey(e.chatId)) {
        cL[e.chatId] = 0;
      }
    });

    model.setChatList(cL);
  }

  void onRoomChanged(String roomId) {
    if (!mounted || roomId == null) {
      return;
    }

    int index = items.indexWhere((el) {
      // if chatId matches
      if (roomId == el.chatId) {
        return true;
      }

      return false;
    });

    if (index >= 0) {
      Map cL = model.chatList;
      cL[roomId] = items[index].timestamp;
      setState(() {
        items[index].withBubble = false;
      });
      model.setChatList(cL);
    }
  }

  void onChatReceive(ChatModel chat) {
    if (!mounted) {
      return;
    }

    int i = items.indexWhere((el) => el.chatId == chat.chatId);

    setState(() {
      if (i >= 0) {
        items[i] = chat;
      } else {
        items.add(chat);
      }
    });

    // update chatList if in the same room
    if(chat.chatId == socketService.room) {
      Map cL = model.chatList;
      cL[chat.chatId] = chat.timestamp;
    }

    // check if user is a match
    getMatch(chat.senderId == user.id ? chat.receiverId : chat.senderId);
  }

  List<ChatModel> get chats {

    if(items.isEmpty) {
      return [];
    }

    Map mcL = model.chatList ?? {};
    Map mtL = model.matchList ?? {};
    List<ChatModel> i = items;

    i.forEach((el) { 

      int u = (el.senderId == user.id) ? el.receiverId : el.senderId;

      // get the matches
      if(mtL.containsKey(u.toString())) {
        el.avatar = mtL["$u"]["image"];
        el.name = mtL["$u"]["name"];
      }

      // make sure there is no bubble if user sent the last message
      if(el.senderId == user.id) {
        el.withBubble = false;
        return;
      }

      // check if key is present
      if(mcL.containsKey(el.chatId)){
        el.withBubble = el.timestamp > mcL[el.chatId];
      }

    });

    i.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    i.retainWhere((e) => e.avatar != null);

    return i;
  }

  Widget buildList() {

    return ScopedModelDescendant<AppModel>(
      builder: (context, child, m) {
        model = m;

        return ListView.separated(
          itemBuilder: (context, index) {

            ChatModel item = chats[index]; 

            return ListTile(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ChatView(
                    peerAvatar: item.avatar,
                    peerId: item.senderId == user.id ? "${item.receiverId}" : "${item.senderId}",
                    chatId: item.chatId,
                    apiToken: _dataProvider.token,
                    peerName: item.name,
                    token: _dataProvider.messageToken,
                  ))
                );
              },
              leading: CircleAvatar(
                radius: 30.0,
                backgroundImage:CachedNetworkImageProvider(item.avatar),
              ),
              title: Text("${item.name}"),
              subtitle: Text(
                (item.type == "MEDIA")
                    ? "audio..."
                    : item.content,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontStyle: (item.type == "MEDIA")
                      ? FontStyle.italic
                      : FontStyle.normal),
              ),
              trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${item.fDate}",
                    style: TextStyle(fontSize: 11.0),
                  ),
                  item.withBubble
                      ? Container(
                          width: 10.0,
                          height: 10.0,
                          margin: EdgeInsets.only(
                              top: 10.0),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors
                                  .secondaryElement),
                        )
                      : null,
              ].where((e) => e != null).toList(),
              )
            );
          },
          separatorBuilder: (context, index) {
            return Divider(indent: 80.0,);
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