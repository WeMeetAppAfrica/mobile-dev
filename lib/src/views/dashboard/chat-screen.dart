import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wemeet/src/blocs/bloc.dart';
import 'package:wemeet/src/chat/Global.dart';
import 'package:wemeet/src/models/MessageModel.dart';
import 'package:wemeet/src/resources/api_response.dart';
import 'package:wemeet/src/views/auth/picture.dart';
import 'package:wemeet/src/views/dashboard/player_widget.dart';
import 'package:wemeet/src/views/dashboard/share-songs.dart';
import 'package:wemeet/values/values.dart';

enum PlayerState { stopped, playing, paused }
enum PlayingRouteState { speakers, earpiece }

class Chat extends StatefulWidget {
  final token;
  final socket;
  final String peerId;
  final String peerName;
  final String peerAvatar;

  Chat(
      {Key key,
      this.token,
      this.socket,
      @required this.peerId,
      this.peerName,
      @required this.peerAvatar})
      : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  Choice _selectedChoice = choices[0];
  String groupChatId = '';
  String id;
  String report = 'ABUSIVE';
  List songs = [];

  SharedPreferences prefs;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getGroupChatId();
  }

  getGroupChatId() async {
    prefs = await SharedPreferences.getInstance();
    id = prefs.getString('id') ?? '';
    groupChatId = '${id}_${widget.peerId}';
    print('groupChatId');
    print(groupChatId);
  }

  setSelectedRadio(String val) {
    setState(() {
      report = val;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                            bloc.report(request, widget.token);
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
                              bloc.block(widget.peerId, widget.token),
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
                                style: TextStyle(
                                    color: AppColors.secondaryElement),
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
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShareSongs(
                      peerName: widget.peerName,
                      peerAvatar: widget.peerAvatar,
                      token: widget.token,
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
      body: StreamBuilder(
          stream: bloc.userStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              switch (snapshot.data.status) {
                case Status.BLOCKED:
                  bloc.userSink.add(ApiResponse.idle('message'));
                  myCallback(() {
                    Navigator.pop(context);
                  });
                  Fluttertoast.showToast(msg: 'User Blocked');
                  break;
                case Status.ERROR:
                  bloc.userSink.add(ApiResponse.idle('message'));
                  try {
                    Fluttertoast.showToast(
                        msg: json.decode(snapshot.data.message)['message']);
                  } on FormatException {
                    Fluttertoast.showToast(msg: snapshot.data.message);
                  }
                  break;
                default:
              }
            }
            return ChatScreen(
              token: widget.token,
              peerId: widget.peerId,
              peerName: widget.peerName,
              peerAvatar: widget.peerAvatar,
            );
          }),
    );
  }

  void _select(Choice choice) {
    switch (choice.id) {
      case 1:
        print(widget.token);

        var request = {"type": "ABUSIVE", "userId": widget.peerId};
        bloc.report(request, widget.token);
        break;
      case 2:
        bloc.block(widget.peerId, widget.token);
        break;
      case 3:
        var request = {"type": "ABUSIVE", "userId": widget.peerId};
        bloc.report(request, widget.token);
        bloc.block(widget.peerId, widget.token);
        break;
      default:
    }
    Fluttertoast.showToast(msg: 'Loading...');
    setState(() {
      _selectedChoice = choice;
    });
  }
}

class ChatScreen extends StatefulWidget {
  final String token;
  final String peerId;
  final String peerName;
  final String peerAvatar;

  ChatScreen(
      {Key key,
      this.token,
      @required this.peerId,
      this.peerName,
      @required this.peerAvatar})
      : super(key: key);

  @override
  State createState() => ChatScreenState(
      token: token, peerId: peerId, peerName: peerName, peerAvatar: peerAvatar);
}

class ChatScreenState extends State<ChatScreen> {
  ChatScreenState(
      {Key key,
      @required this.token,
      @required this.peerId,
      @required this.peerName,
      @required this.peerAvatar});

  String token;
  String peerId;
  String peerName;
  String peerAvatar;
  dynamic id;
  String firstName;
  List songs = [];
  String profileImage;

  List<dynamic> listMessage = new List.from([]);
  int _limit = 20;
  final int _limitIncrement = 20;
  String groupChatId;
  SharedPreferences prefs;

