import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:wemeet/models/song.dart';
import 'package:wemeet/utils/colors.dart';

import 'package:wemeet/services/audio.dart';

class WPlaylisItem extends StatelessWidget {

  final SongModel song;
  final bool isPlaying;
  const WPlaylisItem({Key key, this.song, this.isPlaying = false}) : super(key: key);

  Widget _playBtn() {

    WeMeetAudioService _audio = WeMeetAudioService();

    IconData icon = Icons.play_arrow;
    Color color = AppColors.deepPurpleColor;

    if(isPlaying) {
      icon = Icons.pause;
      color = AppColors.deepPurpleColor.withOpacity(0.3);
    }

    return IconButton(
      onPressed: (){
        if(!isPlaying) {
          _audio.playSong(song);
        } else {
          _audio.pause();
        }
      },
      icon: Icon(icon, color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListTile(
        leading: Container(
          width: 50.0,
          alignment: Alignment.center,
          child: Icon(FeatherIcons.music, color: Colors.black87),
        ),
        title: Text(
          song.title
        ),
        subtitle: Text(
          song.artist,
          style: TextStyle(
            fontSize: 12.0,
            color: Colors.grey,
            height: 2.0
          ),
        ),
        trailing: _playBtn(),
      ),
    );
  }
}