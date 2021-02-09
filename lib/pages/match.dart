import 'package:flutter/material.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter_tindercard/flutter_tindercard.dart';
import 'package:ionicons/ionicons.dart';
import 'dart:async';

import 'package:wemeet/models/user.dart';

import 'package:wemeet/services/match.dart';
import 'package:wemeet/providers/data.dart';

import 'package:wemeet/components/media_player.dart';
import 'package:wemeet/components/loader.dart';
import 'package:wemeet/components/error.dart';
import 'package:wemeet/utils/colors.dart';

class MatchPage extends StatefulWidget {
  @override
  _MatchPageState createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {

  int swipesLeft = 0;
  bool isLoading = false;
  int left = 0;
  List<UserModel> users = [];
  UserModel match;

  DataProvider _dataProvider = DataProvider();
  StreamSubscription<String> reloadStream;

  CardController controller = CardController();

  @override
  void initState() { 
    super.initState();
    
    reloadStream = _dataProvider.onReloadPage.listen(onReload);

    fetchData();
  }

  @override
  void dispose() { 
    reloadStream?.cancel();
    super.dispose();
  }

  void fetchData() async {
    setState(() {
      isLoading = true;
    });

    try {
      var res = await MatchService.getSwipes();
      Map data = res["data"];
      List u = data["profiles"] as List; 

      print(data);

      setState(() {
        users = u.map((e) => UserModel.fromMap(e)).toList();
        users.removeWhere((e) => e.profileImage == null);
        swipesLeft = data["swipesLeft"];   
        left = users.length;     
      });

      getMatch(data);

    } catch (e) {

    } finally {
      setState((){
        isLoading = false;
      });
    }
  }

  void getMatch(Map data) {
    // make sure match and swipe is present
    if(!data.containsKey("swipe") && !data.containsKey("match")) {
      setState(() {
        match = null;        
      });
      showMatch(false);
      return;
    }

    // make sure match is boolean and true
    if(data["match"] is bool && data["match"] == true) {
      // if swipe is empty return
      if(data["swipe"] is Map && data["swipe"].isEmpty) {
        setState(() {
          match = null;        
        });
        showMatch(false);
        return;
      }

      // Make sure swipee is Map
      if(!data["swipe"]["swipee"] is Map) {
        setState(() {
          match = null;        
        });
        showMatch(false);
        return;
      }

      Map swipee = data["swipe"]["swipee"];
      // make sure swipee is not null either
      if(swipee.isNotEmpty) {
        setState(() {
          match = UserModel.fromMap(swipee);          
        });
        print("Found a match");
        showMatch(true);
        return;
      }
    }

  }

  void showMatch(bool val) async {
    // Push Match with delay

    // remove the match component anyways
    setState(() {
      if(val){
        match = null; 
      }            
    });
  }

  void onReload(String val) {
    if(!mounted) {
      return;
    }

    if(val.split(",").contains("match")) {
      fetchData();
    }

  }

  Widget buildSwipes() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [

        ],
      ),
    );
  }

  Widget buildBody() {

    if(isLoading && users.isEmpty) {
      return WeMeetLoader.showBusyLoader(color: AppColors.color1);
    }

    if(users.isEmpty) {
      return WErrorComponent(
        text: "No Match Found",
        icon: Ionicons.heart_circle_outline,
        buttonText: "Retry",
        callback: fetchData,
      );
    }

    return buildSwipes();

  }

  Widget buildMain() {

    return Column(
      children: [
        Expanded(child: buildBody(),),
        WMEdiaPlayer()
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("WeeMeet"),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: (){
              Navigator.pushNamed(context, "/messages");
            },
            icon: Icon(FeatherIcons.messageSquare),
          )
        ],
      ),
      body: buildMain(),
    );
  }
}