import 'package:flutter/material.dart';
import 'package:wemeet/values/colors.dart';

class CircularBtn extends StatelessWidget {

  final double radius;
  final Function onTap;
  final Icon icon;

  const CircularBtn({Key key, this.radius = 45.0, this.onTap, @required this.icon}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: radius,
        height: radius,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.secondaryElement.withOpacity(0.2),
          shape: BoxShape.circle
        ),
        child: Container(
          width: radius - 10.0,
          height: radius - 10.0,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.secondaryElement,
            shape: BoxShape.circle
          ),
          child: icon,
        ),
      ),
    );
  }
}