  File imageFile;
  bool isLoading;
  bool isShowSticker;
  String imageUrl;

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController(initialScrollOffset: 0.0);
  final FocusNode focusNode = FocusNode();
  String url;
  Duration _duration;
  Duration _position;

  PlayerState _playerState = PlayerState.stopped;
  PlayingRouteState _playingRouteState = PlayingRouteState.speakers;
  StreamSubscription _durationSubscription;
  dynamic unsent;
  String isPlaying = '';
  List messages = [];
  bool allowSend = true;

  _scrollListener() {
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      print("reach the bottom");
      setState(() {
        print("reach the bottom");
        _limit += _limitIncrement;
      });
    }
    if (listScrollController.offset <=
            listScrollController.position.minScrollExtent &&
        !listScrollController.position.outOfRange) {
      print("reach the top");
      setState(() {
        print("reach the top");
      });
    }
  }

  @override
  void initState() {
    super.initState();
    focusNode.addListener(onFocusChange);
    listScrollController.addListener(_scrollListener);
    bloc.getMessages(peerId, token);
    groupChatId = '';

    isLoading = false;
    isShowSticker = false;
    imageUrl = '';
    readLocal();
    G.socketUtils.setConnectListener(onConnect);
    G.socketUtils.setOnChatMessageReceivedListener(onChatMessageReceived);
  }

  onConnect(data) {
    print('Connected $data');
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear
      setState(() {
        isShowSticker = false;
      });
    }
  }

  readLocal() async {
    prefs = await SharedPreferences.getInstance();
    id = prefs.getString('id') ?? '';
    firstName = prefs.getString('firstName') ?? '';
    profileImage = prefs.getString('profileImage') ?? '';
    print(id);
    if (id.hashCode <= peerId.hashCode) {
      groupChatId = '$id-$peerId';
    } else {
      groupChatId = '$peerId-$id';
    }

    setState(() {});
  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile;

    pickedFile = await imagePicker.getImage(source: ImageSource.gallery);
    imageFile = File(pickedFile.path);

    if (imageFile != null) {
      setState(() {
        isLoading = true;
      });
      // uploadFile();
    }
  }

  onChatMessageReceived(data) {
    print('onChatMessageReceived $data');
    if (null == data || data.toString().isEmpty) {
      return;
    }
    // bool online = chatMessageModel.toUserOnlineStatus;
    // _updateToUserOnlineStatusInUI(online);
    // processMessage(chatMessageModel);
  }

  void getSticker() {
    // Hide keyboard when sticker appear
    focusNode.unfocus();
    setState(() {
      isShowSticker = !isShowSticker;
    });
  }

  void onSendMessage(String content, int type) {
    // type: 0 = text, 1 = image, 2 = sticker
    var request = {
      "content": content.trim(),
      "receiverId": peerId,
      "type": "TEXT"
    };
    setState(() {
      unsent = {"content": content.trim(), "receiverId": peerId, "type": 0};
    });
    textEditingController.clear();
    if (content.trim() != '') {
      print(request);
      bloc.sendMessage(request, widget.token);
    } else {
      print('nothing to send');
      Fluttertoast.showToast(
          msg: 'Nothing to send',
          backgroundColor: Colors.black,
          textColor: Colors.red);
    }
  }

  Widget buildItem(int index, dynamic document) {
    if (document.senderId.toString() == id) {
      // Right (my message)
      print('my message');
      return Container(
        child: Column(
          children: [
            Row(
              children: <Widget>[
                document.type == "TEXT"
                    // Text
                    ? Container(
                        child: Text(
                          document.content,
                          style: TextStyle(color: AppColors.primaryText),
                        ),
                        padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                        width: 200.0,
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(228, 228, 228, 1.0),
                            borderRadius: BorderRadius.circular(8.0)),
                        margin: EdgeInsets.only(
                            bottom: isLastMessageRight(index) ? 10.0 : 5.0,
                            right: 10.0),
                      )
                    : document.type == "IMAGE"
                        // Image
                        ? Container(
                            child: FlatButton(
                              child: Material(
                                child: CachedNetworkImage(
                                  placeholder: (context, url) => Container(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          AppColors.secondaryElement),
                                    ),
                                    width: 200.0,
                                    height: 200.0,
                                    padding: EdgeInsets.all(70.0),
                                    decoration: BoxDecoration(
                                      color: Color.fromRGBO(228, 228, 228, 1.0),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Material(
                                    child: Image.network(
                                      'https://via.placeholder.com/1080',
                                      width: 200.0,
                                      height: 200.0,
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                  ),
                                  imageUrl: document.content,
                                  width: 200.0,
                                  height: 200.0,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                                clipBehavior: Clip.hardEdge,
                              ),
                              onPressed: () {
                                // Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //         builder: (context) => FullPhoto(
                                //             url: document.content,)));
                              },
                              padding: EdgeInsets.all(0),
                            ),
                            margin: EdgeInsets.only(
                                bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                                right: 10.0),
                          )
                        // Sticker
                        : document.type == 2
                            ? Container(
                                padding: EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                    color: AppColors.secondaryElement,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                height: 135,
                                width: MediaQuery.of(context).size.width * 0.75,
                                child: PlayerWidget(
                                  url: document.content,
                                  artwork: document.content,
                                ),
                                margin: EdgeInsets.only(
                                    bottom:
                                        isLastMessageRight(index) ? 10.0 : 5.0,
                                    right: 10.0),
                              )
                            : Container(),
              ],
              mainAxisAlignment: MainAxisAlignment.end,
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                padding: EdgeInsets.only(right: 20),
                child: Text(
                  document.sentAt.toString(),
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
            Row(
              children: <Widget>[
                document.type == 'TEXT'
                    ? Container(
                        child: Text(
                          document.content,
                          style: TextStyle(color: AppColors.primaryText),
                        ),
                        padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                        width: 200.0,
                        decoration: BoxDecoration(
                            color: AppColors.primaryElement,
                            borderRadius: BorderRadius.circular(8.0)),
                        margin: EdgeInsets.only(left: 10.0),
                      )
                    : Container()
              ],
            ),

            // Time
            if (document.type != "")
              Container(
                child: Text(
                  document.sentAt.toString(),
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

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1].senderId == id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1].senderId != id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              // List of messages
              buildListMessage(),

              // Input content
              buildInput(),
            ],
          ),

          // Loading
          buildLoading()
        ],
      ),
      // onWillPop: onBackPress,
    );
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading ? const CircularProgressIndicator() : Container(),
    );
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
                onSendMessage(textEditingController.text, 0);
              },
              controller: textEditingController,
              keyboardType: TextInputType.multiline,
              maxLength: 1000,
              minLines: 1,
              maxLines: 5,
              decoration: InputDecoration(hintText: 'Say something...'),
            ),
          ),
          IconButton(
            onPressed: () => onSendMessage(textEditingController.text, 0),
            icon: Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  Widget buildListMessage() {
    return Flexible(
      child: groupChatId == ''
          ? Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.secondaryElement)))
          : Container(
              child: StreamBuilder(
                stream: bloc.messageStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    switch (snapshot.data.status) {
                      
                      case Status.SENDMESSAGE:
                        bloc.messageSink.add(ApiResponse.idle('message'));
                        listMessage.add(snapshot.data.data.data.message);
                        unsent = null;
                        // listMessage.add(unsent);
                        if (listScrollController.hasClients)
                          listScrollController.animateTo(0.0,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeOut);

                        break;
                      case Status.GETMESSAGES:
                        print('snapshot.data.data.data.messages');
                        print(listScrollController.position.minScrollExtent);
                        bloc.messageSink.add(ApiResponse.idle('message'));
                        listMessage.addAll(snapshot.data.data.data.messages);
                         listScrollController.animateTo(listScrollController.position.maxScrollExtent,
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeOut);
                        break;
                      case Status.ERROR:
                        print('error oo');
                        unsent = null;
                        var error;
                        try {
                          error = json.decode(snapshot.data.message)['message'];
                        } on FormatException {
                          error = snapshot.data.message;
                        }
                        Fluttertoast.showToast(msg: error);
                        break;
                      default:
                    }
                  }
                  return ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemBuilder: (context, index) {
                      
                      return buildItem(index, listMessage[index]);
                    },
                    itemCount: listMessage.length,
                    reverse: false,
                    controller: listScrollController,
                  );
                },
              ),
            ),
    );
  }
}

class Choice {
  const Choice({this.title, this.id});

  final String title;
  final int id;
}

const List<Choice> choices = const <Choice>[
  const Choice(title: 'Report', id: 1),
  const Choice(title: 'Block', id: 2),
  const Choice(title: 'Report & Block', id: 3),
];
