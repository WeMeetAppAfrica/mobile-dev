import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'custom_dialog.dart';

import 'package:wemeet/utils/colors.dart';

class WeMeetLoader{

  static void showLoadingModal(BuildContext context){
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => KCustomDialog(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Container(
          width: 100.0,
          height: 100.0,
          alignment: Alignment.center,
          child: SpinKitPumpingHeart(
            color: AppColors.yellowColor,
          ),
        ),
      )
    );
  }

  static Widget showBusyLoader({Color color = AppColors.yellowColor, double size = 50.0}) {
    return Center(
      child: SpinKitPumpingHeart(
        color: color,
        size: size,
      ),
    );
  }

  static Future<bool> showBottomModalSheet(BuildContext context, String title, {String content, String cancelText, String okText, VoidCallback cancelCallback, VoidCallback okCallback}) async {
    return await showModalBottomSheet(
      context: context, 
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0)
        )
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(30.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.w500
              )
            ),
            SizedBox(height: 10.0),
            content != null ? Text(
              content,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.0,
                color: Colors.black54
              )
            ) : null,
            SizedBox(height: 20.0),
            Row(
              children: [
                Expanded(
                  child: cancelText != null ? FlatButton(
                    onPressed: () {Navigator.pop(context);},
                    child: Text(cancelText),
                  ) : SizedBox(),
                ),
                SizedBox(width: 10.0),
                Expanded(
                  child: okText != null ? RaisedButton(
                    onPressed: (){Navigator.pop(context, true);},
                    child: Text(okText),
                    elevation: 0.0,
                  ) : SizedBox(),
                )
              ],
            )
          ].where((element) => element != null).toList(),
        ),
      )
    ) ?? false;
  }
}