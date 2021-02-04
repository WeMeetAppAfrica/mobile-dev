import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:wemeet/models/app.dart';
import 'package:wemeet/services/message.dart';
import 'package:wemeet/services/socket_bg.dart';

import 'package:wemeet/utils/svg_content.dart';

import 'package:wemeet/pages/match.dart';
import 'package:wemeet/pages/profile.dart';
import 'package:wemeet/pages/playlist.dart';
import 'package:wemeet/pages/subscription.dart';

class HomePage extends StatefulWidget {

  final AppModel model;
  const HomePage({Key key, this.model}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int _currentPage = 0;

  ThemeData theme;
  MediaQueryData mQuery;

  @override
  void initState() { 
    super.initState();

    getMessageToken();
    
  }

  void getMessageToken() {
    MessageService.postLogin().then((res){
      String data = res["data"]["accessToken"] as String;
      print("Message Token: $data");
      widget.model.setMessageToken(data);

      List list = (widget.model.chatList ?? {}).keys.toList();
      BackgroundSocketService().joinRooms(list);
    });
  }

  Widget buildBody() {
    double opacity(int index) {
      return index == _currentPage ? 1.0 : 0.0;
    }

    return Stack(
      children: <Widget>[
        IgnorePointer(
          ignoring: _currentPage != 0,
          child: Opacity(
            opacity: opacity(0),
            child: MatchPage(),
          ),
        ),
        IgnorePointer(
          ignoring: _currentPage != 1,
          child: Opacity(
            opacity: opacity(1),
            child: ProfilePage(),
          ),
        ),
        IgnorePointer(
          ignoring: _currentPage != 2,
          child: Opacity(
            opacity: opacity(2),
            child: PlaylistPage(),
          ),
        ),
        IgnorePointer(
          ignoring: _currentPage != 3,
          child: Opacity(
            opacity: opacity(3),
            child: SubscriptionPage(),
          ),
        )
      ],
    );
  }

  Widget _buildBottomNav() {

    List<BottomNavigationBarItem> items = <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: SvgPicture.string(WemeetSvgContent.homeOutline, height: 23.0,),
          label: "Home",
          activeIcon: SvgPicture.string(WemeetSvgContent.home, height: 23.0,),
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.string(WemeetSvgContent.userOutline, height: 23.0,),
          label: "Profile",
          activeIcon: SvgPicture.string(WemeetSvgContent.user, height: 23.0,),
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.string(WemeetSvgContent.playlistOutline, height: 23.0,),
          label: "Playlist",
          activeIcon: SvgPicture.string(WemeetSvgContent.playlist, height: 23.0,),
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.string(WemeetSvgContent.cardOutline, height: 20.0,),
          label: "Subscription",
          activeIcon: SvgPicture.string(WemeetSvgContent.card, height: 20.0,),
        ),
    ];

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _currentPage,
      items: items,
      elevation: 0.0,
      selectedItemColor: theme.accentColor,
      onTap: (index){
        FocusScope.of(context).requestFocus(FocusNode());
        setState(() {
          _currentPage = index;
        });
      },
      backgroundColor: Colors.white,
      selectedFontSize: 10.0,
      unselectedFontSize: 10.0,
      selectedLabelStyle: TextStyle(
        height: 1.6
      ),
      iconSize: 20.0
    );
  }

  @override
  Widget build(BuildContext context) {

    theme = Theme.of(context);
    mQuery = MediaQuery.of(context);

    return Scaffold(
      body: buildBody(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }
}