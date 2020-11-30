import 'dart:convert';

import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wemeet/src/blocs/bloc.dart';
import 'package:wemeet/src/chat/Global.dart';
import 'package:wemeet/src/models/MessageModel.dart';
import 'package:wemeet/src/resources/api_response.dart';
import 'package:wemeet/values/values.dart';

class ChatView extends StatefulWidget {
  final String token;
  final String peerId;
  final String peerName;
  final String peerAvatar;
  ChatView(
      {Key key,
      this.token,
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

  readLocal() async {
    prefs = await SharedPreferences.getInstance();
    id = prefs.getString('id') ?? '';
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

  @override
  void saveObject(String userId, String peerId, object) async {
    final prefs = await SharedPreferences.getInstance();
    // 1
    final string = JsonEncoder().convert(object);
    // 2
    print('string');
    print(string);
    await prefs.setString(_generateKey(userId, peerId), string);
  }

  @override
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

  @override
  Future<void> removeObject(String userId, String peerId) async {
    final prefs = await SharedPreferences.getInstance();
    // 5
    prefs.remove(_generateKey(userId, peerId));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readLocal();
    G.socketUtils.joinRoom('52_22');
    G.socketUtils.setOnChatMessageReceivedListener(onMessageReceived);
    bloc.getMessages(widget.peerId, widget.token);
  }

  onMessageReceived(data) {
    var message = Message.fromJson(data['message']);
    bloc.messageSink
        .add(ApiResponse.addMessage(JsonEncoder().convert(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(FeatherIcons.chevronLeft),
          color: AppColors.accentText,
          onPressed: () => Navigator.pop(context),
        ),
        iconTheme: new IconThemeData(color: AppColors.primaryText),
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.peerAvatar != null
                  ? NetworkImage(widget.peerAvatar)
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
                  color: Color.fromRGBO(228, 228, 228, 1.0),
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
                  color: AppColors.primaryElement,
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
