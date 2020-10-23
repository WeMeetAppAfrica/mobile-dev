import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:wemeet/src/SwipeAnimation/detail.dart';
import 'package:wemeet/src/blocs/bloc.dart';
import 'package:wemeet/src/blocs/swipe_bloc.dart';
import 'package:wemeet/src/models/swipesuggestions.dart';
import 'package:wemeet/src/resources/api_response.dart';
import 'package:wemeet/src/views/auth/kyc.dart';
import 'package:wemeet/src/views/dashboard/chat-screen.dart';
import 'package:wemeet/src/views/dashboard/updateProfile.dart';
import 'package:wemeet/src/views/dashboard/updatepassword.dart';
import 'package:wemeet/values/values.dart';

class Profile extends StatefulWidget {
  final token;
  Profile({Key key, this.token}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with TickerProviderStateMixin {
  List matches = [];
  var items = List();
  bool ki = true;
  dynamic details;
  dynamic type;
  _ProfileState({this.type});
  double _appBarHeight = 500.0;
  AppBarBehavior _appBarBehavior = AppBarBehavior.pinned;

  void initState() {
    super.initState();
    bloc.getProfile(widget.token);
    swipeBloc.getMatches(widget.token);
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
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                          break;
                        case Status.GETPROFILE:
                          details = snapshot.data.data.data;

                          break;
                        default:
                      }
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
                                      height: 700,
                                      decoration: new BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            new BorderRadius.circular(30.0),
                                      ),
                                      child: TabBarView(
                                        children: [
                                          ListView(
                                            children: [
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
                                              Center(
                                                child: FlatButton(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            18.0),
                                                  ),
                                                  onPressed: () => {},
                                                  color: Color.fromARGB(
                                                      255, 198, 156, 63),
                                                  child: Text(
                                                    'Unverified Account',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
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
                                                title:
                                                    Text('Update Preferences'),
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
                                                        child:
                                                            CircularProgressIndicator(),
                                                      );
                                                      break;
                                                    case Status.DONE:
                                                      matches = snapshot.data
                                                          .data.data.content;
                                                      items = snapshot.data.data
                                                          .data.content;
                                                      // swipeBloc.matchSink.add(
                                                      //     ApiResponse.idle(
                                                      //         'message'));
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
                                                          Text(
                                                            'people',
                                                            style: TextStyle(
                                                              color: AppColors
                                                                  .accentText,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontSize: 14,
                                                            ),
                                                          ),
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
                                                          // print(items);
                                                          filterSearchResults(
                                                              value);
                                                        },
                                                        decoration: new InputDecoration(
                                                            prefixIcon: Icon(
                                                                FeatherIcons
                                                                    .search),
                                                            fillColor: AppColors
                                                                .secondaryBackground,
                                                            filled: true,
                                                            hintText: 'Search',
                                                            border: InputBorder
                                                                .none),
                                                      ),
                                                    ),
                                                    Container(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height -
                                                              320,
                                                      child: ListView.builder(
                                                        itemCount: items.length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          return ListTile(
                                                            onTap: () {
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            DetailPage(
                                                                      type: Datum
                                                                          .fromJson(
                                                                              items[index]),
                                                                    ),
                                                                  ));
                                                            },
                                                            leading: Image(
                                                              height: 48,
                                                              image: NetworkImage(
                                                                  '${items[index]['profileImage']}'),
                                                            ),
                                                            title: Text(
                                                                '${items[index]['firstName']} ${items[index]['lastName']}'),
                                                            trailing: Wrap(
                                                              spacing:
                                                                  12, // space between two icons
                                                              children: <
                                                                  Widget>[
                                                                IconButton(
                                                                  icon: Icon(
                                                                      FeatherIcons
                                                                          .messageSquare),
                                                                  onPressed:
                                                                      () => {
                                                                    Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              Chat(
                                                                            peerAvatar:
                                                                                items[index]['profileImage'],
                                                                            peerId:
                                                                                items[index]['id'].toString(),
                                                                            peerName:
                                                                                items[index]['firstName'],
                                                                          ),
                                                                        ))
                                                                  },
                                                                ), // icon-1
                                                                IconButton(
                                                                  icon: Icon(
                                                                      FeatherIcons
                                                                          .trash),
                                                                  onPressed:
                                                                      () => {
                                                                    setState(
                                                                        () {
                                                                      ki =
                                                                          false;
                                                                    }),
                                                                    print(ki)
                                                                  },
                                                                ), // icon-2
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }),
                                          ListView(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 12.0),
                                                child: Text(
                                                  'Location Services',
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
                                                title: Text('Change Location'),
                                                subtitle:
                                                    Text('Lagos, Nigeria'),
                                                trailing: Icon(
                                                    FeatherIcons.chevronRight),
                                              ),
                                              ListTile(
                                                title: Text(
                                                    'Turn On/Off Location'),
                                                subtitle: Text(
                                                    'Decide wether users see your location'),
                                                trailing: Icon(
                                                  FeatherIcons.toggleRight,
                                                  color: AppColors
                                                      .secondaryElement,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 12.0),
                                                child: Text(
                                                  'Profile',
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
                                                title: Text('Blocked Users'),
                                                subtitle: Text(
                                                    'See all users that have been blocked'),
                                                trailing: Icon(
                                                    FeatherIcons.chevronRight),
                                              ),
                                              ListTile(
                                                title: Text('Hide My Profile'),
                                                subtitle: Text(
                                                    'Profile is currently visible'),
                                                trailing: Icon(
                                                  FeatherIcons.toggleLeft,
                                                  // color: AppColors.secondaryElement,
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(16.0),
                                                child: RaisedButton(
                                                  onPressed: () => {},
                                                  color: AppColors
                                                      .secondaryElement,
                                                  padding: EdgeInsets.all(18),
                                                  child: Text(
                                                    'Deactivate My Account',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                          ListView(
                                            children: [
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
                                                            UpdatePassword(),
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
                    }
                    return Container();
                  }),
            ),
          ),
        ),
      ),
    );
  }

  void filterSearchResults(String query) {
    List dummyList = [];
    List copyList = matches;
    if (query.isNotEmpty) {
      copyList.forEach((item) {
        print(item['firstName']);
        if (item['firstName'].toLowerCase().contains(query.toLowerCase()) ||
            item['lastName'].toLowerCase().contains(query.toLowerCase())) {
          print('item');
          dummyList.add(item);
          print(dummyList);
        }
      });
      print('matches');
      print(matches);
      setState(() {
        items.clear();
        items.addAll(dummyList);
      });
    } else {
      print('matches');
      print(matches);
      // setState(() {
      //   items.clear();
      //   items.addAll(copyList);
      // });
    }
    // setState(() {
    //   items = matches;
    // });
    // List dummySearchList = List();
    // dummySearchList.addAll(matches);
    // if (query.isNotEmpty) {
    //   print(query);
    //   print(matches);
    //   List dummyListData = List();
    //   matches.forEach((item) {
    //     print(item['firstName']);
    //     // if (item['firstName'].contains(query)) {
    //     //   dummyListData.add(item);
    //     // }
    //   });
    //   // setState(() {
    //   //   items.clear();
    //   //   items.addAll(dummyListData);
    //   // });
    //   return;
    // } else {
    //   print('matches');
    //   print(matches);
    //   print(items);
    //   setState(() {
    //     items.clear();
    //     items.addAll(matches);
    //   });
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
