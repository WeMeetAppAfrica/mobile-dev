import 'dart:convert';

import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tindercard/flutter_tindercard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wemeet/src/SwipeAnimation/activeCard.dart';
import 'package:wemeet/src/SwipeAnimation/data.dart';
import 'package:wemeet/src/SwipeAnimation/dummyCard.dart';
import 'package:wemeet/src/blocs/bloc.dart';
import 'package:wemeet/src/blocs/swipe_bloc.dart';
import 'package:wemeet/src/models/swipesuggestions.dart';
import 'package:wemeet/src/resources/api_response.dart';
import 'package:wemeet/src/views/auth/login.dart';
import 'package:wemeet/src/views/dashboard/payment.dart';
import 'package:wemeet/values/values.dart';
import 'package:flutter/scheduler.dart' show timeDilation;

class SwipeScreen extends StatefulWidget {
  final token;
  final locationFilter;
  SwipeScreen({Key key, this.token, this.locationFilter}) : super(key: key);

  @override
  _SwipeScreenState createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen>
    with TickerProviderStateMixin {
  AnimationController _buttonController;
  Animation<double> rotate;
  Animation<double> right;
  SharedPreferences prefs;
  Animation<double> bottom;
  Animation<double> width;
  int flag = 0;
  int swipesLeft = 0;
  bool disableSwipe = false;
  List data = [];
  dynamic swipeSug;
  List<Widget> actions;
  Widget leading;
  String id;
  String firstName;
  String lastName;
  String locationFilter;
  String title;
  String profileImage;
  dynamic currentData;
  List selectedData = [];
  List<Widget> cardList;
  Future<Null> _swipeAnimation() async {
    try {
      await _buttonController.forward();
    } on TickerCanceled {}
  }

  void _removeCard(index) {
    setState(() {
      cardList.removeAt(index);
    });
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
      print('nontull');
      setState(() {
        swipeSug = Data.fromJson(
            JsonDecoder().convert(objectString) as Map<String, dynamic>);
      });
      print(swipeSug.profiles);
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

  _getSwipeSuggestions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      locationFilter = prefs.getString('locationFilter') ?? 'true';
    });
    swipeBloc.getSwipeSuggestions(widget.token, locationFilter);
  }

  _logout() async {
    bloc.logout({}, widget.token);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    prefs.setBool('passKYC', true);
    prefs.setBool('passWalkthrough', true);
  }

  dismissImg(img) {
    if (!disableSwipe) {
      if (swipesLeft == -1) {
        setState(() {
          swipesLeft = -1;
        });
      } else {
        setState(() {
          disableSwipe = swipesLeft - 1 == 0 ? true : false;
          swipesLeft = swipesLeft - 1;
        });
      }
      print('UNLIKE');
      var req = {"swipeeId": img.id, "type": "UNLIKE"};
      print(req);
      swipeBloc.swipe(req, widget.token);
      setState(() {
        data.remove(img);
      });
      print(selectedData);
    } else {
      _showDialog();
    }
  }

  addImg(img) {
    print(disableSwipe);
    if (!disableSwipe) {
      if (swipesLeft == -1) {
        setState(() {
          swipesLeft = -1;
        });
      } else {
        print('report');
        print(swipesLeft);
        print(disableSwipe);
        setState(() {
          disableSwipe = swipesLeft - 1 == 0 ? true : false;
          swipesLeft = swipesLeft - 1;
        });
      }
      print('LIKE $swipesLeft');
      print(img.id);
      var req = {"swipeeId": img.id, "type": "LIKE"};
      print(req);
      swipeBloc.swipe(req, widget.token);
      setState(() {
        data.remove(img);
        selectedData.add(img);
      });
      print(selectedData);
    } else {
      _showDialog();
    }
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
  void initState() {
    // TODO: implement initState
    super.initState();
    print('sa ' + widget.locationFilter);

    _getSwipeSuggestions();
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

  @override
  void dispose() {
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    timeDilation = 0.4;
    disableSwipe = swipesLeft == 0 ? true : false;
    print(disableSwipe);
    double initialBottom = 15.0;
    CardController controller;
    var dataLength = data.length;
    double backCardPosition = initialBottom + (dataLength - 1) * 10 + 10;
    double backCardWidth = -10.0;
    return StreamBuilder(
        stream: swipeBloc.swipeStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            switch (snapshot.data.status) {
              case Status.ERROR:
                var error = '';
                try {
                  error = json.decode(snapshot.data.message)['responseCode'];
                } on FormatException {
                  error = snapshot.data.message;
                }

                ;
                break;
              default:
            }
          }
          return Container(
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
                            print('swipeSug');
                            print(swipeSug);
                              if (swipeSug == null)
                                return Container(
                                  height: 410,
                                  child: Center(
                                      child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                              print('eeerrr');
                              swipeBloc.swipeSugSink
                                  .add(ApiResponse.idle('message '));
                              if (snapshot.data.message != 'null') {
                                print(snapshot.data.message);
                                try {
                                  if (json.decode(snapshot.data.message)[
                                          'responseCode'] ==
                                      'INVALID_TOKEN') {
                                    _logout();
                                    print('expire');
                                    myCallback(() {
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Login(),
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Error finding new matches...'),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    FlatButton(
                                      color: AppColors.secondaryElement,
                                      child: Text(
                                        'Try Again',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onPressed: () => _getSwipeSuggestions(),
                                    )
                                  ],
                                )),
                              );
                              break;
                            case Status.DONE:
                              swipeBloc.swipeSugSink
                                  .add(ApiResponse.idle('message '));
                              swipeSug = snapshot.data.data.data;
                              saveObject(widget.token, 'swipeSug',
                                  snapshot.data.data.data);

                              swipesLeft = snapshot.data.data.data.swipesLeft;
                              disableSwipe = swipesLeft == 0 ? true : false;
                              print(swipesLeft);

                              break;
                            default:
                          }
                        }
                        if (swipeSug != null) {
                          return swipeSug.profiles.length > 0
                              ? Column(
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Positioned(
                                          top: 0,
                                          child: Container(
                                            width: 265,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.4,
                                            decoration: BoxDecoration(
                                              color: Color.fromARGB(
                                                  255, 231, 208, 206),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(16)),
                                            ),
                                            child: Container(),
                                          ),
                                        ),
                                        Positioned(
                                          top: 8,
                                          child: Container(
                                            width: 297,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.4,
                                            decoration: BoxDecoration(
                                              color: Color.fromARGB(
                                                  255, 230, 234, 224),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(16)),
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
                                          margin: EdgeInsets.only(top: 15),
                                          alignment: Alignment.center,
                                          child: Stack(
                                              alignment:
                                                  AlignmentDirectional.center,
                                              children: swipeSug.profiles
                                                  .map<Widget>((item) {
                                                if (swipeSug.profiles
                                                        .indexOf(item) ==
                                                    swipeSug.profiles.length -
                                                        1) {
                                                  currentData = item;
                                                  return cardDemo(
                                                      item,
                                                      bottom.value,
                                                      right.value,
                                                      0.0,
                                                      backCardWidth + 10,
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
                                                      backCardPosition - 10;
                                                  backCardWidth =
                                                      backCardWidth + 10;

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
                                          fillColor:
                                              Color.fromARGB(255, 142, 198, 63),
                                          child: Icon(
                                            FeatherIcons.x,
                                            color: AppColors.secondaryText,
                                          ),
                                          padding: EdgeInsets.all(15.0),
                                          shape: CircleBorder(),
                                        ),
                                        RawMaterialButton(
                                          onPressed: () {
                                            addImg(currentData);
                                          },
                                          elevation: 2.0,
                                          fillColor: AppColors.secondaryElement,
                                          child: Icon(
                                            Icons.favorite,
                                            color: AppColors.secondaryText,
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                          'Oops, we currently have no new matches for you.'),
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
                                          onPressed: () =>
                                              _getSwipeSuggestions())
                                    ],
                                  )),
                                );
                        } else {
                          return Center(child: CircularProgressIndicator());
                        }
                      }),
                ),
              ],
            ),
          );
        });
  }

  _showDialog() async {
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
}

void myCallback(Function callback) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    callback();
  });
}
