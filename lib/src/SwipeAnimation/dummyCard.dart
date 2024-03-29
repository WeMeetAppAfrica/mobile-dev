import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:wemeet/values/values.dart';

Positioned cardDemoDummy(
    dynamic match,
    double bottom,
    double right,
    double left,
    double cardWidth,
    double rotation,
    double skew,
    BuildContext context) {
  Size screenSize = MediaQuery.of(context).size;
  // Size screenSize=(500.0,200.0);
  // print("dummyCard");
  return new Positioned(
    // bottom: 100.0 + bottom,
    // right: flag == 0 ? right != 0.0 ? right : null : null,
    //left: flag == 1 ? right != 0.0 ? right : null : null,
    child: new Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 363,
          width: 329,
          decoration: new BoxDecoration(
            color: AppColors.ternaryBackground,
            borderRadius: BorderRadius.all(Radius.circular(16)),
            image: DecorationImage(
              image: NetworkImage(match.profileImage != null
                  ? match.profileImage
                  : 'https://via.placeholder.com/1080?text=No+Photo'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          height: 363,
          width: 329,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              gradient: LinearGradient(
                  begin: FractionalOffset.topCenter,
                  end: FractionalOffset.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0),
                    AppColors.primaryElement.withOpacity(0.8),
                  ],
                  stops: [
                    0.6,
                    1.0
                  ])),
        ),
        Positioned(
          top: 15,
          right: 15,
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              decoration: BoxDecoration(
                color: Color.fromARGB(61, 0, 0, 0),
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              child: Container(
                margin: EdgeInsets.all(7),
                child: Text(
                  "${match.distanceInKm}km away",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 31,
          child: Column(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 263,
                  margin: EdgeInsets.only(bottom: 6),
                  child: Text(
                    '${match.firstName} ${match.lastName}, ${match.age}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Berkshire Swash',
                      color: AppColors.secondaryText,
                      fontWeight: FontWeight.w400,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
              Container(
                height: 40,
                padding: EdgeInsets.only(left: 10, right: 10),
                decoration: BoxDecoration(
                  color: Color.fromARGB(61, 255, 255, 255),
                  borderRadius: Radii.k8pxRadius,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      FeatherIcons.mapPin,
                      color: AppColors.secondaryText,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Container(
                      child: Text(
                        '${match.workStatus}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.secondaryText,
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
