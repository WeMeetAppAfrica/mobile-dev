import 'dart:convert';
import 'dart:async';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wemeet/components/error.dart';
import 'package:wemeet/providers/data.dart';
import 'package:wemeet/src/blocs/bloc.dart';
import 'package:wemeet/src/models/MessageModel.dart';
import 'package:wemeet/src/resources/api_response.dart';
import 'package:wemeet/src/views/dashboard/share-songs.dart';
import 'package:wemeet/values/values.dart';
import 'package:wemeet/utils/converters.dart';

import 'package:wemeet/components/chat_player.dart';
import 'package:wemeet/services/socket_bg.dart';
import 'package:wemeet/models/chat.dart';

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
  FocusNode _inputFocus = FocusNode();
  List messages = [];
  String report = 'ABUSIVE';
  dynamic id;

  // ScrollController _scrollController = new ScrollController();
  AutoScrollController _indexScrollController =
      AutoScrollController(axis: Axis.vertical);

  BackgroundSocketService socketService = BackgroundSocketService();

  StreamSubscription<ChatModel> onChatMessage;
  StreamSubscription chatsSub;
  bool isLoading = false;
  bool isError = false;

  List<Message> chats;
  
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
    
    fetchMessages();

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

  void fetchMessages() {
    setState(() {
      isLoading = true;
      isError = false;      
    });
    setId();
    bloc.getMessages(widget.peerId, widget.token);
  }

  void onMessagesReceived(data) async {
    if (!mounted) {
      return;
    }

    if (data.data == null) {
      return;
    }

    print("### Received messages");

    final List mL = data.data.data.messages;

    if (mL == null) {
      setState(() {
        isLoading = false;
        isError = true;        
      });
      return;
    }

    setState(() {
      chats = mL.reversed.toList();
      isLoading = false;
      isError = false;
    });

    _scrollToBottom(checkPosition: true);

    // if(chats != null && chats.length > 0) {
    //   _indexScrollController.scrollToIndex(0, preferPosition: AutoScrollPosition.end, duration: Duration(seconds: 2));
    // }
  }

  void setId() {
    List i = widget.chatId?.split("_");
    if(i.isEmpty) {
      return;
    }
    id = i.firstWhere((e) => e != widget.peerId, orElse: () => null);
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
        body: Column(
          children: [
            Expanded(
              child: buildChatList(),
            ),
            // buildInput()
            bottomBarInput()
          ],
        ),
      ),
    );
  }

  Widget buildChatList() {
    // if loading
    if ((chats ?? []).isEmpty && isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if((chats ?? []).isEmpty && isError) {
      return ErrorComponent(
        text: "An error occured while fetching your conversation",
        buttonText: "Try again",
        callback: fetchMessages,
      );
    }

    return ListView.builder(
      itemCount: chats.length,
      reverse: true,
      controller: _indexScrollController,
      itemBuilder: (context, index) => AutoScrollTag(
            key: ValueKey(index),
            controller: _indexScrollController,
            index: index,
            child: buildItem(chats[index], index),
            // highlightColor: Colors.black.withOpacity(0.1),
          ),
      padding: EdgeInsets.only(bottom: 20.0),
    );
  }

  Widget buildContent(Message message, bool me, bool showT) {
    if (message.type == "TEXT") {
      return Container(
        child: Wrap(
          children: [
            Text(
              message.content,
              style: TextStyle(color: AppColors.primaryText),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        margin: EdgeInsets.only(bottom: showT ? 0.0 : 2.0),
        decoration: BoxDecoration(
            color: me
                ? Color.fromRGBO(247, 247, 247, 1.0)
                : Color.fromRGBO(228, 228, 228, 1.0),
            borderRadius: BorderRadius.circular(8.0)),
      );
    }

    if (message.type == "MEDIA") {
      return GestureDetector(
        onTap: (){
          print(message.content);
        },
        child: ChatPlayerWidget(url: message.content,)
      );
    }

    return SizedBox();
  }

  Widget buildTag(Message mssg, int index) {
    String tag = mssg.tag;

    Widget w = Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
        margin: EdgeInsets.symmetric(vertical: 15.0),
        child: Text(tag),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.01),
          borderRadius: BorderRadius.circular(10.0)
        ),
      ),
    );

    if(index == (chats.length - 1) || chats.length == 1){
      return w;
    }

    if(index < (chats.length - 2)) {
      Message m = chats[index + 1];
      if(m.tag != tag) {
        return w;
      }
    }

    return SizedBox();
  }

  Widget buildTimestamp(Message mssg, int index) {
    String tag = mssg.chatDate;

    Widget w = Text(
      tag,
      textAlign: TextAlign.end,
      style: TextStyle(
          color: AppColors.accentText,
          fontSize: 12.0,
          fontStyle: FontStyle.italic),
    );

    if(index == (chats.length - 1) || chats.length == 1){
      return w;
    }

    if(index < (chats.length - 2)) {
      Message m = chats[index + 1];
      if(m.chatDate != tag) {
        return w;
      }
    }

    return SizedBox();
  }

  Widget buildItem(Message mssg, int index) {
    final bool me = mssg.senderId.toString() == id;
    final bool showT = showTime(mssg, index);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildTag(mssg, index),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                me ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: me ? Alignment.centerRight : Alignment.centerLeft,
                children: [
                  Container(
                    constraints: BoxConstraints(minWidth: 150.0, maxWidth: 350.0),
                    child: Column(
                      crossAxisAlignment:
                          me ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        buildContent(mssg, me, showT),
                        SizedBox(height: showT ? 3.0 : 0.0),
                        showT ? Text(
                          mssg.chatDate,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                              color: AppColors.accentText,
                              fontSize: 12.0,
                              fontStyle: FontStyle.italic),
                        ) : null,
                        SizedBox(height: showT ? 10.0 : 0.0),
                      ].where((e) => e != null).toList(),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ],
    );
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
    if (!_indexScrollController.hasClients) {
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

    if (chats != null) {
      _indexScrollController.scrollToIndex(0,
          preferPosition: AutoScrollPosition.end,
          duration: Duration(seconds: 2));
    }
  }

  bool showTime(Message mssg, int index) {
    String tag = mssg.chatDate;

    if(index == 0) {
      return true;
    }

    if(index == (chats.length - 1) || chats.length == 1) {
      return false;
    };

    if(index < (chats.length - 2)) {
      Message mt = chats[index + 1];
      Message mb = chats[index - 1];

      if("${mb.senderId}" != id &&  "${mt.senderId}" != id) {
        return true;
      }
      
      if(mb.chatDate != tag){
        return true;
      }
    }

    return false;
  }

  Widget bottomBarInput() {
    return GestureDetector(
      onVerticalDragEnd: (details) {
        if(details.primaryVelocity > 0) {
          if(_inputFocus.hasFocus) {
            FocusScope.of(context).requestFocus(FocusNode());
          }
        } 
      },
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 25.0,
          top: 15.0,
          left: 15.0,
          right: 15.0
        ),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: TextField(
                onSubmitted: (value) {
                  onSendMessage(inputTextController.text);
                },
                focusNode: _inputFocus,
                controller: inputTextController,
                keyboardType: TextInputType.multiline,
                maxLength: 1000,
                maxLines: null,
                decoration: InputDecoration(
                  counterText: "",
                  hintText: 'Say something nice',
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(width: 10.0),
            GestureDetector(
              onTap: () => onSendMessage(inputTextController.text),
              child: Container(
                width: 35.0,
                height: 35.0,
                padding: EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 5.0),
                margin: EdgeInsets.only(bottom: 5.0),
                decoration: BoxDecoration(
                  color: AppColors.sendButton,
                  borderRadius: BorderRadius.circular(4.0)
                ),
                child: Transform.rotate(
                  angle: -(math.pi) / 4,
                  origin: Offset(0.0, 0.0),
                  child: Icon(Icons.send, color: Colors.white)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
