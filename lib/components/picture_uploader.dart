import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'dart:math';
import 'dart:io';

import 'package:wemeet/utils/colors.dart';

class PictureUploader extends StatefulWidget {

  final String imageUrl;
  final ValueChanged<String> onDone;
  final double right;
  final double left;
  final double radius;

  const PictureUploader({Key key, 
    this.imageUrl, 
    @required this.onDone,
    this.radius = 50.0,
    this.right = 0.0, 
    this.left = 0.0,
  }) : super(key: key);

  @override
  _PictureUploaderState createState() => _PictureUploaderState();
}

class _PictureUploaderState extends State<PictureUploader> {

  bool isLoading = false;

  String _remoteUrl;
  String _localUrl;

  @override
  void initState() { 
    super.initState();
    
    _remoteUrl = widget.imageUrl;
  }

  bool get isEmpty {
    return _remoteUrl == null && _localUrl == null;
  }

  void _tap() {

  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _tap,
      child: Container(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        width: widget.radius * 2,
        height: widget.radius * 2,
        margin: EdgeInsets.only(
          right: widget.right,
          left: widget.left
        ),
        decoration: BoxDecoration(
          color: Color(0xfff0e5fe),
          borderRadius: BorderRadius.circular(3.0),
        ),
        child: Stack(
          children: [
            // show + if empty
            if(isEmpty) Center(
              child: Icon(FeatherIcons.plus, size: max(16.0, widget.radius * 0.5), color: AppColors.color1)
            ),

            // if local url is present
            if(_localUrl != null /*&& _remoteUrl == null*/) Positioned.fill(
              child: Image.file(
                File(_localUrl),
                fit: BoxFit.cover,
              ),
            ),

            // if remote url is present
            if(_remoteUrl != null) Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: _remoteUrl,
                fit: BoxFit.cover,
              ),
            ),

            // if not ready yet
            if(_remoteUrl == null && !isEmpty) Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5)
                ),
              )
            ),

            // if progress is not done
            if(isLoading) Center(
              child: SpinKitFadingCircle(
                color: Colors.white,
                size: max(widget.radius, 35.0),
              ),
            )
          ].where((e) => e != null).toList(),
        ),
      ),
    );
  }
}