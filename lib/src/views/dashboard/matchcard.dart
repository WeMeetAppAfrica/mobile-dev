import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:wemeet/values/values.dart';

class MatchCard extends StatelessWidget {
  final image;
  final dist;
  final age;
  final name;
  final location;
  const MatchCard({Key key, this.image, this.dist, this.age, this.name, this.location}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 363,
          width: 329,
          decoration: new BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              image: new DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(
                    this.image,
                  ))),
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
                  "${this.dist} Away",
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
                    "${this.name}, ${this.age}",
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
                        this.location,
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
    );
  }
}
