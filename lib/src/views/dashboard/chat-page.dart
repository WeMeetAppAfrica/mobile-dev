import 'dart:convert';
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wemeet/providers/data.dart';
import 'package:wemeet/src/blocs/bloc.dart';
import 'package:wemeet/src/chat/Global.dart';
import 'package:wemeet/src/models/MessageModel.dart';
import 'package:wemeet/src/resources/api_response.dart';
import 'package:wemeet/src/views/dashboard/player_widget.dart';
import 'package:wemeet/src/views/dashboard/share-songs.dart';
import 'package:wemeet/values/values.dart';

import 'package:wemeet/src/views/dashboard/share-songs.dart';

import 'package:wemeet/services/socket.dart';
import 'package:wemeet/src/models/chat_model.dart';

class ChatView extends StatefulWidget {
  final String token;
  final String apiToken;
  final String peerId;
  final String peerName;
  final String peerAvatar;
  final String chatId;
  ChatView(
      {Key key,
      this.token,
      this.apiToken,
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
  String report = 'ABUSIVE';
  dynamic id;

  // ScrollController _scrollController = new ScrollController();
  AutoScrollController _indexScrollController = AutoScrollController(
    axis: Axis.vertical
  );

  SocketService socketService = SocketService();

  StreamSubscription<ChatModel> onChatMessage;
  StreamSubscription chatsSub;

  List<Message> chats;

  readLocal() async {
    prefs = await SharedPreferences.getInstance();
    id = prefs.getString('id') ?? '';

    // id = prefs.getString('id') ?? '';
    var ret = await getObject(id, widget.peerId);
    if (ret != null) messages = ret.messages;
    // removeObject(id, widget.peerId);
    setState(() {});
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
    List<int> ids = [
      int.tryParse(widget.peerId ?? "") ?? 0,
      int.tryParse(id ?? "") ?? 0
    ];
    ids.sort((a, b) => a.compareTo(b));
    return widget.chatId ?? ids.join("_");
  }

  @override
  void initState() {
    super.initState();
    readLocal();
    // G.socketUtils.joinRoom('52_22');
    G.socketUtils.setOnChatMessageReceivedListener(onMessageReceived);
    bloc.getMessages(widget.peerId, widget.token);
    onChatMessage = socketService?.onChatReceived?.listen(onChatReceive);
    waitJoinRoom();

    chatsSub = bloc.messageStream.listen(onMessagesReceived);

  }

  @override
  void dispose() {
    onChatMessage?.cancel();
    chatsSub?.cancel();
    super.dispose();
  }

  void onMessagesReceived(data) async {
    if(!mounted) {
      return;
    }

    if(data.data == null) {
      return;
    }

    final List mL = data.data.data.messages;

    if(mL == null) {
      return;
    }

    setState(() {
      chats = mL.reversed.toList();
    });

    _scrollToBottom(checkPosition: true);

    // if(chats != null && chats.length > 0) {
    //   _indexScrollController.scrollToIndex(0, preferPosition: AutoScrollPosition.end, duration: Duration(seconds: 2));
    // }
  }

  onMessageReceived(data) {
    var message = Message.fromJson(data['message']);
    bloc.messageSink
        .add(ApiResponse.addMessage(JsonEncoder().convert(message)));
  }

  List<String> get messageIds {
    return (chats ?? []).map((e) => "${e.id}").toList();
  }

  void waitJoinRoom() {
    Timer(Duration(seconds: 2), () {
      socketService.join(chatId);

      socketService.setRoom(chatId);
    });
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
        type: chat.type);

    if (chat.id != null && !messageIds.contains("${chat.id}")) {
      setState(() {
        chats.insert(0, mssg);
        // messages.add(mssg);
      });
    }
  }

  _confirmReport() async {
    await showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Report User',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontFamily: 'Berkshire Swash',
                  color: AppColors.secondaryElement,
                  fontWeight: FontWeight.w400,
                  fontSize: 24,
                ),
              ),
              contentPadding: const EdgeInsets.all(16.0),
              content: Wrap(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Why are you reporting this user?'),
                      Row(
                        children: [
                          new Radio(
                            value: 'ABUSIVE',
                            groupValue: report,
                            onChanged: (val) {
                              print("Radio $val");
                              setState(() {
                                report = val;
                              });
                            },
                          ),
                          new Text(
                            'Abusive',
                            style: new TextStyle(fontSize: 16.0),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          new Radio(
                            value: 'FAKE_PROFILE',
                            groupValue: report,
                            onChanged: (val) {
                              print("Radio $val");
                              setState(() {
                                report = val;
                              });
                            },
                          ),
                          new Text(
                            'Fake Profile',
                            style: new TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          new Radio(
                            value: 'HARRASEMENT',
                            groupValue: report,
                            onChanged: (val) {
                              print("Radio $val");
                              setState(() {
                                report = val;
                              });
                            },
                          ),
                          new Text(
                            'Harrasement',
                            style: new TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          new Radio(
                            value: 'OTHERS',
                            groupValue: report,
                            onChanged: (val) {
                              print("Radio $val");
                              setState(() {
                                report = val;
                              });
                            },
                          ),
                          new Text(
                            'Others',
                            style: new TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              actions: <Widget>[
                FlatButton(
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.primaryText),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                StreamBuilder(
                    stream: bloc.userStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        switch (snapshot.data.status) {
                          case Status.LOADING:
                            return Center(
                              child: Container(),
                            );
                            break;
                          default:
                        }
                      }
                      return FlatButton(
                        onPressed: () {
                          var request = {
                            "type": report,
                            "userId": widget.peerId
                          };
                          bloc.report(request, widget.apiToken);
                        },
                        color: AppColors.secondaryElement,
                        padding: EdgeInsets.all(18),
                        child: Text('Report'),
                      );
                    }),
              ],
            );
          },
        );
      },
    );
  }

  _confirmBlock() async {
    await showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Report User',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontFamily: 'Berkshire Swash',
                  color: AppColors.secondaryElement,
                  fontWeight: FontWeight.w400,
                  fontSize: 24,
                ),
              ),
              contentPadding: const EdgeInsets.all(16.0),
              content: Text('Are you sure you want to block this user?'),
              actions: <Widget>[
                FlatButton(
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.primaryText),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                StreamBuilder(
                    stream: bloc.userStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        switch (snapshot.data.status) {
                          case Status.LOADING:
                            return Center(
                              child: Container(),
                            );
                            break;
                          default:
                        }
                      }
                      return FlatButton(
                        onPressed: () =>
                            bloc.block(widget.peerId, widget.apiToken),
                        color: AppColors.secondaryElement,
                        padding: EdgeInsets.all(18),
                        child: Text('Block'),
                      );
                    }),
              ],
            );
          },
        );
      },
    );
  }

  void _showBottom(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Select an option',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Berkshire Swash',
                          fontWeight: FontWeight.w400,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    Container(
                      child: new Wrap(
                        children: <Widget>[
                          new ListTile(
                              trailing: new Icon(FeatherIcons.chevronRight),
                              title: new Text('Block User'),
                              onTap: () {
                                _confirmBlock();
                              }),
                          new ListTile(
                            trailing: new Icon(FeatherIcons.chevronRight),
                            title: new Text(
                              'Report User',
                              style:
                                  TextStyle(color: AppColors.secondaryElement),
                            ),
                            onTap: () {
                              _confirmReport();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        socketService.setRoom(null);
        return true;
      },
      child: Scaffold(
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
                child:
                    widget.peerAvatar == null ? Text(widget.peerAvatar) : null,
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
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ShareSongs(
                        apiToken: widget.apiToken,
                        peerName: widget.peerName,
                        peerAvatar: widget.peerAvatar,
                        token: DataProvider().messageToken,
                        peerId: widget.peerId,
                      ),
                    ));
              },
            ),
            IconButton(
              icon: Icon(FeatherIcons.flag),
              color: AppColors.accentText,
              onPressed: () {
                _showBottom(context);
              },
            ),
          ],
        ),
        /*body: Column(
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
                              print(Message.fromJson(JsonDecoder()
                                  .convert(snapshot.data.message)));
                              messages.add(Message.fromJson(JsonDecoder()
                                  .convert(snapshot.data.message)));
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
                            AutoScrollTag(
                              key: ValueKey(index), 
                              controller: _indexScrollController, 
                              index: index, 
                              child: buildItem(messages[index]),
                              // highlightColor: Colors.black.withOpacity(0.1),
                            )
                              // buildItem(messages[index]),
                        );
                      })),
            ),
            buildInput()
          ],
        ),*/
        body: Column(
          children: [
            Expanded(
              child: buildChatList(),
            ),
            buildInput()
          ],
        ),
      ),
    );
  }

  Widget buildChatList() {
    if(chats == null) {
      return Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: chats.length,
      reverse: true,
      controller: _indexScrollController,
      itemBuilder: (context, index) =>
        AutoScrollTag(
          key: ValueKey(index), 
          controller: _indexScrollController, 
          index: index, 
          child: buildItem(chats[index]),
          // highlightColor: Colors.black.withOpacity(0.1),
        )
          // buildItem(messages[index]),
    );
  }

  Widget buildItem(Message message) {
    if (message.senderId.toString() == id) {
      // Right (my message)
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            message.type == 'TEXT'
                ? Container(
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
                  )
                : message.type == "MEDIA"
                    ? Container(
                        padding: EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                            color: AppColors.secondaryElement,
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        height: 135,
                        width: MediaQuery.of(context).size.width * 0.75,
                        child: PlayerWidget(
                          url: 'https://file-examples-com.github.io/uploads/2017/11/file_example_MP3_700KB.mp3',
                        ),
                        margin: EdgeInsets.only(left: 10.0, top: 5),
                      )
                    : Container(),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                padding: EdgeInsets.only(right: 20),
                child: Text(
                  message.chatDate,
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
            message.type == "TEXT"
                ? Container(
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
                  )
                : message.type == "MEDIA"
                    ? Container(
                        padding: EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                            color: AppColors.secondaryElement,
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        height: 135,
                        width: MediaQuery.of(context).size.width * 0.75,
                        child: PlayerWidget(
                          url: message.content,
                          artwork: message.content,
                        ),
                        margin: EdgeInsets.only(left: 10.0, top: 5),
                      )
                    : Container(),

            // Time
            Container(
              child: Text(
                message.chatDate,
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
      // socketService.addChat(ChatModel(
      //   id: null,
      //   chatId: chatId,
      //   content: content.trim(),
      //   receiverId: int.tryParse(widget.peerId) ?? 999999,
      //   senderId: int.tryParse(id) ?? 0,
      //   sentAt: DateTime.now(),
      //   status: 0,
      //   type: request["type"]
      // ));
      _scrollToBottom(delay: true);
    } else {
      print('nothing to send');
      Fluttertoast.showToast(
          msg: 'Nothing to send',
          backgroundColor: Colors.black,
          textColor: Colors.red);
    }
  }

  void _scrollToBottom({bool delay = false, bool checkPosition = false}) async {

    if(!_indexScrollController.hasClients) {
      return;
    }

    if (checkPosition) {
      double pos = _indexScrollController.position.pixels;
      double max = _indexScrollController.position.maxScrollExtent;

      if ((max - pos) > 50.0) {
        return;
      }
    }

    if (delay) {
      await Future.delayed(Duration(seconds: 1));
    }

    if(chats != null) {
      _indexScrollController.scrollToIndex(0, preferPosition: AutoScrollPosition.end, duration: Duration(seconds: 2));
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
