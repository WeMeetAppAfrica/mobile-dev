import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tindercard/flutter_tindercard.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wemeet/src/SwipeAnimation/detail.dart';
import 'package:wemeet/src/blocs/bloc.dart';
import 'package:wemeet/src/blocs/swipe_bloc.dart';
import 'package:wemeet/src/resources/api_response.dart';
import 'package:wemeet/src/views/auth/login.dart';
import 'package:wemeet/src/views/dashboard/advanced.dart';
import 'package:wemeet/src/views/dashboard/audioplayertask.dart';
import 'package:wemeet/src/views/dashboard/bgaudio.dart';
import 'package:wemeet/src/views/dashboard/bgaudioplayer.dart';
import 'package:wemeet/src/views/dashboard/chat-screen.dart';
import 'package:wemeet/src/views/dashboard/messages.dart';
import 'package:wemeet/src/views/dashboard/music.dart';
import 'package:wemeet/src/views/dashboard/musicplayer.dart';
import 'package:wemeet/src/views/dashboard/payment.dart';
import 'package:wemeet/src/views/dashboard/playlist.dart';
import 'package:wemeet/src/views/dashboard/profile.dart';
import 'package:wemeet/src/views/dashboard/swipe.dart';
import 'package:wemeet/values/values.dart';

enum PlayerState { stopped, playing, paused }
enum PlayingRouteState { speakers, earpiece }

typedef void OnError(Exception exception);

