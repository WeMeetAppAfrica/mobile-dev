import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wemeet/src/views/auth/kyc.dart';
import 'package:wemeet/src/views/auth/login.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:wemeet/src/views/onboarding/screen1.dart';
import 'package:wemeet/src/views/onboarding/screen2.dart';
import 'package:wemeet/src/views/onboarding/screen3.dart';

// # my pages
import 'package:wemeet/pages/home.dart';
import 'package:wemeet/pages/start.dart';
import 'package:wemeet/pages/onboarding.dart';
import 'package:wemeet/pages/messages.dart';

import 'package:wemeet/models/app.dart';

import 'package:wemeet/values/colors.dart';

class MyApp extends StatelessWidget {

  final AppModel model;

  const MyApp({Key key, this.model}) : super(key: key); 

  Map<String, WidgetBuilder> _buildRoutes() {
    final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
      "/": (context) => StartPage(model: model),
      "/on-boarding": (context) => OnBoardingPage(),
      "/home": (context) => HomePage(model: model,),
      "/login": (context) => Login(model: model,),
      "/kyc": (context) => KYC(),
      "/messages": (context) => MessagesPage(model: model)
    };

    return routes;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScopedModel<AppModel>(
      model: model,
      child: MaterialApp(
        title: 'WeMeet',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: AppBarTheme(
            actionsIconTheme: IconThemeData(color: AppColors.primaryText),
            iconTheme: IconThemeData(color: AppColors.primaryText),
            brightness: Brightness.light,
            textTheme: TextTheme(
              headline6: TextStyle(
                color: AppColors.primaryText,
                fontSize: 20.0,
                fontFamily: 'Berkshire Swash',
              ),
            ),
            color: Colors.white,
            elevation: 0.0
          ),
        ),
        // home: MyHomePage(title: 'WeMeet - Swipe'),
        routes: _buildRoutes(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final pageControl = PageController(initialPage: 0);
  final firebaseMessaging = FirebaseMessaging();
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  String token;
  Object user;
  bool passWalkthrough = false;
  bool passKYC = false;
  int _currentPage = 0;

  bool _initialized = false;
  bool _error = false;

  _setDevice(token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('pushToken', token);
    print(token);
  }

  void registerNotification() {
    firebaseMessaging.requestNotificationPermissions();

    firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) {
      print('onMessage: $message');
      Platform.isAndroid
          ? showNotification(message['notification'])
          : showNotification(message['aps']['alert']);
      return;
    }, onResume: (Map<String, dynamic> message) {
      print('onResume: $message');
      return;
    }, onLaunch: (Map<String, dynamic> message) {
      print('onLaunch: $message');
      return;
    });

    firebaseMessaging.getToken().then((token) {
      print('tokemn: $token');

      _setDevice(token);
    }).catchError((err) {
      print('err: $err');
    });
  }

  void showNotification(message) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      Platform.isAndroid ? 'com.wemeetng.wemeet' : 'com.wemeetng.wemeet',
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
        payload: json.encode(message));
  }

  void configLocalNotification() {
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Define an async function to initialize FlutterFire
  void initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp();
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      // Set `_error` state to true if Firebase initialization fails
      setState(() {
        _error = true;
      });
    }

  }

  @override
  void initState() {

    initializeFlutterFire();
    registerNotification();
    configLocalNotification();
    super.initState();
    _getUser();
    Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_currentPage < 2) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (pageControl.hasClients)
        pageControl.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
    });
  }

  _getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(prefs.getString('accessToken'));
    setState(() {
      prefs.setString('user', jsonEncode(user));
      token = prefs.getString('accessToken');
      user = jsonDecode(prefs.getString('user'));
      print(prefs.getBool('passKYC'));
      print(prefs.getBool('passKYC'));
      passKYC =
          prefs.getBool('passKYC') == null ? false : prefs.getBool('passKYC');
      passWalkthrough = prefs.getBool('passWalkthrough') == null
          ? false
          : prefs.getBool('passWalkthrough');
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    if (_error) {
      print('something went wrong');
      // return SomethingWentWrong();
    }

    // Show a loader until FlutterFire is initialized
    if (!_initialized) {
      return Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      body: token != null
          ? passKYC
              ? HomePage() 
              // ? Home(token: token)
              : KYC()
          : passWalkthrough
              ? Login()
              : PageView(
                  controller: pageControl,
                  children: [
                    OnBoarding1(),
                    OnBoarding2(),
                    OnBoarding3(),
                  ],
                ),
    );
  }
}