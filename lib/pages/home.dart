import 'package:flutter/material.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:wemeet/models/app.dart';

import 'package:wemeet/models/user.dart';
import 'package:wemeet/models/app.dart';

import 'package:wemeet/components/home_drawer.dart';

import 'package:wemeet/src/views/dashboard/messages.dart';

import 'package:wemeet/providers/data.dart';
import 'package:wemeet/values/values.dart';

class HomePage extends StatefulWidget {
  final String token;
  final AppModel model;
  const HomePage({Key key, this.model, this.token}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  AppModel model;
  UserModel user;

  DataProvider _dataProvider = DataProvider();
  String token;

  @override
  void initState() { 
    super.initState();

    token = widget.token;
    _dataProvider.setToken(widget.token);
    
  }

  // _getUser() async {
  //   prefs = await SharedPreferences.getInstance();
    
  //   setState(() {
  //     id = prefs.getString('id') ?? '';
  //     firstName = prefs.getString('firstName') ?? '';
  //     workStatus = prefs.getString('workStatus') ?? '';
  //     locationFilter = prefs.getString('locationFilter') ?? 'true';
  //     lastName = prefs.getString('lastName') ?? '';
  //     profileImage = prefs.getString('profileImage') ?? '';
  //   });
  //   bloc.loginMessages({"userId": id}, widget.token);

  //   DataProvider().setUser(UserModel(
  //     id: int.parse(id),
  //     firstName: firstName,
  //     lastName: lastName,
  //     profileImage: profileImage,
  //     workStatus: workStatus
  //   ));

  //   FirebaseCrashlytics.instance.setUserIdentifier(id);

  //   print('object' + id);
  // }

  gotoPage(Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => page)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        brightness: Brightness.light,
        iconTheme: new IconThemeData(color: AppColors.primaryText),
        elevation: 0.0,
        title: Text(
          "Meet Someone",
          style: TextStyle(
            fontFamily: 'Berkshire Swash',
            color: AppColors.primaryText,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              FeatherIcons.messageSquare,
              color: AppColors.primaryText,
            ), 
            onPressed: () => gotoPage(Messages(token: token,))
          )
        ],
      ),
      drawer: HomeDrawer(),
    );
  }
}