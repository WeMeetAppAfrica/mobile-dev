import 'package:flutter/material.dart';
import 'dart:async';

import 'package:wemeet/values/colors.dart';

class OnBoardingPage extends StatefulWidget {
  @override
  _OnBoardingPageState createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {

  PageController _controller = PageController(); 
  int currentPage = 0;

  @override
  void initState() { 
    super.initState();

    setTimer();
    
  }

  void setTimer() {
    Timer.periodic(Duration(seconds: 3), (timer) {

      int page = _controller.page.toInt();
      if (page < 2) {
        page++;
      } else {
        page = 0;
      }


      _controller.animateToPage(page, duration: Duration(milliseconds: 500), curve: Curves.linear);

    });
  }

  Widget buildButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed("/login");
        },
        child: Container(
          width: 60.0,
          height: 60.0,
          alignment: Alignment.center,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 40.0
          ),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            shape: BoxShape.circle
          ),
          child: Container(
            width: 40.0,
            height: 40.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.secondaryElement,
              shape: BoxShape.circle
            ),
            child: Image.asset(
              "assets/images/arrow-right.png",
              fit: BoxFit.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildIndicator() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 150.0
        ),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8.0,
          children: List.generate(3, (index){
            final bool active = index == currentPage;
            return AnimatedContainer(
              duration: Duration(milliseconds: 300),
              width: active ? 10.0 : 8.0,
              height: active ? 10.0 : 8.0,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(active ? 1.0 : 0.5),
                shape: BoxShape.circle
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget buildBody() {

    List items = [
      {
        "text": "Find the person made just for you",
        "image": "assets/images/pexels-innoh-khumbuza-2993031.png"
      },
      {
        "text": "Entertain friends with our daily playlists",
        "image": "assets/images/bg-5.png"
      },
      {
        "text": "Real time chatting to keep you connected",
        "image": "assets/images/bg.png"
      }
    ];

    return Container(
      child: Stack(
        children: [
          Positioned.fill(
            child: PageView(
              controller: _controller,
              physics: ClampingScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  currentPage = index;
                });
              },
              children: items.map((item){
                return Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        item["image"],
                        fit: BoxFit.cover,
                      )
                    ),
                    Positioned.fill(
                      child: Container(
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
                      )
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 30.0),
                        margin: EdgeInsets.only(
                          bottom: MediaQuery.of(context).padding.bottom + 200.0
                        ),
                        child: Text(
                          item["text"],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Berkshire Swash',
                              color: AppColors.secondaryText,
                              // fontWeight: FontWeight.w400,
                              fontSize: 35,
                          ),
                        ),
                      )
                    )
                  ],
                );
              }).toList(),
            )
          ),
          buildIndicator(),
          buildButton()
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildBody(),
    );
  }
}