import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tindercard/flutter_tindercard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wemeet/src/SwipeAnimation/activeCard.dart';
import 'package:wemeet/src/SwipeAnimation/data.dart';
import 'package:wemeet/src/SwipeAnimation/dummyCard.dart';

import 'package:provider/provider.dart';
import 'package:wemeet/src/blocs/swipe_bloc.dart';
import 'package:wemeet/src/resources/api_response.dart';
import 'package:wemeet/src/views/auth/login.dart';
import 'package:wemeet/src/views/dashboard/matchcard.dart';
import 'package:wemeet/src/views/dashboard/messages.dart';
import 'package:wemeet/src/views/dashboard/music.dart';
import 'package:wemeet/src/views/dashboard/payment.dart';
import 'package:wemeet/src/views/dashboard/playlist.dart';
import 'package:wemeet/src/views/dashboard/privacypolicy.dart';
import 'package:wemeet/src/views/dashboard/profile.dart';
import 'package:wemeet/src/views/dashboard/termsofuse.dart';
import 'package:wemeet/values/values.dart';
import 'package:flutter/scheduler.dart' show timeDilation;

typedef void OnError(Exception exception);

class Home extends StatefulWidget {
  final token;
  Home({Key key, this.token}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  AnimationController _buttonController;
  Animation<double> rotate;
  Animation<double> right;
  SharedPreferences prefs;
  Animation<double> bottom;
  Animation<double> width;
  int flag = 0;
  List data = imageData;
  List<Widget> actions;
  Widget leading;
  String id;
  String firstName;
  String lastName;
  String title;
  String profileImage;
  dynamic currentData;
  List selectedData = [];
  List<Widget> cardList;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool isSuccessful = false;
  _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('accessToken');
  }

