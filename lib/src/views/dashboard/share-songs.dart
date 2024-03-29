import 'dart:convert';

import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wemeet/src/blocs/bloc.dart';
import 'package:wemeet/src/resources/api_response.dart';
import 'package:wemeet/values/values.dart';

class ShareSongs extends StatefulWidget {
  final token;
  final peerId;
  final peerName;
  final peerAvatar;
  ShareSongs(
      {Key key,
      this.token,
      @required this.peerId,
      @required this.peerName,
      @required this.peerAvatar})
      : super(key: key);

  @override
  _ShareSongsState createState() => _ShareSongsState();
}

class _ShareSongsState extends State<ShareSongs> {
  List songs = [];

  SharedPreferences prefs;
  String peerId;
  String peerName;
  dynamic content;
  String peerAvatar;
  String id;
  String firstName;
  String groupChatId;
  String profileImage;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readLocal();
    bloc.getMusic(widget.token);
  }

  readLocal() async {
    prefs = await SharedPreferences.getInstance();
    id = prefs.getString('id') ?? '';
    peerId = widget.peerId;
    peerName = widget.peerName;
    peerAvatar = widget.peerAvatar;
    firstName = prefs.getString('firstName') ?? '';
    profileImage = prefs.getString('profileImage') ?? '';
    print(id);
    if (id.hashCode <= peerId.hashCode) {
      groupChatId = '$id-$peerId';
    } else {
      groupChatId = '$peerId-$id';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: new IconThemeData(color: AppColors.primaryText),
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: Text(
          'Share Song',
          style: TextStyle(
            fontFamily: 'Berkshire Swash',
            color: AppColors.primaryText,
            fontWeight: FontWeight.w400,
            fontSize: 24,
          ),
        ),
      ),
      body: StreamBuilder(
          stream: bloc.musicStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              switch (snapshot.data.status) {
                case Status.LOADING:
                  return Center(
                    child: Container(),
                  );
                  break;

                case Status.DONE:
                  songs = snapshot.data.data.data.content;
                  return StreamBuilder(
                      stream: bloc.messageStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          switch (snapshot.data.status) {
                            case Status.LOADING:
                              return Center(
                                child: Container(),
                              );
                              break;

                            case Status.SENDMEDIA:
                              print('done oo');
                              print(groupChatId);
                              bloc.messageSink.add(ApiResponse.idle('message'));
                              

                              break;
                            default:
                          }
                        }
                        return Container(
                          height: 300,
                          child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: songs.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: Icon(
                                    FeatherIcons.music,
                                    color: AppColors.secondaryElement,
                                  ),
                                  trailing: ClipOval(
                                    child: Material(
                                      color: AppColors
                                          .secondaryElement, // button color
                                      child: InkWell(
                                        child: SizedBox(
                                          width: 56,
                                          height: 56,
                                          child: SizedBox(
                                              width: 48,
                                              height: 48,
                                              child: Icon(
                                                FeatherIcons.upload,
                                                color: Colors.white,
                                              )),
                                        ),
                                        onTap: () {
                                          var request = {
                                            "content":
                                                songs[index].id.toString(),
                                            "receiverId": widget.peerId,
                                            "type": "MEDIA"
                                          };
                                          setState(() {
                                            content = songs[index];
                                          });
                                          bloc.sendMedia(request, widget.token);
                                        },
                                      ),
                                    ),
                                  ),
                                  title: Text(songs[index].title),
                                  subtitle: Text(songs[index].artist),
                                );
                              }),
                        );
                      });

                  break;
                case Status.ERROR:
                  bloc.musicSink.add(ApiResponse.idle('message'));
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
            return Container();
          }),
    );
  }
}
