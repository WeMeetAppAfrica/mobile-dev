import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wemeet/src/blocs/bloc.dart';
import 'package:wemeet/src/resources/api_response.dart';
import 'package:wemeet/src/views/auth/picture.dart';
import 'package:wemeet/src/views/dashboard/player_widget.dart';
import 'package:wemeet/src/views/dashboard/share-songs.dart';
import 'package:wemeet/values/values.dart';

enum PlayerState { stopped, playing, paused }
enum PlayingRouteState { speakers, earpiece }

class Chat extends StatefulWidget {
  final token;
  final String peerId;
  final String peerName;
  final String peerAvatar;

  Chat(
      {Key key,
      this.token,
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
    print(id);
    if (id.hashCode <= widget.peerId.hashCode) {
      groupChatId = '$id-${widget.peerId}';
    } else {
      groupChatId = '${widget.peerId}-$id';
    }
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
          PopupMenuButton(
            onSelected: _select,
            icon: Icon(
              FeatherIcons.flag,
              color: AppColors.accentText,
            ),
            itemBuilder: (BuildContext context) {
              return choices.map((Choice choice) {
                return PopupMenuItem<Choice>(
                    value: choice, child: Text(choice.title));
              }).toList();
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
                  FirebaseFirestore.instance
                      .collection('messages')
                      .doc(groupChatId)
                      .delete();
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
  String id;
  String firstName;
  List songs = [];
  String profileImage;

  List<QueryDocumentSnapshot> listMessage = new List.from([]);
  int _limit = 20;
  final int _limitIncrement = 20;
  String groupChatId;
  SharedPreferences prefs;

  File imageFile;
  bool isLoading;
  bool isShowSticker;
  String imageUrl;

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
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

    groupChatId = '';

    isLoading = false;
    isShowSticker = false;
    imageUrl = '';
    readLocal();
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

    FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .update({'chattingWith': peerId})
        .then((value) => print("User updated"))
        .catchError((error) => print("Failed to add user: $error"));

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

  void getSticker() {
    // Hide keyboard when sticker appear
    focusNode.unfocus();
    setState(() {
      isShowSticker = !isShowSticker;
    });
  }

  Future uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, 1);
      });
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: 'This file is not an image');
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

