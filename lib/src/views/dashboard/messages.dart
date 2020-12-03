import 'dart:convert';
import 'dart:async';

import 'package:scoped_model/scoped_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:wemeet/src/blocs/bloc.dart';
import 'package:wemeet/src/blocs/swipe_bloc.dart';
import 'package:wemeet/src/chat/Global.dart';
import 'package:wemeet/src/models/getmatchesmodel.dart';
import 'package:wemeet/src/resources/api_response.dart';
import 'package:wemeet/src/views/auth/picture.dart';
import 'package:wemeet/src/views/dashboard/chat-page.dart';
import 'package:wemeet/src/views/dashboard/chat-screen.dart';
import 'package:wemeet/src/views/dashboard/chat.dart';
import 'package:wemeet/src/views/dashboard/music.dart';
import 'package:wemeet/values/values.dart';

// My code
import 'package:wemeet/services/socket.dart';
import 'package:wemeet/src/models/chat_model.dart';
import 'package:wemeet/models/user.dart';
import 'package:wemeet/src/models/MessageModel.dart' as mm;
import 'package:wemeet/models/app.dart';
import 'package:wemeet/providers/data.dart';

class Messages extends StatefulWidget {
  final token;
  Messages({Key key, this.token}) : super(key: key);

  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  SharedPreferences prefs;
  String id;
  String firstName;
  String messageToken;
  List newChats = [];
  List matches = [];
  dynamic matchesCache;
  List activeChats = [];

  SocketService socketService = SocketService();

  StreamSubscription<ChatModel> onChatMessage;
  StreamSubscription<String> onRoom;

  AppModel model;
  UserModel user;

  @override
  void initState() {
    getUser();
    G.initSocket();
    initSocket();

    onChatMessage = socketService?.onChatReceived?.listen(onChatReceive);
    onRoom = socketService?.onRoomChanged?.listen(onRoomChanged);

    // set user
    user = DataProvider().user;

    super.initState();
  }

  @override
  void dispose() {
    onChatMessage?.cancel();
    onRoom?.cancel();
    super.dispose();
  }

  String _generateKey(String userId, String key) {
    return '$userId/$key';
  }

  void saveObject(String userId, String key, Data object) async {
    final prefs = await SharedPreferences.getInstance();
    // 1
    final string = JsonEncoder().convert(object);
    // 2
    print('string');
    print(string);
    await prefs.setString(_generateKey(userId, key), string);
  }

