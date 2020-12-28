import 'package:cached_network_image/cached_network_image.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:wemeet/models/app.dart';
import 'package:wemeet/models/user.dart';
import 'package:wemeet/values/values.dart';

class MatchComponent extends StatelessWidget {

  final UserModel match;
  final Function(bool) onTap;
  const MatchComponent({Key key, @required this.match, @required this.onTap}) : super(key: key);

  static double dWidth = 400.0;

  Widget buildUserPic(String url, Color borderColor, [double radius = 180.0]) {
    return Container(
      width: radius,
      height: radius,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 5.0)
      ),
      child: CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(url),
      ),
    );
  }

  Widget buildBtn(String text, Color color, bool chat) {
    return Container(
      width: dWidth * 0.90,
      height: 50.0,
      constraints: BoxConstraints(
        maxWidth: 400.0,
      ),
      child: RaisedButton(
        onPressed: () => onTap(chat),
        color: color,
        child: Text(text),
        textColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0)
        ),
      ),
    ); 
  }

  @override
  Widget build(BuildContext context) {

    dWidth = MediaQuery.of(context).size.width;
    final btnWidth = 65.0;
    
    return ScopedModelDescendant<AppModel>(
      builder: (context, child, model) {
        return Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'We have a match',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontFamily: 'Berkshire Swash',
                  fontWeight: FontWeight.w400,
                  // color: Color.fromRGBO(142, 198, 63, 1),
                ),
              ),
              Container(
                height: 360.0,
                alignment: Alignment.center,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        margin: EdgeInsets.only(
                          left: btnWidth * 2,
                          top: btnWidth / 2
                        ),
                        child: buildUserPic(
                          model.user.profileImage,
                          Color.fromRGBO(142, 198, 63, 1)
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        margin: EdgeInsets.only(
                          right: btnWidth * 2,
                          bottom: btnWidth / 2
                        ),
                        child: buildUserPic(
                          match.profileImage,
                          AppColors.secondaryElement
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        width: btnWidth,
                        height: btnWidth,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 3.0),
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                            colors: <Color>[
                              AppColors.secondaryElement,
                              Color.fromRGBO(142, 198, 63, 1),
                            ]
                          )
                        ),
                        child: Icon(FeatherIcons.heart, color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
              buildBtn(
                "Work My Magic",
                AppColors.secondaryElement,
                true
              ),
              SizedBox(height: 20.0),
              buildBtn(
                "Talk Later ... Keep Swiping",
                Color.fromRGBO(142, 198, 63, 1),
                false
              )
            ],
          ),
        );
      },
    );
  }
}