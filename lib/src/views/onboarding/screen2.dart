import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wemeet/src/views/auth/login.dart';
import 'package:wemeet/values/values.dart';

class OnBoarding2 extends StatefulWidget {
  OnBoarding2({Key key}) : super(key: key);

  @override
  _OnBoarding2State createState() => _OnBoarding2State();
}

class _OnBoarding2State extends State<OnBoarding2> {
  _passWalkthrough() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('passWalkthrough', true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.expand(),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 254, 246, 248),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 0,
            right: 0,
            child: Image.asset(
              "assets/images/bg-5.png",
              fit: BoxFit.cover,
            ),
          ),
          Container(
            decoration: BoxDecoration(
                color: Colors.black,
                gradient: LinearGradient(
                    begin: FractionalOffset.topCenter,
                    end: FractionalOffset.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.6),
                      AppColors.secondaryElement.withOpacity(0.3),
                    ],
                    stops: [
                      0.8,
                      1.0
                    ])),
          ),
          Positioned(
            top: 89,
            bottom: 47,
            child: Column(
              children: [
                Spacer(),
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: 328,
                    margin: EdgeInsets.only(bottom: 60),
                    child: Text(
                      "Entertain friends with our daily playlists",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Berkshire Swash',
                        color: AppColors.secondaryText,
                        // fontWeight: FontWeight.w400,
                        fontSize: 35,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: 49,
                    height: 12,
                    margin: EdgeInsets.only(bottom: 39),
                    child: Image.asset(
                      "assets/images/owl-carousel-3.png",
                      fit: BoxFit.none,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => {
                    _passWalkthrough(),
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Login(),
                      ),
                    )
                  },
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: 74,
                      height: 74,
                      decoration: BoxDecoration(
                        border: Border.fromBorderSide(Borders.secondaryBorder),
                        borderRadius: BorderRadius.all(Radius.circular(36)),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            left: 16,
                            right: 16,
                            child: Container(
                              height: 42,
                              decoration: BoxDecoration(
                                color: AppColors.secondaryElement,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                              ),
                              child: Container(),
                            ),
                          ),
                          Positioned(
                            child: Image.asset(
                              "assets/images/arrow-right.png",
                              fit: BoxFit.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