class Home extends StatefulWidget {
  final token;
  Home({Key key, this.token}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  PlayerMode mode;
  String url;

  final BehaviorSubject<double> _dragPositionSubject =
      BehaviorSubject.seeded(null);

  bool _loading = false;

  AudioPlayer _audioPlayer;
  AudioPlayerState _audioPlayerState;
  Duration _duration;
  Duration _position;
  int toSwipe = 0;
  bool playing = false;

  PlayerState _playerState = PlayerState.stopped;
  PlayingRouteState _playingRouteState = PlayingRouteState.speakers;
  StreamSubscription _durationSubscription;
  StreamSubscription _positionSubscription;
  StreamSubscription _playerCompleteSubscription;
  StreamSubscription _playerErrorSubscription;
  StreamSubscription _playerStateSubscription;
  StreamSubscription<PlayerControlCommand> _playerControlCommandSubscription;

  get _isPlaying => _playerState == PlayerState.playing;
  get _isPaused => _playerState == PlayerState.paused;
  get _durationText => _duration?.toString()?.split('.')?.first ?? '';
  get _positionText => _position?.toString()?.split('.')?.first ?? '';

  get _isPlayingThroughEarpiece =>
      _playingRouteState == PlayingRouteState.earpiece;

  List songs = [];
  List featured = [];
  bool allowSend = true;
  TextEditingController descController = TextEditingController();
  AnimationController _buttonController;
  Animation<double> rotate;
  Animation<double> right;
  SharedPreferences prefs;
  bool matchMade = false;
  Animation<double> bottom;
  Animation<double> width;
  String locationFilter = 'true';
  int flag = 0;
  int swipesLeft = 0;
  bool disableSwipe = false;
  List<Widget> actions;
  Widget leading;
  String id;
  String firstName;
  String lastName;
  String workStatus;
  String title;
  String profileImage;
  dynamic swipeSug;
  dynamic currentData;
  bool swipeRight = false;
  bool swipeLeft = false;
  List selectedData = [];
  List<Widget> cardList;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool isSuccessful = false;
  _logout() async {
    bloc.logout({}, widget.token);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var locationFilter = prefs.getString('locationFilter');
    prefs.clear();
    prefs.setBool('passKYC', true);
    prefs.setString('locationFilter', locationFilter);
    prefs.setBool('passWalkthrough', true);
  }

  PageController _controller = PageController(
    initialPage: 0,
  );

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  _launchTerms() async {
    const url = 'https://wemeet.africa/termsandconditions.pdf';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  dismissImg(id) {
    print('UNLIKE');
    var req = {"swipeeId": id, "type": "UNLIKE"};
    print(req);
    swipeBloc.swipe(req, widget.token);
  }

  addImg(id) {
    print('LIKE $swipesLeft');
    var req = {"swipeeId": id, "type": "LIKE"};
    print(req);
    swipeBloc.swipe(req, widget.token);
  }

  _getSwipeSuggestions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      locationFilter = prefs.getString('locationFilter') ?? 'true';
    });
    swipeBloc.getSwipeSuggestions(widget.token, locationFilter);
  }

  _launchPrivacy() async {
    const url = 'https://wemeet.africa/privacypolicy.pdf';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    _getUser();
    bloc.getMusic(widget.token);
    _getSwipeSuggestions();
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
  }

  _getUser() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      id = prefs.getString('id') ?? '';
      firstName = prefs.getString('firstName') ?? '';
      workStatus = prefs.getString('workStatus') ?? '';
      locationFilter = prefs.getString('locationFilter') ?? 'true';
      lastName = prefs.getString('lastName') ?? '';
      profileImage = prefs.getString('profileImage') ?? '';
    });
    FirebaseCrashlytics.instance.setUserIdentifier(id);

    print('object' + id);
  }

  @override
  Widget build(BuildContext context) {
    CardController controller; //Use this to trigger swap.
    return WillPopScope(
      onWillPop: () async => false,
      child: Stack(
        children: [
          Scaffold(
            key: _scaffoldKey,
            drawer: ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(32.0),
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
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ProfilePage(
                                                token: widget.token,
                                              ),
                                            ));
                                      },
                                      child: Container(
                                        width: 64,
                                        height: 64,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          child: CachedNetworkImage(
                                            fit: BoxFit.cover,
                                            imageUrl: profileImage != null
                                                ? profileImage
                                                : 'https://via.placeholder.com/1080?text=No+Photo',
                                            placeholder: (context, url) => Center(
                                                child:
                                                    CircularProgressIndicator()),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Icon(Icons.error),
                                          ),
                                        ),
                                        decoration: new BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(16)),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                          left: 1, top: 14, right: 6),
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
                                        workStatus,
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
                                builder: (context) => ProfilePage(
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
                        onTap: () => {
                          Navigator.pop(context),
                          _controller.animateToPage(
                            2,
                            duration: Duration(milliseconds: 300),
                            curve: Curves.linear,
                          )
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
                                builder: (context) => Payment(
                                  token: widget.token,
                                ),
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
                            _launchPrivacy();
                          }),
                      ListTile(
                        title: Row(
                          children: [
                            Icon(FeatherIcons.file),
                            SizedBox(
                              width: 10,
                            ),
                            Text('Terms of Use'),
                          ],
                        ),
                        onTap: () {
                          _launchTerms();
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
              brightness: Brightness.light,
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
                  physics: new NeverScrollableScrollPhysics(),
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
                    }
                    if (value == 0) {
                      setState(() {
                        title = 'Meet Someone';
                        leading = IconButton(
                          icon: new Icon(FeatherIcons.menu),
                          onPressed: () =>
                              _scaffoldKey.currentState.openDrawer(),
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
                    if (value == 2) {
                      setState(() {
                        title = '';
                        leading = IconButton(
                          icon: Icon(
                            FeatherIcons.chevronLeft,
                            color: AppColors.primaryText,
                          ),
                          onPressed: () => _controller.animateToPage(
                            0,
                            duration: Duration(milliseconds: 300),
                            curve: Curves.linear,
                          ),
                        );
                        actions = [];
                      });
                    }
                  },
                  children: [
                    // SwipeScreen(
                    //   token: widget.token,
                    //   locationFilter: locationFilter,
                    // ),
                    Center(
                      child: Stack(
                        children: [
                          Center(
                            child: StreamBuilder(
                                stream: swipeBloc.swipeSugStream,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    switch (snapshot.data.status) {
                                      case Status.LOADING:
                                        print('swipeSug');
                                        print(swipeSug);
                                        if (swipeSug == null)
                                          return Container(
                                            height: 410,
                                            child: Center(
                                                child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                CircularProgressIndicator(
                                                  backgroundColor: AppColors
                                                      .secondaryElement,
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
                                        print('eeerrr');
                                        swipeBloc.swipeSugSink
                                            .add(ApiResponse.idle('message '));
                                        if (snapshot.data.message != 'null') {
                                          print(snapshot.data.message);
                                          try {
                                            if (json.decode(snapshot.data
                                                    .message)['responseCode'] ==
                                                'INVALID_TOKEN') {
                                              _logout();
                                              print('expire');
                                              myCallback(() {
                                                Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          Login(),
                                                    ));
                                              });
                                            }
                                          } on FormatException catch (e) {
                                            print(snapshot.data.message);
                                          }
                                        }
                                        return Container(
                                          height: 410,
                                          child: Center(
                                              child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                  'Error finding new matches...'),
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
                                                onPressed: () =>
                                                    _getSwipeSuggestions(),
                                              )
                                            ],
                                          )),
                                        );
                                        break;
                                      case Status.DONE:
                                        swipeBloc.swipeSugSink
                                            .add(ApiResponse.idle('message '));
                                        swipeSug = snapshot.data.data.data;
                                        // saveObject(widget.token, 'swipeSug',
                                        //     snapshot.data.data.data);
                                        myCallback(() {
                                          setState(() {});
                                        });
                                        toSwipe = swipeSug.profiles.length;
                                        swipesLeft =
                                            snapshot.data.data.data.swipesLeft;
                                        disableSwipe =
                                            swipesLeft == 0 ? true : false;
                                        print(swipesLeft);

                                        break;
                                      default:
                                    }
                                  }
                                  if (swipeSug != null) {
                                    return toSwipe > 0
                                        ? Column(
                                            children: [
                                              Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.6,
                                                child: new TinderSwapCard(
                                                  swipeUp: false,
                                                  swipeDown: false,
                                                  orientation:
                                                      AmassOrientation.TOP,
                                                  totalNum:
                                                      swipeSug.profiles.length,
                                                  stackNum: 3,
                                                  swipeEdge: 1.0,
                                                  maxWidth:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.9,
                                                  maxHeight:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.9,
                                                  minWidth:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.8,
                                                  minHeight:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.8,
                                                  cardBuilder:
                                                      (context, index) =>
                                                          InkWell(
                                                    onTapDown: (value) {
                                                      Navigator.of(context).push(
                                                          new PageRouteBuilder(
                                                        pageBuilder:
                                                            (_, __, ___) =>
                                                                new DetailPage(
                                                          type: swipeSug
                                                              .profiles[index],
                                                          from: 'SWIPE',
                                                          token: widget.token,
                                                        ),
                                                      ));
                                                      print('swipesLeft');
                                                      print(swipesLeft);
                                                      if (swipesLeft == 0) {
                                                        _showUpgrade();
                                                      }
                                                    },
                                                    onTap: () => {print(index)},
                                                    child: Card(
                                                      child: Stack(
                                                        children: [
                                                          Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.9,
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.9,
                                                            child:
                                                                CachedNetworkImage(
                                                                    placeholder:
                                                                        (context,
                                                                                url) =>
                                                                            Center(
                                                                              child: CircularProgressIndicator(),
                                                                            ),
                                                                    imageUrl:
                                                                        '${swipeSug.profiles[index].profileImage}',
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    errorWidget: (context,
                                                                            url,
                                                                            error) =>
                                                                        Center(
                                                                          child:
                                                                              Text('Unable to load photo.'),
                                                                        )),
                                                          ),
                                                          Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.9,
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.9,
                                                            decoration:
                                                                BoxDecoration(
                                                                    gradient: LinearGradient(
                                                                        begin: FractionalOffset
                                                                            .topCenter,
                                                                        end: FractionalOffset
                                                                            .bottomCenter,
                                                                        colors: [
                                                                  Colors.black
                                                                      .withOpacity(
                                                                          0),
                                                                  AppColors
                                                                      .primaryElement
                                                                      .withOpacity(
                                                                          0.8),
                                                                ],
                                                                        stops: [
                                                                  0.6,
                                                                  1.0
                                                                ])),
                                                          ),
                                                          Positioned(
                                                            top: 15,
                                                            right: 15,
                                                            child: Align(
                                                              alignment:
                                                                  Alignment
                                                                      .topCenter,
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Color
                                                                      .fromARGB(
                                                                          61,
                                                                          0,
                                                                          0,
                                                                          0),
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              16)),
                                                                ),
                                                                child:
                                                                    Container(
                                                                  margin:
                                                                      EdgeInsets
                                                                          .all(
                                                                              7),
                                                                  child: Text(
                                                                    "${swipeSug.profiles[index].distanceInKm != 0 ? swipeSug.profiles[index].distanceInKm : 1}km away",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style:
                                                                        TextStyle(
                                                                      color: AppColors
                                                                          .secondaryText,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      fontSize:
                                                                          12,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Positioned(
                                                            bottom: 31,
                                                            child: Column(
                                                              children: [
                                                                Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .topCenter,
                                                                  child:
                                                                      Container(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.9,
                                                                    margin: EdgeInsets.only(
                                                                        bottom:
                                                                            6),
                                                                    child: Text(
                                                                      '${swipeSug.profiles[index].firstName} ${swipeSug.profiles[index].lastName}, ${swipeSug.profiles[index].age}',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          TextStyle(
                                                                        fontFamily:
                                                                            'Berkshire Swash',
                                                                        color: AppColors
                                                                            .secondaryText,
                                                                        fontWeight:
                                                                            FontWeight.w400,
                                                                        fontSize:
                                                                            24,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Container(
                                                                  height: 40,
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          left:
                                                                              10,
                                                                          right:
                                                                              10),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Color
                                                                        .fromARGB(
                                                                            61,
                                                                            255,
                                                                            255,
                                                                            255),
                                                                    borderRadius:
                                                                        Radii
                                                                            .k8pxRadius,
                                                                  ),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Container(
                                                                        child:
                                                                            Text(
                                                                          '${swipeSug.profiles[index].workStatus}',
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                AppColors.secondaryText,
                                                                            fontWeight:
                                                                                FontWeight.w400,
                                                                            fontSize:
                                                                                16,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          if (swipeRight)
                                                            Container(
                                                              color: AppColors
                                                                  .ternaryBackground
                                                                  .withOpacity(
                                                                      0.3),
                                                              child: Center(
                                                                child: Icon(
                                                                    FeatherIcons
                                                                        .heart),
                                                              ),
                                                            ),
                                                          if (swipeLeft)
                                                            Container(
                                                              color: AppColors
                                                                  .secondaryElement
                                                                  .withOpacity(
                                                                      0.3),
                                                              child: Center(
                                                                child: Icon(
                                                                    FeatherIcons
                                                                        .x),
                                                              ),
                                                            )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  cardController: controller =
                                                      CardController(),
                                                  swipeUpdateCallback:
                                                      (DragUpdateDetails
                                                              details,
                                                          Alignment align) {
                                                    swipesLeft == 0
                                                        ? _showUpgrade()
                                                        : null;
                                                    print(swipesLeft);

                                                    /// Get swiping card's alignment
                                                    if (align.x < 0) {
                                                      swipeLeft = true;
                                                      swipeRight = false;
                                                      //Card is swipeLeft swiping
                                                    } else if (align.x > 0) {
                                                      swipeRight = true;
                                                      swipeLeft = false;
                                                      //Card is RIGHT swiping
                                                    }
                                                  },
                                                  swipeCompleteCallback:
                                                      (CardSwipeOrientation
                                                              orientation,
                                                          int index) {
                                                    /// Get orientation & index of swiped card!

                                                    if (orientation !=
                                                        CardSwipeOrientation
                                                            .RECOVER) {
                                                      setState(() {
                                                        swipeLeft = false;
                                                        swipeRight = false;
                                                        toSwipe = toSwipe - 1;
                                                        swipesLeft =
                                                            swipesLeft - 1;
                                                      });
                                                    }
                                                    print(orientation);

                                                    if (orientation ==
                                                        CardSwipeOrientation
                                                            .LEFT) {
                                                      print(swipeSug
                                                          .profiles[index].id);
                                                      dismissImg(swipeSug
                                                          .profiles[index].id);
                                                    }
                                                    if (orientation ==
                                                        CardSwipeOrientation
                                                            .RIGHT) {
                                                      print('right');
                                                      addImg(swipeSug
                                                          .profiles[index].id);
                                                    }
                                                  },
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  RawMaterialButton(
                                                    onPressed: () {
                                                      if (swipesLeft == 0) {
                                                        _showUpgrade();
                                                        return null;
                                                      }
                                                      controller.triggerLeft();
                                                    },
                                                    elevation: 2.0,
                                                    fillColor: Color.fromARGB(
                                                        255, 142, 198, 63),
                                                    child: Icon(
                                                      FeatherIcons.x,
                                                      color: AppColors
                                                          .secondaryText,
                                                    ),
                                                    padding:
                                                        EdgeInsets.all(15.0),
                                                    shape: CircleBorder(),
                                                  ),
                                                  RawMaterialButton(
                                                    onPressed: () {
                                                      if (swipesLeft == 0) {
                                                        _showUpgrade();
                                                        return null;
                                                      }
                                                      controller.triggerRight();
                                                    },
                                                    elevation: 2.0,
                                                    fillColor: AppColors
                                                        .secondaryElement,
                                                    child: Icon(
                                                      Icons.favorite,
                                                      color: AppColors
                                                          .secondaryText,
                                                    ),
                                                    padding:
                                                        EdgeInsets.all(23.0),
                                                    shape: CircleBorder(),
                                                  ),
                                                ],
                                              ),
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
                                                    color: AppColors
                                                        .secondaryElement,
                                                    child: Text(
                                                      'Try Again',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                    onPressed: () =>
                                                        _getSwipeSuggestions())
                                              ],
                                            )),
                                          );
                                  } else {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  }
                                }),
                          ),
                          swipesLeft == 0
                              ? GestureDetector(
                                  onTap: () =>
                                      {print(swipesLeft), _showUpgrade()},
                                  onPanUpdate: (e) => _showUpgrade(),
                                  child: Container(
                                    color: Colors.transparent,
                                  ),
                                )
                              : Container()
                        ],
                      ),
                    ),

                    Messages(
                      token: widget.token,
                    ),
                    Container(
                      color: Colors.white,
                      child: ListView(
                        padding: EdgeInsets.all(16),
                        children: [
                          Row(
                            children: [
                              Text(
                                "Today's Playlist",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontFamily: 'Berkshire Swash',
                                  color: AppColors.primaryText,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 32,
                                ),
                              ),
                              Spacer(),
                              IconButton(
                                onPressed: () => {_showDialog()},
                                color: AppColors.secondaryElement,
                                icon: Icon(FeatherIcons.plus),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 18,
                          ),
                          StreamBuilder(
                              stream: bloc.musicStream,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  switch (snapshot.data.status) {
                                    case Status.LOADING:
                                      return Center(
                                        child: Container(),
                                      );
                                      break;
                                    case Status.DONE:
                                      featured =
                                          snapshot.data.data.data.content;

                                      break;
                                    case Status.ERROR:
                                      break;
                                    default:
                                  }
                                }
                                return Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.3,
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: featured.length,
                                      itemBuilder: (context, index) {
                                        return Card(
                                          clipBehavior:
                                              Clip.antiAliasWithSaveLayer,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: Radii.k8pxRadius,
                                          ),
                                          child: Stack(
                                            children: [
                                              Image(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.3,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.5,
                                                fit: BoxFit.cover,
                                                image: NetworkImage(
                                                  featured[index].artworkUrl,
                                                ),
                                              ),
                                              Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.3,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.5,
                                                decoration: BoxDecoration(
                                                    color: Colors.black,
                                                    gradient: LinearGradient(
                                                        begin: FractionalOffset
                                                            .topCenter,
                                                        end: FractionalOffset
                                                            .bottomCenter,
                                                        colors: [
                                                          Colors.transparent,
                                                          Colors.black
                                                              .withOpacity(0.7),
                                                        ],
                                                        stops: [
                                                          0.6,
                                                          1.0
                                                        ])),
                                              ),
                                              Positioned(
                                                bottom: 18,
                                                left: 18,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      featured[index].title,
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color: AppColors
                                                            .secondaryText,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 22,
                                                      ),
                                                    ),
                                                    Text(
                                                      featured[index].artist,
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color: AppColors
                                                            .secondaryText
                                                            .withOpacity(0.8),
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        );
                                      }),
                                );
                              }),
                          SizedBox(
                            height: 18,
                          ),
                          StreamBuilder(
                              stream: bloc.musicStream,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  switch (snapshot.data.status) {
                                    case Status.LOADING:
                                      return Center(
                                          child: CircularProgressIndicator());
                                      break;
                                    case Status.DONE:
                                      songs = snapshot.data.data.data.content;

                                      break;
                                    case Status.ERROR:
                                      bloc.musicSink
                                          .add(ApiResponse.idle('message'));
                                      try {
                                        Fluttertoast.showToast(
                                            msg: json.decode(snapshot
                                                .data.message)['message']);
                                      } on FormatException {
                                        Fluttertoast.showToast(
                                            msg: snapshot.data.message);
                                      }
                                      break;
                                    default:
                                  }
                                }
                                return Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.7,
                                  child: ListView.builder(
                                      scrollDirection: Axis.vertical,
                                      itemCount: songs.length,
                                      itemBuilder: (context, index) {
                                        return ListTile(
                                          leading: Icon(
                                            FeatherIcons.music,
                                            color: AppColors.secondaryElement,
                                          ),
                                          trailing: ClipOval(
                                            child: Material(
                                              color: AppColors
                                                  .secondaryElement, // button color
                                              child: InkWell(
                                                child: SizedBox(
                                                  width: 56,
                                                  height: 56,
                                                  child: SizedBox(
                                                      width: 48,
                                                      height: 48,
                                                      child: Icon(
                                                        FeatherIcons.play,
                                                        color: Colors.white,
                                                      )),
                                                ),
                                                onTap: () async {
                                                  // AudioService.stop();
                                                  // _changeQueue(songs[index].songUrl);
                                                  // await AudioService.stop();
                                                  List orderSong = [];
                                                  List append = [];
                                                  for (int i = 0;
                                                      i < songs.length;
                                                      i++) {
                                                    if (index <= i) {
                                                      orderSong.add(songs[i]);
                                                    } else {
                                                      append.add(songs[i]);
                                                    }
                                                  }
                                                  orderSong.addAll(append);
                                                  var m;

                                                  print('play');
                                                  if (AudioService.running) {
                                                    AudioService
                                                        .skipToQueueItem(
                                                            songs[index]
                                                                .songUrl);
                                                    return;
                                                  }
                                                  List<dynamic> list = [];
                                                  orderSong.forEach(
                                                    (element) => {
                                                      m = MediaItem(
                                                        id: element.songUrl,
                                                        album: element.title,
                                                        title: element.title,
                                                        artist: element.artist,
                                                        artUri:
                                                            element.artworkUrl,
                                                      ).toJson(),
                                                      list.add(m)
                                                    },
                                                  );
                                                  var params = {"data": list};
                                                  _startAudioPlayerBtn(params);

                                                  // bloc.musicSink
                                                  //     .add(ApiResponse.play(orderSong));
                                                  // setState(() {
                                                  //   _currentPlay = index;
                                                  //   _queue = songs;
                                                  //   url = _queue[index].songUrl;
                                                  //   songs.forEach((element) {
                                                  //     element.isPlaying = false;
                                                  //   });
                                                  //   songs[index].isPlaying = true;
                                                  // });
                                                  // _play();
                                                },
                                              ),
                                            ),
                                          ),
                                          title: Text(songs[index].title),
                                          subtitle: Text(songs[index].artist),
                                        );
                                      }),
                                );
                              }),
                        ],
                      ),
                    )
                    // Advanced()
                  ],
                ),
                StreamBuilder(
                    stream: bloc.musicStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        switch (snapshot.data.status) {
                          case Status.LOADING:
                            return Center(
                              child: Container(),
                            );
                            break;
                          case Status.GETMUSICLIST:
                            // bloc.musicSink.add(ApiResponse.play(
                            //     snapshot.data.data));
                            break;
                          case Status.DONE:
                            print(snapshot.data.songs);
                            var m;
                            List<dynamic> list = List();
                            snapshot.data.data.data.content.forEach(
                              (element) => {
                                m = MediaItem(
                                  id: element.songUrl,
                                  album: element.title,
                                  title: element.title,
                                  artist: element.artist,
                                  duration: Duration(milliseconds: 5739820),
                                  artUri: element.artworkUrl,
                                ).toJson(),
                                list.add(m)
                              },
                            );
                            var params = {"data": list};
                            // _startAudioPlayerBtn(params);
                            break;
                          case Status.ERROR:
                            break;
                          default:
                        }
                      }

                      return AudioServiceWidget(
                        child: StreamBuilder<AudioState>(
                          stream: _audioStateStream,
                          builder: (context, snapshot) {
                            final audioState = snapshot.data;
                            final queue = audioState?.queue;
                            final mediaItem = audioState?.mediaItem;
                            final playbackState = audioState?.playbackState;
                            final processingState =
                                playbackState?.processingState ??
                                    AudioProcessingState.none;
                            playing = playbackState?.playing ?? false;
                            print('playbackState $playing');
                            if (AudioService.running)
                              return Positioned.fill(
                                bottom: 25,
                                child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      padding:
                                          EdgeInsets.only(right: 20, left: 20),
                                      decoration: BoxDecoration(
                                          color: AppColors.secondaryElement,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20))),
                                      height: 80,
                                      width: MediaQuery.of(context).size.width *
                                          .8,
                                      child: Container(
                                          child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            if (processingState !=
                                                AudioProcessingState.none) ...[
                                              if (mediaItem?.title != null)
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Flexible(
                                                        child: Text(
                                                      mediaItem.artist,
                                                      style: TextStyle(
                                                          color: Color.fromARGB(
                                                              180,
                                                              255,
                                                              255,
                                                              255),
                                                          fontSize: 12),
                                                    )),
                                                    Flexible(
                                                        child: Text(
                                                      mediaItem.title,
                                                      style: TextStyle(
                                                          color: AppColors
                                                              .secondaryText,
                                                          fontSize: 16),
                                                    )),
                                                  ],
                                                ),
                                              Spacer(),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  IconButton(
                                                    icon: Icon(
                                                      FeatherIcons.skipBack,
                                                      color: Colors.white,
                                                    ),
                                                    iconSize: 30,
                                                    onPressed: () {
                                                      if (mediaItem ==
                                                          queue.first) {
                                                        return;
                                                      }
                                                      AudioService
                                                          .skipToPrevious();
                                                    },
                                                  ),
                                                  !playing
                                                      ? IconButton(
                                                          icon: Icon(
                                                            FeatherIcons
                                                                .playCircle,
                                                            color: Colors.white,
                                                          ),
                                                          iconSize: 30.0,
                                                          onPressed:
                                                              AudioService.play,
                                                        )
                                                      : IconButton(
                                                          icon: Icon(
                                                            FeatherIcons
                                                                .pauseCircle,
                                                            color: Colors.white,
                                                          ),
                                                          iconSize: 30.0,
                                                          onPressed:
                                                              AudioService
                                                                  .pause,
                                                        ),
                                                  IconButton(
                                                    icon: Icon(
                                                      FeatherIcons.skipForward,
                                                      color: Colors.white,
                                                    ),
                                                    iconSize: 30,
                                                    onPressed: () {
                                                      if (mediaItem ==
                                                          queue.last) {
                                                        return;
                                                      }
                                                      AudioService.skipToNext();
                                                    },
                                                  ),
                                                  // IconButton(
                                                  //   icon: Icon(
                                                  //     FeatherIcons.stopCircle,
                                                  //     color: Colors.white,
                                                  //   ),
                                                  //   iconSize: 30.0,
                                                  //   onPressed: AudioService.stop,
                                                  // ),
                                                ],
                                              )
                                            ]
                                          ],
                                        ),
                                      )),
                                    )),
                              );

                            return Container();
                          },
                        ),
                      );
                    })
              ],
            ),
          ),
          StreamBuilder(
              stream: swipeBloc.swipeStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  switch (snapshot.data.status) {
                    case Status.DONE:
                      dynamic js = json.encode(snapshot.data.data.data);
                      js = json.decode(js);
                      dynamic swipee = js['swipe']['swipee'];
                      print('asda ${swipee['profileImage']}');
                      if (js['match'] == false) {
                        swipeBloc.swipeSink.add(ApiResponse.idle('message'));
                        return Container();
                      }
                      return Scaffold(
                        body: Container(
                          color: Color.fromRGBO(245, 253, 237, 1),
                          child: Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Spacer(),
                                Text(
                                  'We have a match',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontFamily: 'Berkshire Swash',
                                    fontWeight: FontWeight.w400,
                                    color: Color.fromRGBO(142, 198, 63, 1),
                                  ),
                                ),
                                Spacer(),
                                Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.4,
                                  child: Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      Positioned(
                                        left: 50,
                                        child: CircleAvatar(
                                          backgroundColor:
                                              AppColors.secondaryElement,
                                          radius: 105,
                                          child: CircleAvatar(
                                            radius: 100,
                                            backgroundColor:
                                                AppColors.secondaryElement,
                                            backgroundImage: NetworkImage(
                                              'https://via.placeholder.com/1080',
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 0,
                                        right: 50,
                                        child: CircleAvatar(
                                          backgroundColor:
                                              Color.fromRGBO(142, 198, 63, 1),
                                          radius: 105,
                                          child: CircleAvatar(
                                            radius: 100,
                                            backgroundColor:
                                                Color.fromRGBO(142, 198, 63, 1),
                                            backgroundImage: NetworkImage(
                                              'https://via.placeholder.com/1080',
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 140,
                                        left: 180,
                                        child: CircleAvatar(
                                          backgroundColor:
                                              Color.fromRGBO(255, 255, 255, 1),
                                          radius: 40,
                                          child: CircleAvatar(
                                            radius: 35,
                                            child: Container(
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    gradient: LinearGradient(
                                                        colors: [
                                                          AppColors
                                                              .secondaryElement,
                                                          Color.fromRGBO(
                                                              142, 198, 63, 1),
                                                        ],
                                                        begin: Alignment
                                                            .bottomLeft,
                                                        end: Alignment
                                                            .topRight)),
                                                child: CircleAvatar(
                                                    radius: 35,
                                                    child: Icon(
                                                        FeatherIcons.heart),
                                                    backgroundColor:
                                                        Colors.transparent)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Spacer(),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: RaisedButton(
                                    child: Padding(
                                      padding: const EdgeInsets.all(18.0),
                                      child: Text(
                                        'Work My Magic',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    onPressed: () {
                                      swipeBloc.swipeSink
                                          .add(ApiResponse.idle('message'));
                                      // Navigator.push(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //       builder: (context) => Chat(
                                      //         peerAvatar:
                                      //             swipee['profileImage'],
                                      //         peerId: swipee['id'].toString(),
                                      //         peerName: swipee['firstName'],
                                      //       ),
                                      //     ));
                                    },
                                    color: AppColors.secondaryElement,
                                  ),
                                ),
                                SizedBox(height: 18),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: RaisedButton(
                                    child: Padding(
                                      padding: const EdgeInsets.all(18.0),
                                      child: Text(
                                        'Talk Later... Keep Swiping',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    color: Color.fromRGBO(142, 198, 63, 1),
                                    onPressed: () {
                                      swipeBloc.swipeSink
                                          .add(ApiResponse.idle('message'));
                                    },
                                  ),
                                ),
                                Spacer(),
                              ],
                            ),
                          ),
                        ),
                      );

                      break;
                    default:
                  }
                }
                return Container();
              }),
        ],
      ),
    );
  }

  _showDialog() async {
    await showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Request for Song',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontFamily: 'Berkshire Swash',
                  color: AppColors.secondaryElement,
                  fontWeight: FontWeight.w400,
                  fontSize: 24,
                ),
              ),
              contentPadding: const EdgeInsets.all(16.0),
              content: StreamBuilder(
                  stream: bloc.songStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      switch (snapshot.data.status) {
                        case Status.LOADING:
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Center(child: CircularProgressIndicator()),
                            ],
                          );
                          break;

                        case Status.ERROR:
                          bloc.songSink.add(ApiResponse.idle('message'));
                          myCallback(() {
                            setState(() {
                              allowSend = true;
                            });
                          });

                          try {
                            Fluttertoast.showToast(
                                msg: json
                                    .decode(snapshot.data.message)['message']);
                          } on FormatException {
                            Fluttertoast.showToast(msg: snapshot.data.message);
                          }
                          break;
                        case Status.SONGREQUEST:
                          print('done');
                          bloc.songSink.add(ApiResponse.idle('message'));
                          myCallback(() {
                            setState(() {
                              allowSend = true;
                            });
                          });
                          Navigator.pop(context);
                          Fluttertoast.showToast(
                              msg: 'Song request submitted successfully');
                          break;
                        default:
                      }
                    }
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                            "Tell us about the song you'd like to add and we would add it to tomorrow's playlist"),
                        new TextFormField(
                          controller: descController,
                          autofocus: true,
                          decoration: new InputDecoration(
                            prefixIcon: Icon(FeatherIcons.music),
                            labelText: 'Song Description',
                            hintText: 'eg. Joro by Layon ft. Elhi',
                            focusedBorder: UnderlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.green, width: 2.0),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
              actions: <Widget>[
                new FlatButton(
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: AppColors.primaryText),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
                allowSend == true
                    ? FlatButton(
                        color: AppColors.secondaryElement,
                        child: const Text('Send Song Request'),
                        onPressed: () {
                          setState(() {
                            allowSend = false;
                          });
                          var request = {
                            "description": descController.text,
                            "id": 0,
                            "requester": {
                              "active": true,
                              "dateOfBirth": "2020-10-27T22:29:06.265Z",
                              "email": "string",
                              "emailVerified": true,
                              "firstName": "string",
                              "gender": "MALE",
                              "id": 0,
                              "lastName": "string",
                              "phone": "string",
                              "phoneVerified": true,
                              "profileImage": "string",
                              "suspended": true,
                              "type": "FREE"
                            }
                          };
                          bloc.songRequest(request, widget.token);
                          // Navigator.pop(context);
                        })
                    : Container()
              ],
            );
          },
        );
      },
    );
  }

  _showUpgrade() async {
    await showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
                title: Text(
                  'Upgrade',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Berkshire Swash',
                    color: AppColors.secondaryElement,
                    fontWeight: FontWeight.w400,
                    fontSize: 24,
                  ),
                ),
                contentPadding: const EdgeInsets.all(16.0),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'You are out of swipes for today.',
                      textAlign: TextAlign.center,
                    ),
                    FlatButton(
                      color: AppColors.secondaryElement,
                      child: Text(
                        'Subscribe',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () => {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Payment(
                                token: widget.token,
                              ),
                            ))
                      },
                    )
                  ],
                ));
          },
        );
      },
    );
  }

  _startAudioPlayerBtn(params) async {
    await AudioService.start(
      backgroundTaskEntrypoint: _audioPlayerTaskEntrypoint,
      androidNotificationChannelName: 'Audio Player',
      androidNotificationColor: 0xFF2196f3,
      androidNotificationIcon: 'mipmap/ic_launcher',
      params: params,
    );
    setState(() {});
  }

  Widget positionIndicator(MediaItem mediaItem, PlaybackState state) {
    double seekPos;
    return StreamBuilder(
      stream: Rx.combineLatest2<double, double, double>(
          _dragPositionSubject.stream,
          Stream.periodic(Duration(milliseconds: 200)),
          (dragPosition, _) => dragPosition),
      builder: (context, snapshot) {
        double position =
            snapshot.data ?? state.currentPosition.inMilliseconds.toDouble();
        double duration = mediaItem?.duration?.inMilliseconds?.toDouble();
        return Column(
          children: [
            if (duration != null)
              Slider(
                min: 0.0,
                max: duration,
                value: seekPos ?? max(0.0, min(position, duration)),
                onChanged: (value) {
                  _dragPositionSubject.add(value);
                },
                onChangeEnd: (value) {
                  AudioService.seekTo(Duration(milliseconds: value.toInt()));
                  // Due to a delay in platform channel communication, there is
                  // a brief moment after releasing the Slider thumb before the
                  // new position is broadcast from the platform side. This
                  // hack is to hold onto seekPos until the next state update
                  // comes through.
                  // TODO: Improve this code.
                  seekPos = value;
                  _dragPositionSubject.add(null);
                },
              ),
            Text("${state.currentPosition}"),
          ],
        );
      },
    );
  }
}

Stream<AudioState> get _audioStateStream {
  return Rx.combineLatest3<List<MediaItem>, MediaItem, PlaybackState,
      AudioState>(
    AudioService.queueStream,
    AudioService.currentMediaItemStream,
    AudioService.playbackStateStream,
    (queue, mediaItem, playbackState) => AudioState(
      queue,
      mediaItem,
      playbackState,
    ),
  );
}

void _audioPlayerTaskEntrypoint() async {
  AudioServiceBackground.run(() => AudioPlayerTask());
}

void myCallback(Function callback) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    callback();
  });
}
