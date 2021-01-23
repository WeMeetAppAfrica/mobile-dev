import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:wemeet/models/app.dart';

import 'package:wemeet/pages/start.dart';
import 'package:wemeet/pages/404.dart';




class WeMeetApp extends StatelessWidget {

  final AppModel model;

  const WeMeetApp({Key key, this.model}) : super(key: key);

  Map<String, WidgetBuilder> _buildRoutes() {
    final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
      "/": (context) => StartPage(model: model),
      // "/on-boarding": (context) => OnBoardingPage(),
      // "/home": (context) => HomePage(model: model,),
      // "/login": (context) => Login(model: model,),
      // "/forgot-password": (context) => ForgotPass(),
      // "/kyc": (context) => KYC(),
      // "/messages": (context) => MessagesPage(model: model)
    };

    return routes;
  }


  @override
  Widget build(BuildContext context) {

    return ScopedModel<AppModel>(
      model: model,
      child: MaterialApp(
        title: "WeMeet",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        routes: _buildRoutes(),
        onUnknownRoute: (settings) {
          return MaterialPageRoute(builder: (_) => NotFoundPage());
        },
      ),
    );
  }

}