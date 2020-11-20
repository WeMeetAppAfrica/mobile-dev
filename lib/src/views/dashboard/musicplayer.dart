import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:wemeet/values/values.dart';

Row musicPlayer(
  String artist,
  String title,
  dynamic _audioPlayer,
  dynamic _position,
  dynamic _positionText,
  dynamic _duration,
  dynamic _durationText,
  dynamic _isPlaying,
  dynamic _isPaused,
  dynamic _isPlayingThroughEarpiece,
  dynamic _earpieceOrSpeakersToggle,
  Function _play,
  Function _pause,
  Function _stop,
) {
  return Row(
    children: [
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            artist,
            style: TextStyle(
                color: Color.fromARGB(180, 255, 255, 255), fontSize: 12),
          ),
          Text(
            title,
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 16,
            ),
          ),
        ],
      ),
      Spacer(),
      Container(
        height: 80,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              key: Key('play_button'),
              onPressed: _isPlaying ? null : () => _play(),
              iconSize: 30.0,
              icon: Icon(FeatherIcons.playCircle),
              color: Colors.white,
            ),
            IconButton(
              key: Key('pause_button'),
              onPressed: _isPlaying ? () => _pause() : null,
              iconSize: 30.0,
              icon: Icon(Icons.pause),
              color: Colors.white,
            ),
            IconButton(
              key: Key('stop_button'),
              onPressed: _isPlaying || _isPaused ? () => _stop() : null,
              iconSize: 30.0,
              icon: Icon(Icons.stop),
              color: Colors.white,
            ),
          ],
        ),
      ),
    ],
  );
}