  Future<dynamic> getObject(String userId, String key) async {
    final prefs = await SharedPreferences.getInstance();
    // 3
    final objectString = prefs.getString(_generateKey(userId, key));
    // 4
    print('objectString');
    print(objectString);
    if (objectString != null) {
      print(Data.fromJson(
              JsonDecoder().convert(objectString) as Map<String, dynamic>)
          .totalPages);
      setState(() {
        matchesCache = Data.fromJson(
            JsonDecoder().convert(objectString) as Map<String, dynamic>);
      });
      return Data.fromJson(
          JsonDecoder().convert(objectString) as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> removeObject(String userId, String key) async {
    final prefs = await SharedPreferences.getInstance();
    // 5
    prefs.remove(_generateKey(userId, key));
  }

  getUser() async {
    prefs = await SharedPreferences.getInstance();
    id = prefs.getString('id') ?? '';
    firstName = prefs.getString('firstName') ?? '';
    print(id);
    print('initiated' + id.toString());
    bloc.loginMessages({"userId": id}, widget.token);
  }

  setMessageToken(val) async {
    prefs = await SharedPreferences.getInstance();
    prefs.setString('messageToken', val);
    messageToken = val;
  }

  initSocket() async {
    await G.socketUtils.initSocket();

    G.socketUtils.setConnectListener(onConnect);
  }

  onConnect(data) {
    print('Connected $data');
  }

  void gotoChat({String image, int peerId, String name, String chatId, int timestamp}) {

    // update chatList
    Map cL = model.chatList ?? {};
    cL[chatId] = timestamp; 
    model.setChatList(cL);

    // set active room to false
    socketService.setRoom(null);

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatView(
            token: messageToken,
            apiToken: widget.token,
            // socket: socket,
            chatId: chatId,
            peerAvatar: image,
            peerId: peerId.toString(),
            peerName: name,
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<AppModel>(builder: (context, child, m) {
      model = m;
      return Container(
        child: StreamBuilder(
            stream: bloc.messageStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                switch (snapshot.data.status) {
                  case Status.LOADING:
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                    break;
                  case Status.LOGINMESSAGES:
                    print('meme');
                    bloc.messageSink.add(ApiResponse.idle('message'));
                    print(snapshot.data.data.data.accessToken);
                    setMessageToken(snapshot.data.data.data.accessToken);
                    swipeBloc.getMatches(widget.token);
                    break;
                  case Status.ERROR:
                    Fluttertoast.showToast(msg: 'An error occured');
                    break;
                  default:
                }
              }
              return Container(
                color: Colors.white,
                child: Column(
                  children: [
                    StreamBuilder(
                        stream: swipeBloc.matchStream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            switch (snapshot.data.status) {
                              case Status.LOADING:
                                return Container(
                                    height: 100,
                                    child: Center(
                                      child: Text('Loading matches...'),
                                    ));
                                break;
                              case Status.DONE:
                                var items = snapshot.data.data.data.content;
                                matches = items;
                                swipeBloc.matchSink
                                    .add(ApiResponse.idle('message'));
                                bloc.getChats(messageToken);

                                break;
                              default:
                            }
                          }
                          if (matches.length > 0) {
                            return Container(
                              height: 100,
                              child: ListView.builder(
                                itemCount: matches.length,
                                itemBuilder: (context, index) {
                                  if (!activeChats.contains(
                                      matches[index]['id'].toString())) {
                                    return GestureDetector(
                                      onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ChatView(
                                              token: messageToken,
                                              apiToken: widget.token,
                                              // socket: socket,
                                              peerAvatar: matches[index]
                                                  ['profileImage'],
                                              peerId: matches[index]['id']
                                                  .toString(),
                                              peerName: matches[index]
                                                  ['firstName'],
                                            ),
                                          )),
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            CircleAvatar(
                                              radius: 30,
                                              backgroundImage: matches[index]
                                                          ['profileImage'] !=
                                                      null
                                                  ? CachedNetworkImageProvider(
                                                      matches[index]
                                                          ['profileImage'])
                                                  : null,
                                              child: matches[index]
                                                          ['profileImage'] ==
                                                      null
                                                  ? Text(matches[index]['name'])
                                                  : null,
                                            ),
                                            Text(matches[index]['firstName'])
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                  return SizedBox(); // Solves widget return error
                                },
                                scrollDirection: Axis.horizontal,
                              ),
                            );
                          }
                          return Container(
                            height: 100,
                          );
                        }),
                    StreamBuilder(
                        stream: bloc.messageStream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            switch (snapshot.data.status) {
                              case Status.LOADING:
                                return Container(
                                    height: 100,
                                    child: Center(
                                      child: Text('Loading matches...'),
                                    ));
                                break;
                              case Status.ERROR:
                                print(snapshot.data.message);
                                return Center(
                                    child:
                                        Text('erro ${snapshot.data.message}'));
                                break;
                              case Status.GETCHATS:
                                print('sss');
                                print(snapshot.data.data.data);
                                activeChats = snapshot.data.data.data.messages;
                                break;
                              default:
                            }
                          }
                          return Flexible(
                              child: ListView.builder(
                                  itemCount: activeChats.length,
                                  itemBuilder: (context, index) {
                                    var mssg = chats[index];
                                    Map u = itemDetails(mssg);
                                    if (u.isEmpty) return SizedBox();
                                    return ListTile(
                                      // onTap: () => Navigator.push(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //       builder: (context) => ChatView(
                                      //         token: messageToken,
                                      //         // socket: socket,
                                      //         chatId: mssg.chatId,
                                      //         peerAvatar: u["profileImage"],
                                      //         peerId: u['id'].toString(),
                                      //         peerName: u['firstName'],
                                      //       ),
                                      //     )),
                                      onTap: () {
                                        gotoChat(
                                          image: u["profileImage"],
                                          name: u['firstName'],
                                          peerId: u['id'],
                                          chatId: mssg.chatId,
                                          timestamp: mssg.timestamp
                                        );
                                      },
                                      leading: CircleAvatar(
                                        radius: 30.0,
                                        backgroundImage:
                                            CachedNetworkImageProvider(
                                                u["profileImage"]),
                                      ),
                                      title: Text(
                                          "${((u["firstName"] ?? "") + " " + (u["lastName"] ?? ""))}"
                                              .trim()),
                                      subtitle: Text(
                                        (mssg.type == "AUDIO")
                                            ? "audio..."
                                            : mssg.content,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontStyle: (mssg.type == "AUDIO")
                                                ? FontStyle.italic
                                                : FontStyle.normal),
                                      ),
                                      trailing: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            "${mssg.fDate}",
                                            style: TextStyle(fontSize: 11.0),
                                          ),
                                          mssg.withBubble
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
                                      ),
                                    );
                                  }));
                        }),
                  ],
                ),
              );
            }),
      );
    });
  }

  void onRoomChanged(String roomId) {
    if (!mounted || roomId == null) {
      return;
    }

    int index = activeChats.indexWhere((el) {
      // if chatId matches
      if (roomId == el.chatId) {
        return true;
      }

      return false;
    });

    if (index >= 0) {
      // remove bubble
      setState(() {
        activeChats[index].withBubble = false;
      });
    }
  }

  void onChatReceive(ChatModel chat) {
    if (!mounted) {
      return;
    }

    mm.Message mssg = mm.Message(
      content: chat.content,
      chatId: chat.chatId,
      id: chat.id,
      receiverId: chat.receiverId,
      senderId: chat.senderId,
      sentAt: chat.sentAt,
      status: chat.status,
      type: chat.type,
    );

    mssg.withBubble = chat.chatId != socketService.room;

    int i = activeChats.indexWhere((el) {
      List<String> ci = ["${chat.receiverId}", "${chat.senderId}"];
      List<String> ei = ["${el.receiverId}", "${el.senderId}"];

      ci.sort((a, b) => a.compareTo(b));
      ei.sort((a, b) => a.compareTo(b));

      print("$ci ===== $ei");

      return ci.join("_") == ei.join("_");
    });

    print("########## Index is: $i ");
    print("${chat.chatId}");

    // if index is found
    setState(() {
      if (i >= 0) {
        activeChats[i] = mssg;
      } else {
        activeChats.add(mssg);
      }
    });

    setState(() {
      activeChats.sort((b, a) => a.sentAt.millisecondsSinceEpoch
          .compareTo(b.sentAt.millisecondsSinceEpoch));
    });

    processChatList();
  }

  void processChatList() {
    Map cL = model.chatList;

    activeChats.forEach((el) {
      if(cL.containsKey(el.chatId)) {
        cL[el.chatId] = el.timestamp;
      } else {
        cL[el.chatId] = el.timestamp - 20;
      }
    });

    model.setChatList(cL);
  }

  List<mm.Message> get chats {

    List cl = activeChats;

    if(model == null || model.chatList.isEmpty) {
      return cl;
    }

    Map mcL = model.chatList;
    

    cl.forEach((el) { 
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

    return cl;
  }

  Map itemDetails(mssg) {
    return (matches ?? []).firstWhere(
        (e) => e['id'] == mssg.receiverId || e['id'] == mssg.senderId,
        orElse: () => {});
  }

  dynamic getDetails(message) {
    var ret;
    if (matches != null)
      matches.forEach((e) => {
            if (e['id'] == message.receiverId || e['id'] == message.senderId)
              {ret = e}
          });
    return ret;
  }
}
