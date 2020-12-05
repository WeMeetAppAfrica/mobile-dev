import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter_tindercard/flutter_tindercard.dart';

import 'package:wemeet/models/user.dart';
import 'package:wemeet/providers/data.dart';

import 'package:wemeet/services/match.dart';
import 'package:wemeet/src/SwipeAnimation/detail.dart';
import 'package:wemeet/utils/errors.dart';
import 'package:wemeet/values/colors.dart';

class HomeSwipeComponent extends StatefulWidget {
  @override
  _HomeSwipeComponentState createState() => _HomeSwipeComponentState();
}

class _HomeSwipeComponentState extends State<HomeSwipeComponent> {

  bool isLoading = false;
  int swipesLeft = 0;

  List<UserModel> users = [];
  CardController controller = CardController();

  MediaQueryData mQuery;

  @override
  void initState() { 
    super.initState();
    
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
      });

    } catch (e) {

    } finally {
      setState((){
        isLoading = false;
      });
    }
  }

  Widget buildSwipes() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 30.0),
          Container(
            height: 300.0,
            child: TinderSwapCard(
              cardController: controller,
              swipeUp: false,
              swipeDown: false,
              orientation: AmassOrientation.TOP,
              totalNum: users.length,
              stackNum: 2,
              swipeEdge: 10.0,
              maxWidth: mQuery.size.width * 0.80,
              maxHeight: mQuery.size.width * 0.80,
              minWidth: mQuery.size.width * 0.70,
              minHeight: mQuery.size.width * 0.70,
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
            spacing: 20.0,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              InkWell(
                child: Container(
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle
                  ),
                  child: Center(
                    child: Icon(FeatherIcons.x, color: Colors.white, size: 20.0,),
                  ),
                ),
              ),
              InkWell(
                child: Container(
                  width: 50.0,
                  height: 50.0,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryElement,
                    shape: BoxShape.circle
                  ),
                  child: Center(
                    child: Icon(Icons.favorite, color: Colors.white,)
                  ),
                ),
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

    if(users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: fetchData,
              child: Container(
                width: 90.0,
                height: 90.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.secondaryElement.withOpacity(0.2),
                  shape: BoxShape.circle
                ),
                child: Container(
                  width: 75.0,
                  height: 75.0,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryElement,
                    shape: BoxShape.circle
                  ),
                  child: Icon(FeatherIcons.heart, color: Colors.white)
                )
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              "No match"
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