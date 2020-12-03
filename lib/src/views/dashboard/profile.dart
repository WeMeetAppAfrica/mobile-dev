import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wemeet/src/SwipeAnimation/detail.dart';
import 'package:wemeet/src/blocs/bloc.dart';
import 'package:wemeet/src/blocs/swipe_bloc.dart';
import 'package:wemeet/src/models/profilemodel.dart';
import 'package:wemeet/src/models/swipesuggestions.dart' as Pro;
import 'package:wemeet/src/resources/api_response.dart';
import 'package:wemeet/src/views/auth/kyc.dart';
import 'package:wemeet/src/views/auth/login.dart';
import 'package:wemeet/src/views/dashboard/blocked.dart';
import 'package:wemeet/src/views/dashboard/chat-screen.dart';
import 'package:wemeet/src/views/dashboard/chat-page.dart';
import 'package:wemeet/src/views/dashboard/payment.dart';
import 'package:wemeet/src/views/dashboard/updateProfile.dart';
import 'package:wemeet/src/views/dashboard/updatelocation.dart';
import 'package:wemeet/src/views/dashboard/updatepassword.dart';
import 'package:wemeet/src/views/dashboard/updatepicture.dart';
import 'package:wemeet/values/values.dart';

class ProfilePage extends StatefulWidget {
  final token;
  ProfilePage({Key key, this.token}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  List matches = [];
  var items = List();
  String locationFilter;
  bool toggleLocation = true;
  dynamic allowChangeLocation;
  SharedPreferences prefs;
  bool toggleProfile = false;
  bool toggleLoading = false;
  dynamic details;
  dynamic type;
  _ProfilePageState({this.type});
  double _appBarHeight = 500.0;
  AppBarBehavior _appBarBehavior = AppBarBehavior.pinned;

  void initState() {
    super.initState();
    _getUser();
    getObject(widget.token, 'profile');
    bloc.getProfile(widget.token);
    print('details $details');
    swipeBloc.getMatches(widget.token);
  }

  String _generateKey(String userId, String key) {
    return '$userId/$key';
  }

  @override
  void saveObject(String userId, String key, Data object) async {
    final prefs = await SharedPreferences.getInstance();
    // 1
    final string = JsonEncoder().convert(object);
    // 2
    print('string');
    print(string);
    await prefs.setString(_generateKey(userId, key), string);
  }

  @override
  Future<dynamic> getObject(String userId, String key) async {
    final prefs = await SharedPreferences.getInstance();
    // 3
    final objectString = prefs.getString(_generateKey(userId, key));
    // 4
    print('objectString');
    print(objectString);
    if (objectString != null) {
      print(Data.fromJson(
              JsonDecoder().convert(objectString) as Map<String, dynamic>)
          .id);
      setState(() {
        details = Data.fromJson(
            JsonDecoder().convert(objectString) as Map<String, dynamic>);
      });
      return Data.fromJson(
          JsonDecoder().convert(objectString) as Map<String, dynamic>);
    }
    return null;
  }

  @override
  Future<void> removeObject(String userId, String key) async {
    final prefs = await SharedPreferences.getInstance();
    // 5
    prefs.remove(_generateKey(userId, key));
  }

  _logout() async {
    bloc.logout({}, widget.token);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var locationFilter = prefs.getString('locationFilter');
    prefs.clear();
    prefs.setBool('passKYC', true);
    prefs.setString('locationFilter', locationFilter);
    prefs.setBool('passWalkthrough', true);
  }

  _getUser() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      locationFilter = prefs.getString('locationFilter') ?? 'true';
    });
  }

  _setPref() async {
    prefs = await SharedPreferences.getInstance();
    prefs.setString('locationFilter', locationFilter);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: new ThemeData(
        brightness: Brightness.light,
        primaryColor: AppColors.secondaryElement,
        platform: Theme.of(context).platform,
      ),
      child: Container(
        child: new Hero(
          tag: "img",
          child: new Material(
            color: Colors.transparent,
            child: new Container(
              alignment: Alignment.center,
              decoration: new BoxDecoration(
                color: Colors.white,
                borderRadius: new BorderRadius.circular(10.0),
              ),
              child: StreamBuilder(
                  stream: bloc.profileStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      switch (snapshot.data.status) {
                        case Status.LOADING:
                          if (details == null)
                            return Center(
                              child: Container(),
                            );
                          break;
                        case Status.GETPROFILE:
                          bloc.profileSink.add(ApiResponse.idle('message'));
                          details = snapshot.data.data.data;
                          saveObject(widget.token, 'profile', details);
                          toggleLocation = details.hideLocation;
                          toggleProfile = details.hideProfile;
                          allowChangeLocation = details.type;
                          break;
                        case Status.ERROR:
                          bloc.profileSink.add(ApiResponse.idle('message'));
                          try {
                            if (json.decode(
                                    snapshot.data.message)['responseCode'] ==
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
                          break;
                        default:
                      }
                    }
                    if (details != null) {
                      print('details.id');
                      print(details);
                      return DefaultTabController(
                        length: 4,
                        child: new Stack(
                          alignment: AlignmentDirectional.bottomCenter,
                          children: <Widget>[
                            new CustomScrollView(
                              shrinkWrap: false,
                              slivers: <Widget>[
                                new SliverAppBar(
                                  elevation: 0.0,
                                  forceElevated: true,
                                  leading: new IconButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    icon: new Icon(
                                      Icons.chevron_left,
                                      size: 30.0,
                                    ),
                                  ),
                                  expandedHeight: _appBarHeight,
                                  pinned:
                                      _appBarBehavior == AppBarBehavior.pinned,
                                  floating: _appBarBehavior ==
                                          AppBarBehavior.floating ||
                                      _appBarBehavior ==
                                          AppBarBehavior.snapping,
                                  snap: _appBarBehavior ==
                                      AppBarBehavior.snapping,
                                  flexibleSpace: Stack(
                                    children: [
                                      Positioned(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                          ),
                                        ),
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                      ),
                                      Positioned(
                                        child: Container(
                                          child: TabBar(
                                            indicator: CircleTabIndicator(
                                                color: Colors.white, radius: 3),
                                            tabs: [
                                              Tab(
                                                text: 'Bio',
                                              ),
                                              Tab(
                                                text: 'Matches',
                                              ),
                                              Tab(
                                                text: 'Privacy',
                                              ),
                                              Tab(
                                                text: 'Settings',
                                              ),
                                            ],
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.secondaryElement,
                                          ),
                                        ),
                                        bottom: 10,
                                        left: 0,
                                        right: 0,
                                      ),
                                      Positioned(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.vertical(
                                              bottom: Radius.circular(30),
                                            ),
                                            child: Image(
                                              fit: BoxFit.cover,
                                              image: NetworkImage(
                                                details.profileImage != null
                                                    ? details.profileImage
                                                    : 'https://via.placeholder.com/1080',
                                              ),
                                            ),
                                          ),
                                          top: 0,
                                          left: 0,
                                          right: 0,
                                          bottom: 70),
                                    ],
                                  ),
                                ),
                                new SliverList(
                                  delegate:
                                      new SliverChildListDelegate(<Widget>[
                                    new Container(
                                      height:
                                          MediaQuery.of(context).size.height,
                                      decoration: new BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            new BorderRadius.circular(30.0),
                                      ),
                                      child: TabBarView(
                                        children: [
                                          Column(
                                            children: [
                                              SizedBox(height: 18),
                                              Text(
                                                '${details.firstName} ${details.lastName}, ${details.age}',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontFamily: 'Berkshire Swash',
                                                  color: AppColors.primaryText,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 24,
                                                ),
                                              ),
                                              SizedBox(height: 20),
                                              ListTile(
                                                onTap: () => {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            UpdateProfile(),
                                                      ))
                                                },
                                                title: Text('Update Profile'),
                                                trailing: Icon(
                                                    FeatherIcons.chevronRight),
                                              ),
                                              ListTile(
                                                onTap: () => {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            UpdatePhotos(),
                                                      ))
                                                },
                                                title: Text('Update Photos'),
                                                trailing: Icon(
                                                    FeatherIcons.chevronRight),
                                              ),
                                            ],
                                          ),
                                          StreamBuilder(
                                              stream: swipeBloc.matchStream,
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {
                                                  switch (
                                                      snapshot.data.status) {
                                                    case Status.LOADING:
                                                      return Center(
                                                        child: Container(),
                                                      );
                                                      break;
                                                    case Status.DONE:
                                                      matches = snapshot.data
                                                          .data.data.content;
                                                      items = snapshot.data.data
                                                          .data.content;
                                                      swipeBloc.matchSink.add(
                                                          ApiResponse.idle(
                                                              'message'));
                                                      break;
                                                    default:
                                                  }
                                                }
                                                return Column(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 12.0,
                                                              top: 18),
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            'Matches',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Berkshire Swash',
                                                              color: AppColors
                                                                  .primaryText,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontSize: 24,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          // Text(
                                                          //   'people',
                                                          //   style: TextStyle(
                                                          //     color: AppColors
                                                          //         .accentText,
                                                          //     fontWeight:
                                                          //         FontWeight
                                                          //             .w400,
                                                          //     fontSize: 14,
                                                          //   ),
                                                          // ),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 16.0,
                                                              left: 12),
                                                      child: TextFormField(
                                                        onChanged: (value) {
                                                          print('items');
                                                          var list = matches
                                                              .where((f) =>
                                                                  f['firstName']
                                                                      .contains(
                                                                          value
                                                                              .toLowerCase()) ||
                                                                  f['lastName']
                                                                      .contains(
                                                                          value
                                                                              .toLowerCase()))
                                                              .toList();
                                                          setState(() {
                                                            items = list;
                                                          });
                                                          // setState(() {
                                                          //   items.clear();
                                                          //   items.addAll(matches.where((f) =>
                                                          //       f['firstName']
                                                          //           .contains(value
                                                          //               .toLowerCase()) ||
                                                          //       f['lastName']
                                                          //           .contains(value
                                                          //               .toLowerCase())));
                                                          // });
                                                          print(items);
                                                        },
                                                        decoration:
                                                            new InputDecoration(
                                                                prefixIcon: Icon(
                                                                    FeatherIcons
                                                                        .search),
                                                                fillColor: AppColors
                                                                    .secondaryBackground,
                                                                filled: true,
                                                                hintText:
                                                                    'Search',
                                                                focusedBorder:
                                                                    UnderlineInputBorder(
                                                                  borderSide: const BorderSide(
                                                                      color: Colors
                                                                          .green,
                                                                      width:
                                                                          2.0),
                                                                ),
                                                                border:
                                                                    InputBorder
                                                                        .none),
                                                      ),
                                                    ),
                                                    items.length > 0
                                                        ? Container(
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height -
                                                                320,
                                                            child: ListView
                                                                .builder(
                                                              itemCount:
                                                                  items.length,
                                                              itemBuilder:
                                                                  (context,
                                                                      index) {
                                                                return ListTile(
                                                                  onTap: () {
                                                                    Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              DetailPage(
                                                                            from:
                                                                                'MATCH',
                                                                            type:
                                                                                Pro.Profile.fromJson(items[index]),
                                                                          ),
                                                                        ));
                                                                  },
                                                                  leading:
                                                                      CachedNetworkImage(
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    height: 48,
                                                                    width: 48,
                                                                    imageUrl:
                                                                        '${items[index]['profileImage']}',
                                                                  ),
                                                                  title: Text(
                                                                      '${items[index]['firstName']} ${items[index]['lastName']}'),
                                                                  trailing:
                                                                      Wrap(
                                                                    spacing:
                                                                        12, // space between two icons
                                                                    children: <
                                                                        Widget>[
                                                                      IconButton(
                                                                        icon: Icon(
                                                                            FeatherIcons.messageSquare),
                                                                        onPressed:
                                                                            () =>
                                                                                {
                                                                          Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(
                                                                                builder: (context) => Chat(
                                                                                  token: widget.token,
                                                                                  peerAvatar: items[index]['profileImage'],
                                                                                  peerId: items[index]['id'].toString(),
                                                                                  peerName: items[index]['firstName'],
                                                                                ),
                                                                              ))
                                                                        },
                                                                      ), // icon-1
                                                                      IconButton(
                                                                        icon: Icon(
                                                                            FeatherIcons.trash),
                                                                        onPressed:
                                                                            () =>
                                                                                {
                                                                          bloc.block(
                                                                              items[index]['id'].toString(),
                                                                              widget.token),
                                                                        },
                                                                      ), // icon-2
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          )
                                                        : Container(
                                                            height: 200,
                                                            child: Center(
                                                                child: Text(
                                                                    'You have no matches'))),
                                                  ],
                                                );
                                              }),
                                          StreamBuilder(
                                              stream: bloc.profileLocStream,
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData) {
                                                  switch (
                                                      snapshot.data.status) {
                                                    case Status.LOADING:
                                                      toggleLoading = true;
                                                      Fluttertoast.showToast(
                                                          msg:
                                                              'Updating Privacy Settings');
                                                      break;
                                                    case Status.DONE:
                                                      bloc.profileLocSink.add(
                                                          ApiResponse.idle(
                                                              'message'));
                                                      toggleLoading = false;
                                                      print(snapshot.data.data
                                                          .data.hideLocation);
                                                      toggleLocation = snapshot
                                                          .data
                                                          .data
                                                          .data
                                                          .hideLocation;
                                                      toggleProfile = snapshot
                                                          .data
                                                          .data
                                                          .data
                                                          .hideProfile;
                                                      Fluttertoast.showToast(
                                                          msg:
                                                              'Privacy Settings Updated');
                                                      break;
                                                    default:
                                                  }
                                                }
                                                return Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: [
                                                    SizedBox(height: 18),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 12.0),
                                                      child: Text(
                                                        'Location Services',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Berkshire Swash',
                                                          color: AppColors
                                                              .accentText,
                                                          fontWeight:
                                                              FontWeight.w100,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                    ListTile(
                                                      onTap: () {
                                                        print(
                                                            allowChangeLocation);
                                                        if (allowChangeLocation ==
                                                            "FREE")
                                                          _showUpgrade();
                                                        else
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        UpdateLocation(
                                                                  token: widget
                                                                      .token,
                                                                ),
                                                              ));
                                                      },
                                                      title: Text(
                                                          'Change Location'),
                                                      subtitle: Text(
                                                          'Lagos, Nigeria'),
                                                      trailing: Icon(
                                                          FeatherIcons
                                                              .chevronRight),
                                                    ),
                                                    ListTile(
                                                      onTap: () {
                                                        bloc.updateProfileLoc({
                                                          "hideLocation":
                                                              !toggleLocation
                                                        }, widget.token);
                                                      },
                                                      title: Text(
                                                          'Turn On/Off Location'),
                                                      subtitle: Text(
                                                          'Decide wether users see your location'),
                                                      trailing: toggleLoading
                                                          ? SizedBox(
                                                              width: 10,
                                                              height: 10,
                                                              child:
                                                                  CircularProgressIndicator(
                                                                backgroundColor:
                                                                    AppColors
                                                                        .secondaryElement,
                                                              ))
                                                          : Icon(
                                                              toggleLocation
                                                                  ? FeatherIcons
                                                                      .toggleRight
                                                                  : FeatherIcons
                                                                      .toggleLeft,
                                                              color: toggleLocation
                                                                  ? AppColors
                                                                      .secondaryElement
                                                                  : null,
                                                            ),
                                                    ),
                                                    ListTile(
                                                      onTap: () {
                                                        setState(() {
                                                          locationFilter =
                                                              locationFilter ==
                                                                      'true'
                                                                  ? 'false'
                                                                  : 'true';
                                                        });
                                                        _setPref();
                                                      },
                                                      title: Text('Global'),
                                                      subtitle: Text(
                                                          'Going global will allow you to see people nearby and from around the world.'),
                                                      trailing: Icon(
                                                        locationFilter == 'true'
                                                            ? FeatherIcons
                                                                .toggleRight
                                                            : FeatherIcons
                                                                .toggleLeft,
                                                        color: locationFilter ==
                                                                'true'
                                                            ? AppColors
                                                                .secondaryElement
                                                            : null,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 12.0),
                                                      child: Text(
                                                        'Profile',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Berkshire Swash',
                                                          color: AppColors
                                                              .accentText,
                                                          fontWeight:
                                                              FontWeight.w100,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                    ListTile(
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      Blocked(
                                                                token: widget
                                                                    .token,
                                                              ),
                                                            ));
                                                      },
                                                      title:
                                                          Text('Blocked Users'),
                                                      subtitle: Text(
                                                          'See all users that have been blocked'),
                                                      trailing: Icon(
                                                          FeatherIcons
                                                              .chevronRight),
                                                    ),
                                                    ListTile(
                                                      onTap: () {
                                                        bloc.updateProfileLoc({
                                                          "hideProfile":
                                                              !toggleProfile
                                                        }, widget.token);
                                                      },
                                                      title: Text(
                                                          'Hide My Profile'),
                                                      subtitle: Text(
                                                          'Profile is currently visible'),
                                                      trailing: toggleLoading
                                                          ? SizedBox(
                                                              width: 10,
                                                              height: 10,
                                                              child:
                                                                  CircularProgressIndicator(
                                                                backgroundColor:
                                                                    AppColors
                                                                        .secondaryElement,
                                                              ))
                                                          : Icon(
                                                              toggleProfile
                                                                  ? FeatherIcons
                                                                      .toggleRight
                                                                  : FeatherIcons
                                                                      .toggleLeft,
                                                              color: toggleProfile
                                                                  ? AppColors
                                                                      .secondaryElement
                                                                  : null,
                                                            ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              16.0),
                                                      child: RaisedButton(
                                                        onPressed: () =>
                                                            {_showDialog()},
                                                        color: AppColors
                                                            .secondaryElement,
                                                        padding:
                                                            EdgeInsets.all(18),
                                                        child: Text(
                                                          'Deactivate My Account',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 18),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                );
                                              }),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              SizedBox(
                                                height: 18,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 12.0),
                                                child: Text(
                                                  'Password Settings',
                                                  style: TextStyle(
                                                    fontFamily:
                                                        'Berkshire Swash',
                                                    color: AppColors.accentText,
                                                    fontWeight: FontWeight.w100,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                              ListTile(
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            UpdatePassword(
                                                          token: widget.token,
                                                        ),
                                                      ));
                                                },
                                                title: Text('Change Password'),
                                                subtitle: Text(
                                                    'Update your WeMeet login password'),
                                                trailing: Icon(
                                                    FeatherIcons.chevronRight),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  }),
            ),
          ),
        ),
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
                'Confirm',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontFamily: 'Berkshire Swash',
                  color: AppColors.secondaryElement,
                  fontWeight: FontWeight.w400,
                  fontSize: 24,
                ),
              ),
              contentPadding: const EdgeInsets.all(16.0),
              content:
                  Text('Are you sure you want to deactivate your account?'),
              actions: <Widget>[
                FlatButton(
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.primaryText),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                StreamBuilder(
                    stream: bloc.userStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        switch (snapshot.data.status) {
                          case Status.LOADING:
                            return Center(
                              child: Container(),
                            );
                            break;
                          case Status.SELFDELETE:
                            bloc.userSink.add(ApiResponse.idle('message'));
                            Fluttertoast.showToast(msg: 'Profile Deactivated');
                            Navigator.pop(context);
                            _logout();
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Login(),
                                ),
                                (Route<dynamic> route) => false);
                            break;
                          default:
                        }
                      }
                      return FlatButton(
                        onPressed: () => {bloc.selfDelete(widget.token)},
                        color: AppColors.secondaryElement,
                        padding: EdgeInsets.all(18),
                        child: Text('Deactivate'),
                      );
                    }),
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

  void filterSearchResults(String query) {
    List dummyList = [];
    List copyList = matches;
    print('matches');

    print(matches
        .where((f) =>
            f['firstName'].contains(query.toLowerCase()) ||
            f['lastName'].contains(query.toLowerCase()))
        .toList());

    // if (query.isNotEmpty) {
    //   copyList.forEach((item) {
    //     print(item['firstName']);
    //     if (item['firstName'].toLowerCase().contains(query.toLowerCase()) ||
    //         item['lastName'].toLowerCase().contains(query.toLowerCase())) {
    //       print('item');
    //       dummyList.add(item);
    //       print(dummyList);
    //     }
    //   });
    //   setState(() {
    //     items.clear();
    //     items.addAll(dummyList);
    //   });
    // } else {
    //   print('matches jui');
    //   print(copyList);
    //   print('uyh $matches');
    //   setState(() {
    //     items.clear();
    //     items.addAll(copyList);
    //   });
    //   print('object');
    // }
  }
}

class CircleTabIndicator extends Decoration {
  final BoxPainter _painter;

  CircleTabIndicator({@required Color color, @required double radius})
      : _painter = _CirclePainter(color, radius);

  @override
  BoxPainter createBoxPainter([onChanged]) => _painter;
}

class _CirclePainter extends BoxPainter {
  final Paint _paint;
  final double radius;

  _CirclePainter(Color color, this.radius)
      : _paint = Paint()
          ..color = color
          ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    final Offset circleOffset =
        offset + Offset(cfg.size.width / 2, cfg.size.height - radius - 5);
    canvas.drawCircle(circleOffset, radius, _paint);
  }
}

void myCallback(Function callback) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    callback();
  });
}
