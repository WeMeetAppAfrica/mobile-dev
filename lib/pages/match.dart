import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter_tindercard/flutter_tindercard.dart';
import 'package:ionicons/ionicons.dart';
import 'dart:async';

import 'package:wemeet/models/user.dart';

import 'package:wemeet/services/match.dart';
import 'package:wemeet/providers/data.dart';

import 'package:wemeet/pages/match_found.dart';
import 'package:wemeet/pages/chat.dart';
import 'package:wemeet/pages/user_details.dart';

import 'package:wemeet/components/media_player.dart';
import 'package:wemeet/components/loader.dart';
import 'package:wemeet/components/error.dart';
import 'package:wemeet/utils/colors.dart';
import 'package:wemeet/utils/svg_content.dart';

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

  MediaQueryData mQuery;

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

    if(!val) {
      return;
    }

    await Future.delayed(Duration(seconds: 1));

    String id = "${match?.id}";

    bool go = await Navigator.push(context, MaterialPageRoute(
      builder: (context) => MatchFoundPage(match: match),
      fullscreenDialog: true
    )) ?? false;

    // remove the match component anyways
    setState(() {
      if(val){
        match = null; 
      }            
    });

    if(!go) {
      return;
    }

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ChatPage(uid: id)
    ));
    
  }

  void onReload(String val) {
    if(!mounted) {
      return;
    }

    if(val.split(",").contains("match")) {
      fetchData();
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

  void _showUpgrade() async {
    bool val = await WeMeetLoader.showBottomModalSheet(
      context,
      "Out of Swipes.",
      content: "Unfortunately you are out of swipes for today. Would you like t upgrade to enjoy unlimited swipes?",
      cancelText: "No, thanks",
      okText: "Yes, please!",
    );

    if(!val) {
      return;
    }

    DataProvider().setNavPage(3);
    
  }

  void viewUser(UserModel u) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => UserDetailsPage(
        user: u,
        onSwipe: (val) {
          if(val == null) {
            return;
          }

          if(val) {
            controller.triggerRight();
          } else {
            controller.triggerLeft();
          }
        },
      )
    ));
  }

  Widget _swipeBtn(String icon, [bool left = false]) {
    return InkWell(
      onTap: () {
        if(left) {
          controller.triggerLeft();
        } else {
          controller.triggerRight();
        }
      },
      child: Container(
        width: 50.0,
        height: 50.0,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.orangeColor.withOpacity(0.06)
        ),
        child: SvgPicture.string(
          icon,
          color: AppColors.orangeColor
        ),
      ),
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
              orientation: AmassOrientation.TOP,
              totalNum: users.length,
              stackNum: 2,
              swipeEdge: 10.0,
              allowVerticalMovement: false,
              maxWidth: mQuery.size.width * 0.95,
              maxHeight: mQuery.size.width * 0.95,
              minWidth: mQuery.size.width * 0.80,
              minHeight: mQuery.size.width * 0.80,
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
              cardBuilder: (context, index) {
                UserModel item = users[index];
                return GestureDetector(
                  onTap: () {
                    viewUser(item);
                  },
                  child: Card(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0)
                    ),
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
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            margin: EdgeInsets.only(bottom: 20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "${item.firstName}, ${item.age}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15.0
                                  ),
                                ),
                                SizedBox(height: 5.0,),
                                Text(
                                  "${item.distanceInKm ?? 1}Km Away",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w700
                                  ),
                                ),
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
          SizedBox(height: 13.0),
          Wrap(
            spacing: 20.0,
            alignment: WrapAlignment.center,
            children: [
              _swipeBtn(WemeetSvgContent.cancel, true),
              _swipeBtn(WemeetSvgContent.heartY, false)
            ],
          )
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

    mQuery = MediaQuery.of(context);

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

/*
{id: 140, firstName: Olalekan, lastName: Oladipupo, bio: Hello world, gender: MALE, dateOfBirth: 694224000000, workStatus: SELF_EMPLOYED, genderPreference: [FEMALE], type: FREE, age: 29, hideLocation: false, hideProfile: false, longitude: 18.891966, latitude: -33.747374, distanceInKm: 0, distanceInMiles: 0, email: lakesida10@gmail.com, emailVerified: true, phone: 2348051097031, phoneVerified: false, active: true, suspended: false, lastSeen: 1612774981000, dateCreated: 1609867520000, swipeRadius: 1, minAge: 18, maxAge: 30, profileImage: https://wemeetstorage.s3.eu-west-1.amazonaws.com/images/PROFILE_IMAGE_140_8d91235a-902e-4e93-9a59-bfd2adf1a03e, additionalImages: []
*/

List<UserModel> _users = List.generate(5, (i) => UserModel.fromMap({"id": 140, "firstName":" Olalekan", "lastName": "Oladipupo", "bio": "Hello world", "gender": "MALE", "dateOfBirth": 694224000000, "workStatus": "SELF_EMPLOYED", "genderPreference": ["FEMALE"], "type": "FREE", "age": 29, "hideLocation": false, "hideProfile": false, "longitude": 18.891966, "latitude": -33.747374, "distanceInKm": 0, "distanceInMiles": 0, "email": "lakesida10@gmail.com", "emailVerified": true, "phone": "2348051097031", "phoneVerified": false, "active": true, "suspended": false, "lastSeen": 1612774981000, "dateCreated": 1609867520000, "swipeRadius": 1, "minAge": 18, "maxAge": 30, "profileImage": "https://wemeetstorage.s3.eu-west-1.amazonaws.com/images/PROFILE_IMAGE_140_8d91235a-902e-4e93-9a59-bfd2adf1a03e", "additionalImages": []}));