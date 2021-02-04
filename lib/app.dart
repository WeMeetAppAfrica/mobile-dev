import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:bot_toast/bot_toast.dart';

import 'package:wemeet/models/app.dart';

import 'package:wemeet/pages/start.dart';
import 'package:wemeet/pages/home.dart';
import 'package:wemeet/pages/404.dart';
import 'package:wemeet/pages/on_boarding.dart';
import 'package:wemeet/pages/register.dart';
import 'package:wemeet/pages/login.dart';
import 'package:wemeet/pages/forgot_password.dart';
import 'package:wemeet/pages/settings.dart';
import 'package:wemeet/pages/activate.dart';
import 'package:wemeet/pages/messages.dart';

import 'package:wemeet/utils/colors.dart';


class WeMeetApp extends StatelessWidget {

  final AppModel model;

  const WeMeetApp({Key key, this.model}) : super(key: key);

  Map<String, WidgetBuilder> _buildRoutes() {
    final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
      "/": (context) => StartPage(model: model),
      "/start": (context) => StartPage(model: model),
      "/on-boarding": (context) => OnBoardingPage(),
      "/home": (context) => HomePage(model: model,),
      "/login": (context) => LoginPage(model: model,),
      "/register": (context) => RegisterPage(),
      "/forgot-password": (context) => ForgotPasswordPage(),
      "/settings": (context) => SettingsPage(),
      "/activate": (context) => ActivatePage(model: model),
      "/messages": (context) => MessagesPage()
    };

    return routes;
  }


  @override
  Widget build(BuildContext context) {

    return ScopedModel<AppModel>(
      model: model,
      child: MaterialApp(
        title: "WeMeet",
        builder: BotToastInit(),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.white,
          accentColor: AppColors.color1,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          scaffoldBackgroundColor: Colors.white,
          fontFamily: "Nunito",
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
              headline6: TextStyle(
                color: AppColors.deepPurpleColor,
                fontSize: 18.0,
                fontWeight: FontWeight.w700,
                fontFamily: "Nunito"
              ) 
            )
          )
        ),
        routes: _buildRoutes(),
        navigatorObservers: [BotToastNavigatorObserver()],
        onUnknownRoute: (settings) {
          return MaterialPageRoute(builder: (_) => NotFoundPage());
        },
      ),
    );
  }

}