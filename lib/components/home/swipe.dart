import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter_tindercard/flutter_tindercard.dart';
import 'dart:async';

import 'package:wemeet/models/user.dart';
import 'package:wemeet/providers/data.dart';

import 'package:wemeet/services/match.dart';
import 'package:wemeet/src/SwipeAnimation/detail.dart';
import 'package:wemeet/src/views/dashboard/chat-page.dart';
import 'package:wemeet/src/views/dashboard/payment.dart';
import 'package:wemeet/utils/errors.dart';
import 'package:wemeet/values/colors.dart';
import 'package:wemeet/components/circular_button.dart';
import 'package:wemeet/components/home/match.dart';

class HomeSwipeComponent extends StatefulWidget {
  final ValueChanged<bool> onMatch;
  const HomeSwipeComponent({Key key, this.onMatch}) : super(key: key);

  @override
  _HomeSwipeComponentState createState() => _HomeSwipeComponentState();
}

class _HomeSwipeComponentState extends State<HomeSwipeComponent> {

  bool isLoading = false;
  int swipesLeft = 0;
  int left = 0;
  List<UserModel> users = [];
  UserModel match;
  CardController controller = CardController();

  DataProvider _dataProvider = DataProvider();
  StreamSubscription<bool> reloadStream;

  MediaQueryData mQuery;

  @override
  void initState() { 
    super.initState();

    reloadStream = _dataProvider.onReload.listen(onReload);
    
    fetchData();
  }

  @override
  void dispose() {
    reloadStream?.cancel();
    super.dispose();
  }

  void onReload(bool val) {
    if(!mounted) {
      return;
    }

    fetchData();
  }

  void fetchData() async {

    setState(() {
      isLoading = true;
    });

    try {
      var res = await MatchService.getSwipes();
      Map data = res["data"];
      List u = data["profiles"] as List; 

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

  void postSwipe(int id, String action) {
    
    setState(() {
      left = left - 1;
      users.removeWhere((e) => e.id == id);      
    });

    if(swipesLeft == 0) {
      _showUpgrade();
      return;
    }

    MatchService.postSwipe({"swipeeId": id, "type": action}).then((val){
      print(val);
      setState(() {
        swipesLeft = swipesLeft - 1;        
      });
    });
  }

  void showMatch(bool val) {
    // remove the match component anyways
    setState(() {
      if(val){
        match = null; 
      }            
    });
    if(widget.onMatch == null) {
      return;
    }
    widget.onMatch(val);
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
                                token: DataProvider().token,
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

  Widget buildSwipes() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 30.0),
          Container(
            constraints: BoxConstraints(
              maxWidth: 400.0,
              maxHeight: mQuery.size.width * 0.95
            ),
            child: TinderSwapCard(
              cardController: controller,
              swipeUp: false,
              swipeDown: false,
              swipeCompleteCallback: (orientation, index){
                if (orientation == CardSwipeOrientation.LEFT) {
                  postSwipe(users[index].id, "UNLIKE");
                }

                if (orientation == CardSwipeOrientation.RIGHT) {
                  postSwipe(users[index].id, "LIKE");
                }
              },
              swipeUpdateCallback: (details, align) {

              },
              orientation: AmassOrientation.TOP,
              totalNum: users.length,
              stackNum: 2,
              swipeEdge: 10.0,
              maxWidth: mQuery.size.width * 0.95,
              maxHeight: mQuery.size.width * 0.95,
              minWidth: mQuery.size.width * 0.80,
              minHeight: mQuery.size.width * 0.80,
              cardBuilder: (context, index){
                UserModel item = users[index];
                return InkWell(
                  onTap: (){
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, _, __) => DetailPage(
                          type: item,
                          from: "SWIPE",
                          token: DataProvider().token,
                        )
                      )
                    );
                    // if (swipesLeft == 0) {
                    //   _showUpgrade();
                    // }
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0)
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CachedNetworkImage(
                            imageUrl: item.profileImage,
                            placeholder: (context, _) => DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.black,
                                gradient: LinearGradient(
                                  begin: FractionalOffset.topCenter,
                                  end: FractionalOffset.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.2),
                                    Colors.black.withOpacity(0.9),
                                  ],
                                )
                              ),
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.black,
                              gradient: LinearGradient(
                                begin: FractionalOffset.topCenter,
                                end: FractionalOffset.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.01),
                                  Colors.black.withOpacity(0.7),
                                ],
                                stops: [0.6, 1.0]
                              )
                            ),
                          ),
                        ),
                        Positioned(
                          top: 15.0,
                          right: 15.0,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 3.0),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10.0)
                            ),
                            child: Text(
                              "${item.distanceInKm ?? 1}Km Away",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.0
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            margin: EdgeInsets.only(bottom: 20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "${item.fullName}, ${item.age}",
                                  style: TextStyle(
                                    fontFamily: 'Berkshire Swash',
                                    color: Colors.white,
                                    fontSize: 24.0
                                  ),
                                ),
                                SizedBox(height: 5.0,),
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius: BorderRadius.circular(6.0)
                                  ),
                                  child: Wrap(
                                    spacing: 10.0,
                                    children: [
                                      Text(
                                        "${item.workStatus}",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13.0
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            )
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20.0),
          Wrap(
            spacing: 10.0,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              RawMaterialButton(
                onPressed: (){
                  if(swipesLeft == 0) {
                    _showUpgrade();
                    return;
                  }
                  controller.triggerLeft();
                },
                elevation: 2.0,
                shape: CircleBorder(),
                padding: EdgeInsets.all(15.0),
                fillColor: Colors.green,
                child: Icon(FeatherIcons.x, color: Colors.white, size: 20.0,),
              ),
              RawMaterialButton(
                onPressed: () {
                  if(swipesLeft == 0) {
                    _showUpgrade();
                    return;
                  }
                  controller.triggerRight();
                },
                shape: CircleBorder(),
                fillColor: AppColors.secondaryElement,
                padding: EdgeInsets.all(20.0),
                child: Icon(Icons.favorite, color: Colors.white,),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget buildBody() {
    if(isLoading && users.isEmpty) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if(match != null) {
      return Center(
        child: MatchComponent(
          onTap: (val) {
            if(val) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatView(
                    apiToken: _dataProvider.token,
                    token: _dataProvider.messageToken,
                    peerAvatar: match.profileImage,
                    peerId: match.id.toString(),
                    peerName: match.fullName,
                  ),
                ));
            }
            showMatch(false);
          },
          match: match,
        ),
      );
    }

    if(users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularBtn(
              onTap: fetchData,
              radius: 90.0,
              icon: Icon(FeatherIcons.heart, color: Colors.white),
            ),
            SizedBox(height: 10.0),
            Text(
              "No Match Found. Retry"
            )
          ],
        ),
      );
    }

    return buildSwipes();
  }

  @override
  Widget build(BuildContext context) {
    mQuery = MediaQuery.of(context);
    return buildBody();
  }
}