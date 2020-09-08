/*
*  shadows.dart
*  WeMeet Mobile App
*
*  Created by 'TiFe Pariola.
*  Copyright © 2018 WeMeet. All rights reserved.
    */

import 'package:flutter/rendering.dart';


class Shadows {
  static const BoxShadow primaryShadow = BoxShadow(
    color: Color.fromARGB(41, 0, 0, 0),
    offset: Offset(0, 8),
    blurRadius: 16,
  );
  static const BoxShadow secondaryShadow = BoxShadow(
    color: Color.fromARGB(20, 0, 0, 0),
    offset: Offset(0, 4),
    blurRadius: 16,
  );
}