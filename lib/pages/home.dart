import 'package:flutter/material.dart';

import 'package:wemeet/components/home_drawer.dart';

import 'package:wemeet/providers/data.dart';

import 'package:wemeet/values/values.dart';

class HomePage extends StatefulWidget {
  final String token;
  const HomePage({Key key, this.token}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  DataProvider _dataProvider = DataProvider();

  @override
  void initState() { 
    super.initState();

    _dataProvider.setToken(widget.token);
    
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
      ),
      drawer: HomeDrawer(),
    );
  }
}