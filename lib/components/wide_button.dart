import 'package:flutter/material.dart';
import 'package:wemeet/utils/colors.dart';

import 'package:wemeet/utils/constants.dart';

class WWideButton extends StatelessWidget {

  final String title;
  final Color color;
  final Color textColor; 
  final VoidCallback onTap;

  const WWideButton({Key key, @required this.title, this.color, this.textColor, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 45.0,
        width: wemeetScreenWidth(context) * 0.90,
        constraints: BoxConstraints(
          maxWidth: 400.0
        ),
        child: RaisedButton(
          onPressed: onTap,
          child: Text(title),
          color: color,
          textColor: textColor ?? AppColors.color3,
          elevation: 0.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0)
          ),
        ),
      )
    );
  }
}