  Widget buildItem(int index, DocumentSnapshot document) {
    if (document.data()['idFrom'] == id) {
      // Right (my message)
      return Container(
        child: Column(
          children: [
            Row(
              children: <Widget>[
                document.data()['type'] == 0
                    // Text
                    ? Container(
                        child: Text(
                          document.data()['content'],
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
                    : document.data()['type'] == 1
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
                                    child: Image.asset(
                                      'images/img_not_available.jpeg',
                                      width: 200.0,
                                      height: 200.0,
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                  ),
                                  imageUrl: document.data()['content'],
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
                                //             url: document.data()['content'])));
                              },
                              padding: EdgeInsets.all(0),
                            ),
                            margin: EdgeInsets.only(
                                bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                                right: 10.0),
                          )
                        // Sticker
                        : document.data()['type'] == 2
                            ? Container(
                                padding: EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                    color: AppColors.secondaryElement,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                height: 135,
                                width: MediaQuery.of(context).size.width * 0.75,
                                child: PlayerWidget(
                                  url: document.data()['songUrl'],
                                  artwork: document.data()['artworkUrl'],
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
                  DateFormat('dd MMM kk:mm').format(
                      DateTime.fromMillisecondsSinceEpoch(
                          int.parse(document.data()['timestamp']))),
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
                isLastMessageLeft(index)
                    ? Material(
                        child: CachedNetworkImage(
                          placeholder: (context, url) => Container(
                            child: CircularProgressIndicator(
                              strokeWidth: 1.0,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.secondaryElement),
                            ),
                            width: 35.0,
                            height: 35.0,
                            padding: EdgeInsets.all(10.0),
                          ),
                          imageUrl: peerAvatar,
                          width: 35.0,
                          height: 35.0,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(18.0),
                        ),
                        clipBehavior: Clip.hardEdge,
                      )
                    : Container(width: 35.0),
                document.data()['type'] == 0
                    ? Container(
                        child: Text(
                          document.data()['content'],
                          style: TextStyle(color: AppColors.primaryText),
                        ),
                        padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                        width: 200.0,
                        decoration: BoxDecoration(
                            color: AppColors.primaryElement,
                            borderRadius: BorderRadius.circular(8.0)),
                        margin: EdgeInsets.only(left: 10.0),
                      )
                    : document.data()['type'] == 1
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
                                    child: Image.asset(
                                      'images/img_not_available.jpeg',
                                      width: 200.0,
                                      height: 200.0,
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                  ),
                                  imageUrl: document.data()['content'],
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
                                //             url: document.data()['content'])));
                              },
                              padding: EdgeInsets.all(0),
                            ),
                            margin: EdgeInsets.only(left: 10.0),
                          )
                        : document.data()['type'] == 2
                            ? Container(
                                padding: EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                    color: AppColors.secondaryElement,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                height: 135,
                                width: MediaQuery.of(context).size.width * .75,
                                child: PlayerWidget(
                                  url: document.data()['songUrl'],
                                  artwork: document.data()['artworkUrl'],
                                ),
                                margin: EdgeInsets.only(left: 10.0),
                              )
                            : Container(),
              ],
            ),

            // Time
            Container(
              child: Text(
                DateFormat('dd MMM kk:mm').format(
                    DateTime.fromMillisecondsSinceEpoch(
                        int.parse(document.data()['timestamp']))),
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
            listMessage[index - 1].data()['idFrom'] == id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1].data()['idFrom'] != id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> onBackPress() {
    if (isShowSticker) {
      setState(() {
        isShowSticker = false;
      });
    } else {
      FirebaseFirestore.instance
          .collection('users')
          .doc(id)
          .update({'chattingWith': null});
      Navigator.pop(context);
    }
    return Future.value(false);
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

              // Sticker
              (isShowSticker ? buildSticker() : Container()),

              // Input content
              buildInput(),
            ],
          ),

          // Loading
          buildLoading()
        ],
      ),
      onWillPop: onBackPress,
    );
  }

  Widget buildSticker() {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage('mimi1', 2),
                child: Image.asset(
                  'images/mimi1.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi2', 2),
                child: Image.asset(
                  'images/mimi2.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi3', 2),
                child: Image.asset(
                  'images/mimi3.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage('mimi4', 2),
                child: Image.asset(
                  'images/mimi4.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi5', 2),
                child: Image.asset(
                  'images/mimi5.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi6', 2),
                child: Image.asset(
                  'images/mimi6.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage('mimi7', 2),
                child: Image.asset(
                  'images/mimi7.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi8', 2),
                child: Image.asset(
                  'images/mimi8.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi9', 2),
                child: Image.asset(
                  'images/mimi9.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          )
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      ),
      decoration: BoxDecoration(
          border: Border(
              top: BorderSide(
                  color: Color.fromRGBO(228, 228, 228, 1.0), width: 0.5)),
          color: Colors.white),
      padding: EdgeInsets.all(5.0),
      height: 180.0,
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
          : StreamBuilder(
              stream: bloc.messageStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  switch (snapshot.data.status) {
                    case Status.LOADING:
                      print('losssading');
                      break;
                    case Status.SENDMESSAGE:
                      print('done oo');
                      print(unsent);
                      bloc.messageSink.add(ApiResponse.idle('message'));
                      var documentReference = FirebaseFirestore.instance
                          .collection('messages')
                          .doc(groupChatId)
                          .collection(groupChatId)
                          .doc(
                              DateTime.now().millisecondsSinceEpoch.toString());

                      FirebaseFirestore.instance
                          .runTransaction((transaction) async {
                        transaction.set(
                          FirebaseFirestore.instance
                              .collection('messages')
                              .doc(groupChatId),
                          {
                            'userProfiles': [
                              {
                                'id': id,
                                'name': firstName,
                                'profileImage': profileImage
                              },
                              {
                                'id': peerId,
                                'name': peerName,
                                'profileImage': peerAvatar
                              }
                            ],
                            'users': [id, peerId],
                            'timestamp': DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            'content': unsent['content'].trim(),
                            'type': unsent['type']
                          },
                        );
                        transaction.set(
                          documentReference,
                          {
                            'idFrom': id,
                            'idTo': peerId,
                            'timestamp': DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            'content': unsent['content'].trim(),
                            'type': unsent['type']
                          },
                        );
                      }).then((e) {
                        unsent = null;
                        print("Transaction successfully committed!");
                      });
                      listScrollController.animateTo(0.0,
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
                return Container(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('messages')
                        .doc(groupChatId)
                        .collection(groupChatId)
                        .orderBy('timestamp', descending: true)
                        .limit(_limit)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                            child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.secondaryElement)));
                      } else {
                        listMessage.addAll(snapshot.data.documents);
                        return ListView.builder(
                          padding: EdgeInsets.all(10.0),
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              if (unsent != null) {
                                return Row(
                                  children: <Widget>[
                                    unsent['type'] == 0
                                        ? Container(
                                            child: Text(
                                              unsent['content'],
                                              style: TextStyle(
                                                  color: AppColors.primaryText),
                                            ),
                                            padding: EdgeInsets.fromLTRB(
                                                15.0, 10.0, 15.0, 10.0),
                                            width: 200.0,
                                            decoration: BoxDecoration(
                                                color: Color.fromRGBO(
                                                    255, 218, 28, 0.2),
                                                borderRadius:
                                                    BorderRadius.circular(8.0)),
                                            margin:
                                                EdgeInsets.only(right: 10.0),
                                          )
                                        : unsent['type'] == 1
                                            ? Container(
                                                child: FlatButton(
                                                  child: Material(
                                                    child: CachedNetworkImage(
                                                      placeholder:
                                                          (context, url) =>
                                                              Container(
                                                        child:
                                                            CircularProgressIndicator(
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                      Color>(
                                                                  AppColors
                                                                      .secondaryElement),
                                                        ),
                                                        width: 200.0,
                                                        height: 200.0,
                                                        padding: EdgeInsets.all(
                                                            70.0),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Color.fromRGBO(
                                                              228,
                                                              228,
                                                              228,
                                                              1.0),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                            Radius.circular(
                                                                8.0),
                                                          ),
                                                        ),
                                                      ),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Material(
                                                        child: Image.asset(
                                                          'images/img_not_available.jpeg',
                                                          width: 200.0,
                                                          height: 200.0,
                                                          fit: BoxFit.cover,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                          Radius.circular(8.0),
                                                        ),
                                                        clipBehavior:
                                                            Clip.hardEdge,
                                                      ),
                                                      imageUrl:
                                                          unsent['content'],
                                                      width: 200.0,
                                                      height: 200.0,
                                                      fit: BoxFit.cover,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                8.0)),
                                                    clipBehavior: Clip.hardEdge,
                                                  ),
                                                  onPressed: () {
                                                    // Navigator.push(
                                                    //     context,
                                                    //     MaterialPageRoute(
                                                    //         builder: (context) => FullPhoto(
                                                    //             url: document.data()['content'])));
                                                  },
                                                  padding: EdgeInsets.all(0),
                                                ),
                                                margin:
                                                    EdgeInsets.only(left: 10.0),
                                              )
                                            : Container(
                                                child: Image.asset(
                                                  'images/${unsent['content']}.gif',
                                                  width: 100.0,
                                                  height: 100.0,
                                                  fit: BoxFit.cover,
                                                ),
                                                margin: EdgeInsets.only(
                                                    bottom: isLastMessageRight(
                                                            index)
                                                        ? 20.0
                                                        : 10.0,
                                                    right: 10.0),
                                              ),
                                  ],
                                  mainAxisAlignment: MainAxisAlignment.end,
                                );
                              }
                              return Container();
                            }
                            return buildItem(
                                index, snapshot.data.documents[index - 1]);
                          },
                          itemCount: snapshot.data.documents.length + 1,
                          reverse: true,
                          controller: listScrollController,
                        );
                      }
                    },
                  ),
                );
              }),
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
