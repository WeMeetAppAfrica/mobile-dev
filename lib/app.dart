import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:wemeet/src/views/auth/kyc.dart';
import 'package:wemeet/src/views/auth/login.dart';

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
        routes: _buildRoutes(),
      ),
    );
  }
}

