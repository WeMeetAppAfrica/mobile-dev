import 'dart:async';

import 'package:flutter/material.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:audio_service/audio_service.dart';

import 'package:wemeet/values/colors.dart';

class MusicPlayerComponent extends StatefulWidget {

  final ValueChanged<bool> onShow;
  final EdgeInsets margin;
  const MusicPlayerComponent({Key key, this.onShow, this.margin}) : super(key: key);

  @override
  _MusicPlayerComponentState createState() => _MusicPlayerComponentState();
}

class _MusicPlayerComponentState extends State<MusicPlayerComponent> {

  bool show = false;
  MediaItem currentItem;

  StreamSubscription _runningSub;

  MediaQueryData mQuery;

  @override
  void initState() { 
    super.initState();

    // runing sub
    _runningSub = AudioService.currentMediaItemStream.listen(onCurrentRunning);
    
    // setShow(true);
  }

  @override
  void dispose() {
    _runningSub?.cancel();
    
    super.dispose();
  }

  void onCurrentRunning(MediaItem val) {
    if(!mounted) {
      return;
    }

    setState(() {
      show = val != null;
      currentItem = val;
    });

  }

  void setShow(bool val) async {
    await Future.delayed(Duration(milliseconds: 1000));
    if(widget.onShow != null) {
      widget.onShow(val);
      setState(() {
        show = val;        
      });
    }
  }

  Widget buildBtn({IconData icon, bool visible = false, VoidCallback callback}) {

    if(!visible) {
      return null;
    }

    return InkWell(
      onTap: callback,
      child: Container(
        alignment: Alignment.center,
        width: 40.0,
        height: 40.0,
        child: Icon(icon, color: Colors.white),
      ),
    );

  }

  Widget buildControls() {
    return Wrap(
      spacing: 8.0,
      children: [
        buildBtn(
          visible: true,
          icon: FeatherIcons.skipBack
        ),
        buildBtn(
          visible: true,
          icon: FeatherIcons.pauseCircle
        ),
        buildBtn(
          visible: true,
          icon: FeatherIcons.skipForward
        )
      ].where((e) => e != null).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    mQuery = MediaQuery.of(context);

    return show ? Container(
      padding: EdgeInsets.symmetric(vertical: 13.0, horizontal: 15.0),
      margin: widget.margin,
      width: mQuery.size.width * 0.90,
      constraints: BoxConstraints(
        maxWidth: 350.0
      ),
      decoration: BoxDecoration(
        color: AppColors.secondaryElement,
        borderRadius: BorderRadius.circular(12.0)
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Song Artist",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w300
                  )
                ),
                SizedBox(height: 5.0),
                Text(
                  "Song title",
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
          buildControls()
        ],
      ),
    ) : SizedBox();
  }
}