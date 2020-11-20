import 'package:audio_service/audio_service.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:wemeet/src/views/dashboard/audioplayertask.dart';
import 'package:wemeet/values/values.dart';

Container bgAudioPlayer(dynamic _audioStateStream) {
  return Container(
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
        print('playbackState ${snapshot.data}');
        return Container(
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              if (processingState != AudioProcessingState.none) ...[
                if (mediaItem?.title != null)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                          child: Text(
                        mediaItem.artist,
                        style: TextStyle(
                            color: Color.fromARGB(180, 255, 255, 255),
                            fontSize: 12),
                      )),
                      Flexible(
                          child: Text(
                        mediaItem.title,
                        style: TextStyle(
                            color: AppColors.secondaryText, fontSize: 16),
                      )),
                    ],
                  ),
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                        )
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
        );
      },
    ),
  );
}
