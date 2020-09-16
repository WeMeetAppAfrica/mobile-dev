import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wemeet/src/views/auth/login.dart';
import 'package:wemeet/src/views/dashboard/matchcard.dart';
import 'package:wemeet/values/values.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Widget> cardList;

  _setUser(token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('accessToken', token);
  }

  List<Widget> _getMatchCard() {
    List<Widget> cardList = new List();

    for (int x = 0; x < 3; x++) {
      cardList.add(Positioned(
          top: 41,
          child: Draggable(
            onDragEnd: (drag) {
              _removeCard(x);
            },
            childWhenDragging: Container(),
            feedback: MatchCard(
              age: x,
              name: "Jane Doe",
              dist: "2km",
              location: "Ikeja, Lagos",
              image:
                  "https://images.pexels.com/photos/5262348/pexels-photo-5262348.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260",
            ),
            child: MatchCard(
              age: x,
              name: "Jane Doe",
              dist: "2km",
              location: "Ikeja, Lagos",
              image:
                  "https://images.pexels.com/photos/5262348/pexels-photo-5262348.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260",
            ),
          )));
    }
    return cardList;
  }

  void _removeCard(index) {
    setState(() {
      cardList.removeAt(index);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    cardList = _getMatchCard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    child: Column(
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
                                  image: NetworkImage(
                                      "https://images.pexels.com/photos/5207248/pexels-photo-5207248.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260"))),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 1, top: 14, right: 6),
                          child: Text(
                            "Buchi Alfred",
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
                    ),
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
                    // Update the state of the app.
                    // ...
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
                    _setUser(null);
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Login(),
                        ));
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
        title: Text(
          "Meet Someone",
          textAlign: TextAlign.left,
          style: TextStyle(
            fontFamily: 'Berkshire Swash',
            color: AppColors.primaryText,
            fontWeight: FontWeight.w400,
            fontSize: 24,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.fromLTRB(0.0, 0.0, 16.0, 0.0),
            child: IconButton(
              icon: Icon(
                FeatherIcons.messageSquare,
                color: AppColors.primaryText,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 327,
                height: 404,
                margin: EdgeInsets.only(top: 45),
                child: cardList.isEmpty
                    ? Center(child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(backgroundColor: AppColors.secondaryElement,),
                        SizedBox(height: 10,),
                        Text('Finding new matches...')
                      ],
                    ))
                    : Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            top: 0,
                            child: Container(
                              width: 265,
                              height: 365,
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 231, 208, 206),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(16)),
                              ),
                              child: Container(),
                            ),
                          ),
                          Positioned(
                            top: 16,
                            child: Container(
                              width: 297,
                              height: 365,
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 230, 234, 224),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(16)),
                              ),
                              child: Container(),
                            ),
                          ),
                          Stack(
                            alignment: Alignment.center,
                            children: cardList,
                          )
                        ],
                      ),
              ),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RawMaterialButton(
                  onPressed: () {},
                  elevation: 2.0,
                  fillColor: Color.fromARGB(255, 142, 198, 63),
                  child: Icon(
                    FeatherIcons.x,
                    color: AppColors.secondaryText,
                  ),
                  padding: EdgeInsets.all(15.0),
                  shape: CircleBorder(),
                ),
                RawMaterialButton(
                  onPressed: () {},
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
            Container(
              padding: EdgeInsets.only(left: 20, right: 20),
              margin: EdgeInsets.only(bottom: 25),
              decoration: BoxDecoration(
                  color: AppColors.secondaryElement,
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              height: 80,
              width: MediaQuery.of(context).size.width * 0.9,
              child: Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '2 Baba',
                        style: TextStyle(
                            color: Color.fromARGB(180, 255, 255, 255),
                            fontSize: 12),
                      ),
                      Text(
                        'Gaga Shuffle',
                        style: TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  Icon(
                    FeatherIcons.playCircle,
                    color: AppColors.secondaryText,
                    size: 32,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Icon(
                    FeatherIcons.fastForward,
                    color: AppColors.secondaryText,
                    size: 32,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
