import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rxdart/rxdart.dart';
import 'package:wemeet/src/blocs/bloc.dart';
import 'package:wemeet/src/resources/api_response.dart';
import 'package:wemeet/src/views/dashboard/audioplayertask.dart';
import 'package:wemeet/src/views/dashboard/bgaudioplayer.dart';
import 'package:wemeet/src/views/dashboard/musicplayer.dart';
import 'package:wemeet/values/values.dart';

enum PlayerState { stopped, playing, paused }
enum PlayingRouteState { speakers, earpiece }

class Playlist extends StatefulWidget {
  final token;
  final musicPlayer;
  Playlist({
    Key key,
    this.token,
    this.musicPlayer,
  }) : super(key: key);

  @override
  _PlaylistState createState() => _PlaylistState();
}

class _PlaylistState extends State<Playlist> {
  List featured = [];
  List songs = [];
  bool allowSend = true;
  TextEditingController descController = TextEditingController();
  @override
  void initState() {
    super.initState();
    bloc.getMusic(widget.token);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget buildBody() {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*body: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Text(
                  "Today's Playlist",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontFamily: 'Berkshire Swash',
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w400,
                    fontSize: 32,
                  ),
                ),
                Spacer(),
                IconButton(
                  onPressed: () => {_showDialog()},
                  color: AppColors.secondaryElement,
                  icon: Icon(FeatherIcons.plus),
                )
              ],
            ),
            SizedBox(
              height: 18,
            ),
            Text(
              "Music Requests",
              textAlign: TextAlign.left,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 20,
              ),
            ),
            SizedBox(
              height: 18,
            ),
            StreamBuilder(
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
                        featured = snapshot.data.data.data.content;

                        break;
                      case Status.ERROR:
                        break;
                      default:
                    }
                  }
                  return Container(
                    height: 300,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: featured.length,
                        itemBuilder: (context, index) {
                          return Card(
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            shape: RoundedRectangleBorder(
                              borderRadius: Radii.k8pxRadius,
                            ),
                            child: Stack(
                              children: [
                                Image(
                                  height: 300,
                                  width: 240,
                                  fit: BoxFit.cover,
                                  image: NetworkImage(
                                    featured[index].artworkUrl,
                                  ),
                                ),
                                Container(
                                  height: 300,
                                  width: 240,
                                  decoration: BoxDecoration(
                                      color: Colors.black,
                                      gradient: LinearGradient(
                                          begin: FractionalOffset.topCenter,
                                          end: FractionalOffset.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.7),
                                          ],
                                          stops: [
                                            0.6,
                                            1.0
                                          ])),
                                ),
                                Positioned(
                                  bottom: 18,
                                  left: 18,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        featured[index].title,
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: AppColors.secondaryText,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 22,
                                        ),
                                      ),
                                      Text(
                                        featured[index].artist,
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: AppColors.secondaryText
                                              .withOpacity(0.8),
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          );
                        }),
                  );
                }),
            SizedBox(
              height: 18,
            ),
            Text(
              "Daily Playlist",
              textAlign: TextAlign.left,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 20,
              ),
            ),
            StreamBuilder(
                stream: bloc.musicStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    switch (snapshot.data.status) {
                      case Status.LOADING:
                        return Center(child: CircularProgressIndicator());
                        break;
                      case Status.DONE:
                        songs = snapshot.data.data.data.content;

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
                                color: AppColors.secondaryElement, // button color
                                child: InkWell(
                                  child: SizedBox(
                                    width: 56,
                                    height: 56,
                                    child: SizedBox(
                                        width: 48,
                                        height: 48,
                                        child: Icon(
                                          FeatherIcons.play,
                                          color: Colors.white,
                                        )),
                                  ),
                                  onTap: () {
                                    // AudioService.stop();
                                    // _changeQueue(songs[index].songUrl);
                                    // List orderSong = [];
                                    // for (int i = 0; i < songs.length; i++) {
                                    //   if (index <= i) {
                                    //     orderSong.add(songs[i]);
                                    //   }
                                    // }
                                    // bloc.musicSink
                                    //     .add(ApiResponse.play(orderSong));
                                    // setState(() {
                                    //   _currentPlay = index;
                                    //   _queue = songs;
                                    //   url = _queue[index].songUrl;
                                    //   songs.forEach((element) {
                                    //     element.isPlaying = false;
                                    //   });
                                    //   songs[index].isPlaying = true;
                                    // });
                                    // _play();
                                  },
                                ),
                              ),
                            ),
                            title: Text(songs[index].title),
                            subtitle: Text(songs[index].artist),
                          );
                        }),
                  );
                }),
          ],
        ),
      ),*/
    );
  }

  _showDialog() async {
    await showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Request for Song',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontFamily: 'Berkshire Swash',
                  color: AppColors.secondaryElement,
                  fontWeight: FontWeight.w400,
                  fontSize: 24,
                ),
              ),
              contentPadding: const EdgeInsets.all(16.0),
              content: StreamBuilder(
                  stream: bloc.songStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      switch (snapshot.data.status) {
                        case Status.LOADING:
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Center(child: CircularProgressIndicator()),
                            ],
                          );
                          break;

                        case Status.ERROR:
                          bloc.songSink.add(ApiResponse.idle('message'));
                          myCallback(() {
                            setState(() {
                              allowSend = true;
                            });
                          });

                          try {
                            Fluttertoast.showToast(
                                msg: json
                                    .decode(snapshot.data.message)['message']);
                          } on FormatException {
                            Fluttertoast.showToast(msg: snapshot.data.message);
                          }
                          break;
                        case Status.SONGREQUEST:
                          print('done');
                          bloc.songSink.add(ApiResponse.idle('message'));
                          myCallback(() {
                            setState(() {
                              allowSend = true;
                            });
                          });
                          Navigator.pop(context);
                          Fluttertoast.showToast(
                              msg: 'Song request submitted successfully');
                          break;
                        default:
                      }
                    }
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                            "Tell us about the song you'd like to add and we would add it to tomorrow's playlist"),
                        new TextFormField(
                          controller: descController,
                          autofocus: true,
                          decoration: new InputDecoration(
                            prefixIcon: Icon(FeatherIcons.music),
                            labelText: 'Song Description',
                            hintText: 'eg. Joro by Layon ft. Elhi',
                            focusedBorder: UnderlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.green, width: 2.0),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
              actions: <Widget>[
                new FlatButton(
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: AppColors.primaryText),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
                allowSend == true
                    ? FlatButton(
                        color: AppColors.secondaryElement,
                        child: const Text('Send Song Request'),
                        onPressed: () {
                          setState(() {
                            allowSend = false;
                          });
                          var request = {
                            "description": descController.text,
                            "id": 0,
                            "requester": {
                              "active": true,
                              "dateOfBirth": "2020-10-27T22:29:06.265Z",
                              "email": "string",
                              "emailVerified": true,
                              "firstName": "string",
                              "gender": "MALE",
                              "id": 0,
                              "lastName": "string",
                              "phone": "string",
                              "phoneVerified": true,
                              "profileImage": "string",
                              "suspended": true,
                              "type": "FREE"
                            }
                          };
                          bloc.songRequest(request, widget.token);
                          // Navigator.pop(context);
                        })
                    : Container()
              ],
            );
          },
        );
      },
    );
  }

  void myCallback(Function callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      callback();
    });
  }
}

class _SystemPadding extends StatelessWidget {
  final Widget child;

  _SystemPadding({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    return new AnimatedContainer(
        padding: mediaQuery.viewInsets,
        duration: const Duration(milliseconds: 300),
        child: child);
  }
}
