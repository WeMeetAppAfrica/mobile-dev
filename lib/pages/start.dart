import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import 'dart:convert';

import 'package:wemeet/models/app.dart';
import 'package:wemeet/models/user.dart';
import 'package:wemeet/providers/data.dart';
import 'package:wemeet/src/blocs/bloc.dart';

class StartPage extends StatefulWidget {
  final AppModel model;
  const StartPage({Key key, this.model}) : super(key: key);

  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final firebaseMessaging = FirebaseMessaging();
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  bool isLoading = false;

  AppModel model;
  UserModel user;

  @override
  void initState() {
    super.initState();

    model = widget.model;
    user = model.user;

    configurePush();
    configLocalNotification();

    created();
  }

  void created() async {
    setState(() {
      isLoading = true;
    });

    await Future.delayed(Duration(milliseconds: 1000));

    print("//// Model token: ${model.token}");

    // if there is no token go to login
    if (model.token == null || model.token.isEmpty || model.user == null) {
      // if first launch got to walkthrough
      if (model.firstLaunch == "yes") {
        model.setFirstLaunch("no");
        routeTo("/on-boarding");
        return;
      }

      routeTo("/login");
      return;
    }

    // if user is not verified
    if (user.profileImage == null) {
      routeTo("kyc");
      return;
    }

    routeTo("/home");
    return;
  }

  void configLocalNotification() {
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void configurePush() {
    firebaseMessaging.requestNotificationPermissions();

    firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) {
          print('onMessage: $message');
          Platform.isAndroid
              ? showNotification(message['notification'])
              : showNotification(message['notification']);
          return;
        },
        onBackgroundMessage:
            Platform.isAndroid ? myBackgroundMessageHandler : null,
        onResume: (Map<String, dynamic> message) {
          print('onResume: $message');
          return;
        },
        onLaunch: (Map<String, dynamic> message) {
          print('onLaunch: $message');
          return;
        });

    firebaseMessaging.getToken().then((token) {
      print('pushh $token');
      model.setPushToken(token);
    }).catchError((err) {
      print('err: $err');
    });

    firebaseMessaging.onTokenRefresh.listen((token) {
      print('new pushh $token');
      if (DataProvider().pushToken != null)
        bloc.updateDevice({
          "newDeviceToken": token,
          "oldDeviceToken": DataProvider().pushToken
        });
      model.setPushToken(token);
    });
  }

  void showNotification(message) async {
    print('show notes');
    print(message['title']);
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      Platform.isAndroid ? 'com.africa.wemeet' : 'com.africa.wemeet',
      'WeMeet',
      'swipe, meet',
      playSound: true,
      enableVibration: true,
      importance: Importance.max,
      priority: Priority.high,
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, message['title'].toString(),
        message['body'].toString(), platformChannelSpecifics,
        payload: jsonEncode(message));
    Fluttertoast.showToast(msg: message['title'].toString());
  }

  void routeTo(String route, [bool delay = true]) async {
    if (delay) {
      await Future.delayed(Duration(seconds: 2));
    }

    Navigator.of(context).pushNamedAndRemoveUntil(route, (route) => false);
  }

  Widget buildBody() {
    if (isLoading) {
      return Center(
        child: SizedBox(
            width: 25.0,
            height: 25.0,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
            )),
      );
    }

    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
      ),
      backgroundColor: Colors.white,
      body: buildBody(),
    );
  }
}

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  if (message.containsKey('data')) {
    // Handle data message
    // final dynamic data = message['data'];
  }

  if (message.containsKey('notification')) {
    // Handle notification message
    // final dynamic notification = message['notification'];
  }
}
