import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:wemeet/services/socket.dart';

import 'package:wemeet/models/app.dart';

import 'app.dart';

// Declare Shared Preference
SharedPreferences prefs;

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // initialize shared preference
  prefs = await SharedPreferences.getInstance();

  // initialize AppModel
  AppModel model = AppModel();

  var data = prefs.getString("store");
  if(data != null){
    var t = jsonDecode(data);
    model.init(t, prefs);
  } else {
    await prefs.setString("store", "{}");
    model.init({}, prefs);
  }

  // SocketService()..init();

  runApp(MyApp(model: model));
}


