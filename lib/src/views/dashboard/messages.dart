import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wemeet/src/blocs/swipe_bloc.dart';
import 'package:wemeet/src/resources/api_response.dart';
import 'package:wemeet/src/views/auth/picture.dart';
import 'package:wemeet/src/views/dashboard/chat-screen.dart';
import 'package:wemeet/src/views/dashboard/chat.dart';
import 'package:wemeet/values/values.dart';

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
  List newChats = [];
  List activeChats = [];
  @override
  void initState() {
    // TODO: implement initState
    getUser();
    super.initState();
    swipeBloc.getMatches(widget.token);
  }

  getUser() async {
    prefs = await SharedPreferences.getInstance();
    id = prefs.getString('id') ?? '';
    firstName = prefs.getString('firstName') ?? '';
    print(id);

    FirebaseFirestore.instance
        .collection('users')
        .doc('13')
        .set({'chattingWith': null})
        .then((value) => print("User updated"))
        .catchError((error) => print("Failed to add user: $error"));

    setState(() {});
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
        title: Text(
          "Messages",
          textAlign: TextAlign.left,
          style: TextStyle(
            fontFamily: 'Berkshire Swash',
            color: AppColors.primaryText,
            fontWeight: FontWeight.w400,
            fontSize: 24,
          ),
        ),
      ),
      body: Column(
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
                      print(items);
                      if (snapshot.data.data.data.content.length > 0) {
                        return Container(
                          height: 100,
                          child: ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              if (!activeChats
                                  .contains(items[index]['id'].toString())) {
                                return GestureDetector(
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Chat(
                                          peerAvatar: items[index]
                                              ['profileImage'],
                                          peerId: items[index]['id'].toString(),
                                          peerName: items[index]['firstName'],
                                        ),
                                      )),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CircleAvatar(
                                          radius: 30,
                                          backgroundImage: items[index]
                                                      ['profileImage'] !=
                                                  null
                                              ? NetworkImage(
                                                  items[index]['profileImage'])
                                              : null,
                                          child: items[index]['profileImage'] ==
                                                  null
                                              ? Text(items[index]['name'])
                                              : null,
                                        ),
                                        Text(items[index]['firstName'])
                                      ],
                                    ),
                                  ),
                                );
                              }
                            },
                            scrollDirection: Axis.horizontal,
                          ),
                        );
                      }

                      break;
                    default:
                  }
                }
                return Container(
                  child: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  height: 100,
                );
              }),
          Container(
            height: MediaQuery.of(context).size.height - 305,
            color: Colors.white,
            child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('messages')
                    .where("users", arrayContains: id)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        print('loading...');
                        break;
                      case ConnectionState.active:
                        print('done...');
                        print(activeChats);
                        print(snapshot.data.documents.length);
                        if (snapshot.data.documents.length > 0) {
                          var chat;
                          snapshot.data.documents.map((document) {
                            document.data()['userProfiles'].forEach((e) {
                              if (e['id'] != id) {
                                chat = e;

                                if (!activeChats.contains(e['id']))
                                  myCallback(() {
                                    setState(() {
                                      activeChats.add(e['id']);
                                    });
                                  });
                              }
                            });
                          }).toList();

                          return ListView.builder(
                              itemCount: snapshot.data.documents.length,
                              itemBuilder: (context, index) {
                                var message =
                                    snapshot.data.documents[index].data();

                                return Container(
                                  decoration: BoxDecoration(
                                    border: new Border(
                                      bottom: new BorderSide(
                                          color:
                                              Color.fromRGBO(228, 231, 227, 1)),
                                    ),
                                  ),
                                  child: ListTile(
                                    onTap: () => {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Chat(
                                              peerAvatar: chat['profileImage'],
                                              peerName: chat['name'],
                                              peerId: chat['id'],
                                            ),
                                          ))
                                    },
                                    leading: CircleAvatar(
                                      backgroundImage: chat['profileImage'] !=
                                              null
                                          ? NetworkImage(chat['profileImage'])
                                          : null,
                                      child: chat['profileImage'] == null
                                          ? Text(chat['name'])
                                          : null,
                                    ),
                                    title: Text(chat['name']),
                                    subtitle: Text(message['content'] != null
                                        ? message['content']
                                        : ''),
                                    trailing: Text(message['timestamp'] != null
                                        ? DateFormat('dd MMM kk:mm').format(
                                            DateTime.fromMillisecondsSinceEpoch(
                                                int.parse(
                                                    message['timestamp'])))
                                        : ''),
                                  ),
                                );
                              });
                        } else {
                          return Center(
                            child: Text('No active chats!'),
                          );
                        }
                        break;
                      default:
                    }
                  }
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }),
          ),
          Container(
            padding: EdgeInsets.only(left: 20, right: 20),
            margin: EdgeInsets.only(bottom: 25),
            decoration: BoxDecoration(
                color: AppColors.secondaryElement,
                borderRadius: BorderRadius.all(Radius.circular(20))),
            height: 80,
            width: MediaQuery.of(context).size.width * 0.9,
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '2 Baba',
                      style: TextStyle(
                          color: Color.fromARGB(180, 255, 255, 255),
                          fontSize: 12),
                    ),
                    Text(
                      'Gaga Shuffle',
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Icon(
                  FeatherIcons.playCircle,
                  color: AppColors.secondaryText,
                  size: 32,
                ),
                SizedBox(
                  width: 20,
                ),
                Icon(
                  FeatherIcons.fastForward,
                  color: AppColors.secondaryText,
                  size: 32,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
