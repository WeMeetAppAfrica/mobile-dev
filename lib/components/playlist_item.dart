import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:wemeet/models/song.dart';
import 'package:wemeet/utils/colors.dart';

class WPlaylisItem extends StatelessWidget {

  final SongModel song;
  const WPlaylisItem({Key key, this.song}) : super(key: key);

  Widget _playBtn() {

    IconData icon = Icons.play_arrow;

    return IconButton(
      onPressed: (){},
      icon: Icon(icon, color: AppColors.deepPurpleColor),
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