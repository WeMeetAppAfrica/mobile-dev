import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

import 'package:wemeet/components/player.dart';

import 'package:wemeet/src/models/musicmodel.dart' as mm;

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

  StreamSubscription queueStream;

  List<mm.Content> items = [];
  List<MediaItem> queue = [];

  @override
  void initState() {
    super.initState();
    bloc.getMusic(widget.token);

    queueStream = AudioService.queueStream.listen(onQueueChanged);
  }

  @override
  void dispose() {
    queueStream?.cancel();
    super.dispose();
  }

  void onQueueChanged(List<MediaItem> val) {
    if(!mounted) {
      return;
    }

    setState(() {
      queue = val ?? [];     
    });
  }

  void updateQueue() async {

    if(!mounted || items.isEmpty) {
      return;
    }

    items.forEach((e) async {
      MediaItem q = queue.firstWhere((i) => i.id == e.songUrl, orElse: () => null);

      if(q == null) {
        queue.add(MediaItem(
          album: e.title,
          id: e.songUrl,
          title: e.title,
          artUri: e.artworkUrl,
          artist: e.artist,
          displayTitle: e.title,
          displaySubtitle: e.artist,
        ));
      }
    });
  }

  void initPlayer() async {
    await AudioService.start(
      backgroundTaskEntrypoint: _audioPlayerTaskEntrypoint,
      androidNotificationChannelName: 'Audio Player',
      androidNotificationColor: 0xFF2196f3,
      androidNotificationIcon: 'mipmap/ic_launcher',
      params: {"data": queue.map((q) => q.toJson).toList()}
    );
  }

  void _playItem(mm.Content item) async {
    print("Play: ${item.title} by ${item.artist}");

    if(AudioService.running) {
      AudioService.skipToQueueItem(item.songUrl);
      return;
    }

    List<dynamic> list = List();
    for (int i = 0; i < 2; i++) {
      var m = queue[i].toJson();
      list.add(m);
    }
    var params = {"data": list};
    await AudioService.start(
      backgroundTaskEntrypoint: _audioPlayerTaskEntrypoint,
      androidNotificationChannelName: 'Audio Player',
      androidNotificationColor: 0xFF2196f3,
      androidNotificationIcon: 'mipmap/ic_launcher',
      params: params,
    );

    await AudioService.playFromMediaId(item.songUrl);
  }

  Widget buildTop() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
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
    );
  }

  Widget buildSongRequests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "Music Requests",
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 17,
            ),
          ),
        ),
        SizedBox(height: 10.0),
        SizedBox(
          height: 300.0,
          child: ListView.builder(
            itemBuilder: (context, index) {
              mm.Content item = items[index];
              return Card(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                shape: RoundedRectangleBorder(
                  borderRadius: Radii.k8pxRadius,
                ),
                margin: EdgeInsets.only(right: 16.0),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CachedNetworkImage(
                        imageUrl: item.artworkUrl,
                        placeholder: (context, _) => Container(
                          color: Colors.black12
                        )
                      ),
                    ),
                    Container(
                      height: 300,
                      width: 220,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        gradient: LinearGradient(
                          begin: FractionalOffset.topCenter,
                          end: FractionalOffset.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.2),
                            Colors.black.withOpacity(0.9),
                          ],
                        )
                      ),
                    ),
                    Positioned(
                      bottom: 18.0,
                      left: 0.0, 
                      right: 0.0,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: AppColors.secondaryText,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    item.artist,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: AppColors.secondaryText
                                          .withOpacity(0.8),
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                    ),
                                  ),
                                ]
                              )
                            )
                          ]
                        )
                      )
                    )
                  ]
                )
              );
            },
            itemCount: items.length,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 15.0),
          )
        ),
      ]
    );
  } 

  Widget buildPlaylist() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "Daily Playlist",
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 17,
            ),
          ),
        ),
        SizedBox(height: 10.0),
        Column(
          children: items.map((item) {
            return Column(
              children: [
                ListTile(
                  onTap:  () => _playItem(item),
                  leading: Container(
                    width: 30.0,
                    alignment: Alignment.center,
                    child: Icon(
                      FeatherIcons.music,
                      color: AppColors.secondaryElement,
                    ),
                  ),
                  trailing: InkWell(
                    onTap:  () => _playItem(item),
                    child: Container(
                      width: 45.0,
                      height: 45.0,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.secondaryElement.withOpacity(0.2),
                        shape: BoxShape.circle
                      ),
                      child: Container(
                        width: 35.0,
                        height: 35.0,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.secondaryElement,
                          shape: BoxShape.circle
                        ),
                        child: Container(
                          margin: EdgeInsets.only(left: 3.0),
                          child: Icon(
                            FeatherIcons.play,
                            color: Colors.white,
                            size: 20.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  title: Text(item.title),
                  subtitle: Text(item.artist),
                  contentPadding: EdgeInsets.symmetric(horizontal: 30.0),
                ),
                Divider(indent: 70.0,)
              ],
            );
          }).toList()
        ),
      ]
    );
  } 

  Widget songsStream() {
    return StreamBuilder(
      stream: bloc.musicStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          switch (snapshot.data.status) {
            case Status.LOADING:
              return Center(
                child: CircularProgressIndicator(),
              );
              break;
            case Status.DONE:
              items = snapshot.data.data.data.content;
              updateQueue();
              break;
            case Status.ERROR:
            return SizedBox();
              break;
            default:
          }
        }
        return Column(
          children: [
            buildSongRequests(),
            SizedBox(height: 25.0),
            buildPlaylist()
          ]
        );
      }
    );
  }

  Widget buildBody() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  buildTop(),
                  SizedBox(height: 20.0),
                  songsStream()
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Center(
              // child: MusicPlayerComponent(
              //   margin: EdgeInsets.symmetric(vertical: 30.0),
              // ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: MusicWidget(),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: buildBody(),
      /*body: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
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

Stream<AudioState> get _audioStateStream {
  return Rx.combineLatest3<List<MediaItem>, MediaItem, PlaybackState,
      AudioState>(
    AudioService.queueStream,
    AudioService.currentMediaItemStream,
    AudioService.playbackStateStream,
    (queue, mediaItem, playbackState) => AudioState(
      queue,
      mediaItem,
      playbackState,
    ),
  );
}

void _audioPlayerTaskEntrypoint() async {
  AudioServiceBackground.run(() => AudioPlayerTask());
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