  PageController _controller = PageController(
    initialPage: 0,
  );
  void _removeCard(index) {
    setState(() {
      cardList.removeAt(index);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    _getUser();
    super.initState();
    title = 'Meet Someone';
    leading = IconButton(
      icon: new Icon(FeatherIcons.menu),
      onPressed: () => _scaffoldKey.currentState.openDrawer(),
    );
    actions = [
      Padding(
        padding: EdgeInsets.fromLTRB(0.0, 0.0, 16.0, 0.0),
        child: IconButton(
          icon: Icon(
            FeatherIcons.messageSquare,
            color: AppColors.primaryText,
          ),
          onPressed: () => _controller.animateToPage(
            1,
            duration: Duration(milliseconds: 300),
            curve: Curves.linear,
          ),
        ),
      ),
    ];
    swipeBloc.getSwipeSuggestions(widget.token);
    _buttonController = new AnimationController(
        duration: new Duration(milliseconds: 1000), vsync: this);

    rotate = new Tween<double>(
      begin: -0.0,
      end: -40.0,
    ).animate(
      new CurvedAnimation(
        parent: _buttonController,
        curve: Curves.ease,
      ),
    );
    rotate.addListener(() {
      setState(() {
        if (rotate.isCompleted) {
          var i = data.removeLast();
          data.insert(0, i);

          _buttonController.reset();
        }
      });
    });

    right = new Tween<double>(
      begin: 0.0,
      end: 400.0,
    ).animate(
      new CurvedAnimation(
        parent: _buttonController,
        curve: Curves.ease,
      ),
    );
    bottom = new Tween<double>(
      begin: 15.0,
      end: 100.0,
    ).animate(
      new CurvedAnimation(
        parent: _buttonController,
        curve: Curves.ease,
      ),
    );
    width = new Tween<double>(
      begin: 20.0,
      end: 25.0,
    ).animate(
      new CurvedAnimation(
        parent: _buttonController,
        curve: Curves.bounceOut,
      ),
    );
  }

  _getUser() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      id = prefs.getString('id') ?? '';
      firstName = prefs.getString('firstName') ?? '';
      lastName = prefs.getString('lastName') ?? '';
      profileImage = prefs.getString('profileImage') ?? '';
    });
    print('object' + firstName);
  }

  @override
  void dispose() {
    _buttonController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<Null> _swipeAnimation() async {
    try {
      await _buttonController.forward();
    } on TickerCanceled {}
  }

  dismissImg(img) {
    print('UNLIKE');
    var req = {"swipeeId": img.id, "type": "UNLIKE"};
    print(req);
    swipeBloc.swipe(req, widget.token);
    setState(() {
      data.remove(img);
    });
    print(selectedData);
  }

  addImg(img) {
    print('LIKE');
    print(img.id);
    var req = {"swipeeId": img.id, "type": "LIKE"};
    print(req);
    swipeBloc.swipe(req, widget.token);
    setState(() {
      data.remove(img);
      selectedData.add(img);
    });
    print(selectedData);
  }

  swipeRight() {
    if (flag == 0)
      setState(() {
        flag = 1;
      });
    _swipeAnimation();
  }

  swipeLeft() {
    if (flag == 1)
      setState(() {
        flag = 0;
      });
    _swipeAnimation();
  }

  @override
  Widget build(BuildContext context) {
    timeDilation = 0.4;
    double initialBottom = 15.0;
    CardController controller;
    var dataLength = data.length;
    double backCardPosition = initialBottom + (dataLength - 1) * 10 + 10;
    double backCardWidth = -10.0;
    return Scaffold(
      key: _scaffoldKey,
      drawer: ClipRRect(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16.0),
          bottom: Radius.circular(16.0),
        ),
        child: Drawer(
          // Add a ListView to the drawer. This ensures the user can scroll
          // through the options in the drawer if there isn't enough vertical
          // space to fit everything.
          child: Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(color: Colors.white),
                  child: Container(
                    width: 133,
                    height: 133,
                    margin: EdgeInsets.only(left: 16),
                    child: firstName != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: new BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(16)),
                                    image: new DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(profileImage != null
                                            ? profileImage
                                            : 'https://via.placeholder.com/1080?text=No+Photo'))),
                              ),
                              Container(
                                margin:
                                    EdgeInsets.only(left: 1, top: 14, right: 6),
                                child: Text(
                                  '$firstName $lastName',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontFamily: 'Berkshire Swash',
                                    color: AppColors.primaryText,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              Opacity(
                                opacity: 0.56,
                                child: Text(
                                  "Entrepreneur",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: AppColors.primaryText,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Container(),
                  ),
                ),
                ListTile(
                  title: Row(
                    children: [
                      Icon(FeatherIcons.home),
                      SizedBox(
                        width: 10,
                      ),
                      Text('Home'),
                    ],
                  ),
                  onTap: () {
                    // Update the state of the app.
                    // ...
                  },
                ),
                ListTile(
                  title: Row(
                    children: [
                      Icon(FeatherIcons.user),
                      SizedBox(
                        width: 10,
                      ),
                      Text('Profile'),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Profile(
                            token: widget.token,
                          ),
                        ));
                  },
                ),
                ListTile(
                  title: Row(
                    children: [
                      Icon(FeatherIcons.music),
                      SizedBox(
                        width: 10,
                      ),
                      Text('Playlist'),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Playlist(token: widget.token,),
                        ));
                    // Update the state of the app.
                    // ...
                  },
                ),
                ListTile(
                  title: Row(
                    children: [
                      Icon(FeatherIcons.creditCard),
                      SizedBox(
                        width: 10,
                      ),
                      Text('Subscription'),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Payment(),
                        ));
                    // Update the state of the app.
                    // ...
                  },
                ),
                Spacer(),
                ListTile(
                  title: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(FeatherIcons.file),
                      SizedBox(
                        width: 10,
                      ),
                      Text('Privacy Policy'),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PrivacyPolicy(),
                        ));
                    // Update the state of the app.
                    // ...
                  },
                ),
                ListTile(
                  title: Row(
                    children: [
                      Icon(FeatherIcons.file),
                      SizedBox(
                        width: 10,
                      ),
                      Text('Term of Use'),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TermsOfUse(),
                        ));
                    // Update the state of the app.
                    // ...
                  },
                ),
                Spacer(),
                ListTile(
                  title: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(FeatherIcons.logOut),
                      SizedBox(
                        width: 10,
                      ),
                      Text('Logout'),
                    ],
                  ),
                  onTap: () {
                    _logout();
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Login(),
                        ),
                        (Route<dynamic> route) => false);
                    // Update the state of the app.
                    // ...
                  },
                ),
                Spacer(),
              ],
            ),
          ),
        ),
      ),
      appBar: AppBar(
        iconTheme: new IconThemeData(color: AppColors.primaryText),
        backgroundColor: Colors.white,
        elevation: 0.0,
        leading: leading,
        title: Text(
          title,
          textAlign: TextAlign.left,
          style: TextStyle(
            fontFamily: 'Berkshire Swash',
            color: AppColors.primaryText,
            fontWeight: FontWeight.w400,
            fontSize: 24,
          ),
        ),
        actions: actions,
      ),
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (value) {
              print("Current Page: " + value.toString());
              if (value == 1) {
                setState(() {
                  title = 'Messages';
                  actions = [];
                  leading = IconButton(
                    icon: new Icon(FeatherIcons.home),
                    onPressed: () => _controller.animateToPage(
                      0,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.linear,
                    ),
                  );
                });
              } else {
                setState(() {
                  title = 'Meet Someone';
                  leading = IconButton(
                    icon: new Icon(FeatherIcons.menu),
                    onPressed: () => _scaffoldKey.currentState.openDrawer(),
                  );
                  actions = [
                    Padding(
                      padding: EdgeInsets.fromLTRB(0.0, 0.0, 16.0, 0.0),
                      child: IconButton(
                        icon: Icon(
                          FeatherIcons.messageSquare,
                          color: AppColors.primaryText,
                        ),
                        onPressed: () => _controller.animateToPage(
                          1,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.linear,
                        ),
                      ),
                    ),
                  ];
                });
              }
            },
            children: [
              Container(
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height - 205,
                      child: StreamBuilder(
                          stream: swipeBloc.swipeSugStream,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              switch (snapshot.data.status) {
                                case Status.LOADING:
                                  return Container(
                                    height: 410,
                                    child: Center(
                                        child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CircularProgressIndicator(
                                          backgroundColor:
                                              AppColors.secondaryElement,
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text('Finding new matches...')
                                      ],
                                    )),
                                  );
                                  break;
                                case Status.ERROR:
                                  swipeBloc.swipeSink
                                      .add(ApiResponse.idle('message '));
                                  try {
                                    if (json.decode(snapshot.data.message)[
                                            'responseCode'] ==
                                        'INVALID_TOKEN') {
                                      _logout();
                                      myCallback(() {
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => Login(),
                                            ));
                                      });
                                    }
                                  } on FormatException catch (e) {
                                    print(snapshot.data);
                                  }

                                  return Container(
                                    height: 410,
                                    child: Center(
                                        child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text('Error finding new matches...'),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        FlatButton(
                                          color: AppColors.secondaryElement,
                                          child: Text(
                                            'Try Again',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          onPressed: () => {
                                            swipeBloc.getSwipeSuggestions(
                                                widget.token)
                                          },
                                        )
                                      ],
                                    )),
                                  );
                                  break;
                                case Status.DONE:
                                  print(snapshot.data.data.data);
                                  data = snapshot.data.data.data;
                                  return snapshot.data.data.data.length > 0
                                      ? Column(
                                          children: [
                                            Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Positioned(
                                                  top: 0,
                                                  child: Container(
                                                    width: 265,
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.4,
                                                    decoration: BoxDecoration(
                                                      color: Color.fromARGB(
                                                          255, 231, 208, 206),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  16)),
                                                    ),
                                                    child: Container(),
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 8,
                                                  child: Container(
                                                    width: 297,
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.4,
                                                    decoration: BoxDecoration(
                                                      color: Color.fromARGB(
                                                          255, 230, 234, 224),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  16)),
                                                    ),
                                                    child: Container(),
                                                  ),
                                                ),
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.8,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.4,
                                                  margin:
                                                      EdgeInsets.only(top: 15),
                                                  alignment: Alignment.center,
                                                  child: Stack(
                                                      alignment:
                                                          AlignmentDirectional
                                                              .center,
                                                      children:
                                                          data.map((item) {
                                                        if (data.indexOf(
                                                                item) ==
                                                            data.length - 1) {
                                                          currentData = item;
                                                          return cardDemo(
                                                              item,
                                                              bottom.value,
                                                              right.value,
                                                              0.0,
                                                              backCardWidth +
                                                                  10,
                                                              rotate.value,
                                                              rotate.value < -10
                                                                  ? 0.1
                                                                  : 0.0,
                                                              context,
                                                              dismissImg,
                                                              flag,
                                                              addImg,
                                                              swipeRight,
                                                              swipeLeft);
                                                        } else {
                                                          backCardPosition =
                                                              backCardPosition -
                                                                  10;
                                                          backCardWidth =
                                                              backCardWidth +
                                                                  10;

                                                          return cardDemoDummy(
                                                              item,
                                                              backCardPosition,
                                                              0.0,
                                                              0.0,
                                                              backCardWidth,
                                                              0.0,
                                                              0.0,
                                                              context);
                                                        }
                                                      }).toList()),
                                                ),
                                              ],
                                            ),
                                            Spacer(),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                RawMaterialButton(
                                                  onPressed: () {
                                                    dismissImg(currentData);
                                                  },
                                                  elevation: 2.0,
                                                  fillColor: Color.fromARGB(
                                                      255, 142, 198, 63),
                                                  child: Icon(
                                                    FeatherIcons.x,
                                                    color:
                                                        AppColors.secondaryText,
                                                  ),
                                                  padding: EdgeInsets.all(15.0),
                                                  shape: CircleBorder(),
                                                ),
                                                RawMaterialButton(
                                                  onPressed: () {
                                                    addImg(currentData);
                                                  },
                                                  elevation: 2.0,
                                                  fillColor: AppColors
                                                      .secondaryElement,
                                                  child: Icon(
                                                    Icons.favorite,
                                                    color:
                                                        AppColors.secondaryText,
                                                  ),
                                                  padding: EdgeInsets.all(23.0),
                                                  shape: CircleBorder(),
                                                ),
                                              ],
                                            ),
                                            Spacer(),
                                            Spacer()
                                          ],
                                        )
                                      : Container(
                                          height: 410,
                                          child: Center(
                                              child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                  'Oops, we currently have no new matches for you.'),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              FlatButton(
                                                color:
                                                    AppColors.secondaryElement,
                                                child: Text(
                                                  'Try Again',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                onPressed: () => {
                                                  swipeBloc.getSwipeSuggestions(
                                                      widget.token)
                                                },
                                              )
                                            ],
                                          )),
                                        );

                                  break;
                                default:
                              }
                            }
                            return Container();
                          }),
                    ),
                  ],
                ),
              ),
              Messages(
                token: widget.token,
              )
            ],
          ),
          Positioned.fill(
            bottom: 25,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: MusicPlayer(
                url:
                    'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
              ),
            ),
          )
        ],
      ),
    );
  }
}

void myCallback(Function callback) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    callback();
  });
}
