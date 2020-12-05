import 'dart:async';

import 'package:flutter/material.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:audio_service/audio_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:wemeet/src/views/dashboard/audioplayertask.dart';

import 'package:wemeet/values/colors.dart';

class MusicPlayerComponent extends StatefulWidget {

  final ValueChanged<bool> onShow;
  final EdgeInsets margin;
  const MusicPlayerComponent({Key key, this.onShow, this.margin}) : super(key: key);

  @override
  _MusicPlayerComponentState createState() => _MusicPlayerComponentState();
}

class _MusicPlayerComponentState extends State<MusicPlayerComponent> {

  MediaQueryData mQuery;

  Widget buildBtn({IconData icon, bool visible = false, VoidCallback callback}) {

    return InkWell(
      onTap: !visible ? null : callback,
      child: Container(
        alignment: Alignment.center,
        width: 40.0,
        height: 40.0,
        child: Icon(icon, color: visible ? Colors.white : Colors.transparent),
      ),
    );

  }

  Widget buildControls(MediaItem item, List<MediaItem> queue, [bool playing = false]) {
    return Wrap(
      spacing: 8.0,
      children: [
        buildBtn(
          visible: item != queue.first,
          icon: FeatherIcons.skipBack,
          callback: () {
            if (item == queue.first) {
              return;
            }
            AudioService.skipToPrevious();
          }
        ),
        buildBtn(
          visible: true,
          icon: playing ? FeatherIcons.pauseCircle : FeatherIcons.playCircle,
          callback: () async {
            if(playing) {
              await AudioService.pause();
            } else {
              await AudioService.play();
            }
          }
        ),
        buildBtn(
          visible: item != queue.last,
          icon: FeatherIcons.skipForward,
          callback: () {
            if (item == queue.last) {
              return;
            }
            AudioService.skipToNext();
          }
        )
      ].where((e) => e != null).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    mQuery = MediaQuery.of(context);

    return AudioServiceWidget(
      child: StreamBuilder<AudioState>(
        stream: _audioStateStream,
        builder: (context, snapshot) {
          final audioState = snapshot.data;
          List<MediaItem> queue = audioState?.queue;
          final mediaItem = audioState?.mediaItem;
          final playbackState = audioState?.playbackState;
          final processingState =
          playbackState?.processingState ?? AudioProcessingState.none;
          final playing = playbackState?.playing ?? false;

          if(!AudioService.running) {
            return SizedBox();
          }

          return Container(
            padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 7.0),
            margin: widget.margin,
            width: mQuery.size.width * 0.90,
            constraints: BoxConstraints(
              maxWidth: 350.0
            ),
            decoration: BoxDecoration(
              color: AppColors.secondaryElement,
              borderRadius: BorderRadius.circular(12.0)
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 15.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              "${mediaItem?.artist}",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w300
                              )
                            ),
                            SizedBox(height: 5.0),
                            Text(
                              "${mediaItem?.title}",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.0
                              )
                            )
                          ],
                        ),
                      ),
                      SizedBox(width: 5.0),
                      buildControls(mediaItem, queue, playing),
                      
                    ],
                  ),
                ),
                Positioned(
                  top: 0.0,
                  right: 0.0,
                  child: GestureDetector(
                    onTap: (){
                      AudioService.stop();
                    },
                    child: Icon(FeatherIcons.x, color: Colors.white, size: 20.0,),
                  ),
                )
              ],
            )
          );
        }
      ),
    );
  }
}

class MusicWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AudioServiceWidget(
      child: StreamBuilder<AudioState>(
        stream: _audioStateStream,
        builder: (context, snapshot) {
          final audioState = snapshot.data;
          final queue = audioState?.queue;
          final mediaItem = audioState?.mediaItem;
          final playbackState = audioState?.playbackState;
          final processingState =
              playbackState?.processingState ?? AudioProcessingState.none;
          final playing = playbackState?.playing ?? false;
          if (AudioService.running)
            return Container(
              padding: EdgeInsets.only(right: 20, left: 20),
              // padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 7.0),
              width: MediaQuery.of(context).size.width * 0.90,
              constraints: BoxConstraints(
                maxWidth: 350.0
              ),
              decoration: BoxDecoration(
                  color: AppColors.secondaryElement,
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              height: 80,
              child: Container(
                  child: Container(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    if (processingState !=
                        AudioProcessingState.none) ...[
                      if (mediaItem?.title != null)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                                child: Text(
                              mediaItem.artist,
                              style: TextStyle(
                                  color: Color.fromARGB(
                                      180, 255, 255, 255),
                                  fontSize: 12),
                            )),
                            Flexible(
                                child: Text(
                              mediaItem.title,
                              style: TextStyle(
                                  color: AppColors.secondaryText,
                                  fontSize: 16),
                            )),
                          ],
                        ),
                      Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(
                              FeatherIcons.skipBack,
                              color: Colors.white,
                            ),
                            iconSize: 30,
                            onPressed: () {
                              if (mediaItem == queue.first) {
                                return;
                              }
                              AudioService.skipToPrevious();
                            },
                          ),
                          !playing
                              ? IconButton(
                                  icon: Icon(
                                    FeatherIcons.playCircle,
                                    color: Colors.white,
                                  ),
                                  iconSize: 30.0,
                                  onPressed: AudioService.play,
                                )
                              : IconButton(
                                  icon: Icon(
                                    FeatherIcons.pauseCircle,
                                    color: Colors.white,
                                  ),
                                  iconSize: 30.0,
                                  onPressed: AudioService.pause,
                                ),
                          IconButton(
                            icon: Icon(
                              FeatherIcons.skipForward,
                              color: Colors.white,
                            ),
                            iconSize: 30,
                            onPressed: () {
                              if (mediaItem == queue.last) {
                                return;
                              }
                              AudioService.skipToNext();
                            },
                          ),
                          // IconButton(
                          //   icon: Icon(
                          //     FeatherIcons.stopCircle,
                          //     color: Colors.white,
                          //   ),
                          //   iconSize: 30.0,
                          //   onPressed: AudioService.stop,
                          // ),
                        ],
                      )
                    ]
                  ],
                ),
              )),
            );

          return Container();
        },
      )
    );
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