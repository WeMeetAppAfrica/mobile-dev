import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:wemeet/models/app.dart';

import 'package:wemeet/pages/start.dart';
import 'package:wemeet/pages/404.dart';
import 'package:wemeet/pages/on_boarding.dart';
import 'package:wemeet/pages/register.dart';

import 'package:wemeet/utils/colors.dart';


class WeMeetApp extends StatelessWidget {

  final AppModel model;

  const WeMeetApp({Key key, this.model}) : super(key: key);

  Map<String, WidgetBuilder> _buildRoutes() {
    final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
      "/": (context) => StartPage(model: model),
      "/start": (context) => StartPage(model: model),
      "/on-boarding": (context) => OnBoardingPage(),
      // "/home": (context) => HomePage(model: model,),
      // "/login": (context) => Login(model: model,),
      "/register": (context) => RegisterPage(),
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
          primaryColor: Colors.white,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          scaffoldBackgroundColor: Colors.white,
          buttonColor: AppColors.color1,
          buttonTheme: ButtonThemeData(
            buttonColor: AppColors.color1,
            textTheme: ButtonTextTheme.primary,
          ),
          appBarTheme: AppBarTheme(
            color: Colors.white,
            brightness: Brightness.light,
            elevation: 0.0,
            actionsIconTheme: IconThemeData(
              color: AppColors.color1,
            ),
            textTheme: TextTheme(

            )
          )
        ),
        routes: _buildRoutes(),
        onUnknownRoute: (settings) {
          return MaterialPageRoute(builder: (_) => NotFoundPage());
        },
      ),
    );
  }

}