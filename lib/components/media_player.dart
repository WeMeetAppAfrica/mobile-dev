import 'package:flutter/material.dart';
import 'dart:async';

import 'package:wemeet/services/audio.dart';

class WMEdiaPlayer extends StatefulWidget {
  @override
  _WMEdiaPlayerState createState() => _WMEdiaPlayerState();
}

class _WMEdiaPlayerState extends State<WMEdiaPlayer> {

  WeMeetAudioService _audioService = WeMeetAudioService();

  @override
  void initState() { 
    super.initState();
  }

  Widget _buildPlayer(List<String> val) {
    if(val.isEmpty) {
      return SizedBox();
    }

    return Container(
      child: Text("Love"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<String>(
        stream: _audioService.playerModeStream,
        builder: (context, snapshot) {

          if(!snapshot.hasData) {
            return SizedBox();
          }

          if(snapshot.data != "playlist") {
            return SizedBox();
          }

          return StreamBuilder<List<String>>(
            stream: _audioService.controlsStream,
            builder: (context, snapshot) {
              if(!snapshot.hasData) {
                return SizedBox();
              }

              return _buildPlayer(snapshot.data);
            }
          );
        }
      ),
    );
  }
}