import 'dart:convert';
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wemeet/src/blocs/bloc.dart';
import 'package:wemeet/src/chat/Global.dart';
import 'package:wemeet/src/models/MessageModel.dart';
import 'package:wemeet/src/resources/api_response.dart';
import 'package:wemeet/values/values.dart';

import 'package:wemeet/services/socket.dart';
import 'package:wemeet/src/models/chat_model.dart';

class ChatView extends StatefulWidget {
  final String token;
  final String peerId;
  final String peerName;
  final String peerAvatar;
  final String chatId;
  ChatView(
      {Key key,
      this.token,
      this.chatId,
      @required this.peerId,
      this.peerName,
      @required this.peerAvatar})
      : super(key: key);

  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  SharedPreferences prefs;
  final TextEditingController inputTextController = TextEditingController();
  List messages = [];
  dynamic id;
  ScrollController _scrollController = new ScrollController();

  SocketService socketService = SocketService();

  StreamSubscription<ChatModel> onChatMessage;
  

  readLocal() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      id = prefs.getString('id') ?? '';
    });
    // id = prefs.getString('id') ?? '';
    var ret = await getObject(id, widget.peerId);
    if (ret != null) messages = ret.messages;
    // removeObject(id, widget.peerId);
    setState(() {});

    print('prin');
    print(messages);
  }

  String _generateKey(String userId, String peerId) {
    if (int.parse(userId) <= int.parse(peerId)) {
      return '$userId/$peerId';
    } else {
      return '$peerId/$userId';
    }
  }

  void saveObject(String userId, String peerId, object) async {
    final prefs = await SharedPreferences.getInstance();
    // 1
    final string = JsonEncoder().convert(object);
    // 2
    print(string);
    await prefs.setString(_generateKey(userId, peerId), string);
  }

  Future<dynamic> getObject(String userId, String peerId) async {
    final prefs = await SharedPreferences.getInstance();
    // 3
    final objectString = prefs.getString(_generateKey(userId, peerId));
    // 4
    if (objectString != null) {
      return Data.fromJson(
          JsonDecoder().convert(objectString) as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> removeObject(String userId, String peerId) async {
    final prefs = await SharedPreferences.getInstance();
    // 5
    prefs.remove(_generateKey(userId, peerId));
  }

  String get chatId {
    List<int> ids = [int.tryParse(widget.peerId ?? "") ?? 0, int.tryParse(id ?? "") ?? 0];
    ids.sort((a, b) => a.compareTo(b));
    return widget.chatId ?? ids.join("_");
  }

  @override
  void initState() {
    super.initState();
    readLocal();
    G.socketUtils.joinRoom('52_22');
    G.socketUtils.setOnChatMessageReceivedListener(onMessageReceived);
    bloc.getMessages(widget.peerId, widget.token);
    onChatMessage = socketService?.onChatReceived?.listen(onChatReceive);
    waitJoinRoom();
  }

  @override
  void dispose() { 
    onChatMessage?.cancel();
    super.dispose();
  }

  onMessageReceived(data) {
    var message = Message.fromJson(data['message']);
    bloc.messageSink
        .add(ApiResponse.addMessage(JsonEncoder().convert(message)));
  }

  void waitJoinRoom() {

  }

  void onChatReceive(ChatModel chat) {

    Message mssg = Message(
      content: chat.content,
      chatId: chat.chatId,
      id: chat.id,
      receiverId: chat.receiverId,
      senderId: chat.senderId,
      sentAt: chat.sentAt,
      status: chat.status,
      type: chat.type
    );

    int i = messages.indexWhere((el) {
      List<String> ci = ["${chat.receiverId}", "${chat.senderId}"];
      List<String> ei = ["${el.receiverId}", "${el.senderId}"];

      ci.sort((a, b) => a.compareTo(b));
      ei.sort((a, b) => a.compareTo(b));

      String cid = ci.join("_");
      String eld = ei.join("_");

      // make sure it is the same chat id
      if(cid != eld) {
        return false;
      }

      // make sure same id doesn't exist
      if(chat.id == el.id || chat.id == null) {
        return false;
      }

      return true;
    });

    // if index is not found
    setState(() {
      if(i >= 0) {
        messages.add(mssg);
      } 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        brightness: Brightness.light,
        leading: IconButton(
          icon: Icon(FeatherIcons.chevronLeft),
          color: AppColors.accentText,
          onPressed: () => Navigator.pop(context),
        ),
        iconTheme: new IconThemeData(color: AppColors.primaryText),
        backgroundColor: Colors.white,
        elevation: 1.0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.peerAvatar != null
                  ? CachedNetworkImageProvider(widget.peerAvatar)
                  : null,
              child: widget.peerAvatar == null ? Text(widget.peerAvatar) : null,
            ),
            SizedBox(
              width: 8,
            ),
            Text(
              widget.peerName,
              style: TextStyle(
                color: AppColors.accentText,
                fontWeight: FontWeight.w400,
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(FeatherIcons.music),
            color: AppColors.accentText,
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(FeatherIcons.flag),
            color: AppColors.accentText,
            onPressed: () {
              // _showBottom(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Flexible(
            child: Container(
                child: StreamBuilder(
                    stream: bloc.messageStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        switch (snapshot.data.status) {
                          case Status.LOADING:
                            if (messages.length < 1) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            } else {
                              if (_scrollController.hasClients)
                                _scrollController.jumpTo(
                                  _scrollController.position.maxScrollExtent,
                                );
                            }

                            break;
                          case Status.ADDMESSAGE:
                            print('snapshot.d');
                            print(Message.fromJson(
                                JsonDecoder().convert(snapshot.data.message)));
                            messages.add(Message.fromJson(
                                JsonDecoder().convert(snapshot.data.message)));
                            if (_scrollController.hasClients)
                              _scrollController.animateTo(
                                _scrollController.position.maxScrollExtent +
                                    100,
                                curve: Curves.easeOut,
                                duration: const Duration(milliseconds: 300),
                              );
                            break;
                          case Status.SENDMESSAGE:
                            bloc.messageSink.add(ApiResponse.idle('message'));
                            messages.add(snapshot.data.data.data.message);
                            if (_scrollController.hasClients)
                              _scrollController.animateTo(
                                _scrollController.position.maxScrollExtent +
                                    100,
                                curve: Curves.easeOut,
                                duration: const Duration(milliseconds: 300),
                              );

                            saveObject(id, widget.peerId,
                                {"messages": messages, "message": null});
                            break;
                          case Status.GETMESSAGES:
                            bloc.messageSink.add(ApiResponse.idle('message'));
                            messages = snapshot.data.data.data.messages;
                            saveObject(
                                id, widget.peerId, snapshot.data.data.data);
                            if (_scrollController.hasClients)
                              _scrollController.animateTo(
                                _scrollController.position.maxScrollExtent,
                                curve: Curves.easeOut,
                                duration: const Duration(milliseconds: 300),
                              );
                            break;
                          default:
                        }
                      }
                      return ListView.builder(
                        itemCount: messages.length,
                        reverse: false,
                        controller: _scrollController,
                        itemBuilder: (context, index) =>
                            buildItem(messages[index]),
                      );
                    })),
          ),
          buildInput()
        ],
      ),
    );
  }

  Widget buildItem(dynamic message) {
    if (message.senderId.toString() == id) {
      // Right (my message)
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              child: Text(
                message.content,
                style: TextStyle(color: AppColors.primaryText),
              ),
              padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
              width: 200.0,
              decoration: BoxDecoration(
                  color: Color.fromRGBO(247, 247, 247, 1.0),
                  borderRadius: BorderRadius.circular(8.0)),
              margin: EdgeInsets.only(bottom: 5.0, right: 10.0, top: 5),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                padding: EdgeInsets.only(right: 20),
                child: Text(
                  message.sentAt.toString(),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      color: AppColors.accentText,
                      fontSize: 12.0,
                      fontStyle: FontStyle.italic),
                ),
                margin: EdgeInsets.only(bottom: 5.0),
              ),
            ),
          ],
        ),
      );
    } else {
      // Left (peer message)
      return Container(
        child: Column(
          children: <Widget>[
            Container(
              child: Text(
                message.content,
                style: TextStyle(color: AppColors.primaryText),
              ),
              padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
              width: 200.0,
              decoration: BoxDecoration(
                  color: Color.fromRGBO(228, 228, 228, 1.0),
                  borderRadius: BorderRadius.circular(8.0)),
              margin: EdgeInsets.only(left: 10.0, top: 5),
            ),

            // Time
            Container(
              child: Text(
                message.sentAt.toString(),
                style: TextStyle(
                    color: AppColors.accentText,
                    fontSize: 12.0,
                    fontStyle: FontStyle.italic),
              ),
              margin: EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),
            )
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }

  void onSendMessage(String content) {
    // type: 0 = text, 1 = image, 2 = sticker
    var request = {
      "content": content.trim(),
      "receiverId": widget.peerId,
      "type": "TEXT"
    };

    inputTextController.clear();
    if (content.trim() != '') {
      bloc.sendMessage(request, widget.token);
      socketService.addChat(ChatModel(
        id: null,
        chatId: chatId,
        content: content.trim(),
        receiverId: int.tryParse(widget.peerId) ?? 999999,
        senderId: int.tryParse(id) ?? 0,
        sentAt: DateTime.now(),
        status: 0,
        type: request["type"]
      ));
    } else {
      print('nothing to send');
      Fluttertoast.showToast(
          msg: 'Nothing to send',
          backgroundColor: Colors.black,
          textColor: Colors.red);
    }
  }

  Widget buildInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              onSubmitted: (value) {
                onSendMessage(inputTextController.text);
              },
              // controller: textEditingController,
              keyboardType: TextInputType.multiline,
              maxLength: 1000,
              minLines: 1,
              controller: inputTextController,
              maxLines: 5,
              decoration: InputDecoration(hintText: 'Say something...'),
            ),
          ),
          IconButton(
            onPressed: () => onSendMessage(inputTextController.text),
            icon: Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}

void myCallback(Function callback) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    callback();
  });
}
