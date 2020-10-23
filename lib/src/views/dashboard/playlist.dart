import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:wemeet/values/values.dart';

class Playlist extends StatefulWidget {
  Playlist({Key key}) : super(key: key);

  @override
  _PlaylistState createState() => _PlaylistState();
}

class _PlaylistState extends State<Playlist> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: new IconThemeData(color: AppColors.primaryText),
        backgroundColor: Colors.white,
        elevation: 0.0,
      ),
      body: Container(
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
                  onPressed: () => {},
                  color: AppColors.secondaryElement,
                  icon: Icon(FeatherIcons.plus),
                )
              ],
            ),
            SizedBox(
              height: 18,
            ),
            Text(
              "Music Requests",
              textAlign: TextAlign.left,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 20,
              ),
            ),
            SizedBox(
              height: 18,
            ),
            Container(
              height: 300,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Card(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    shape: RoundedRectangleBorder(
                      borderRadius: Radii.k8pxRadius,
                    ),
                    child: Stack(
                      children: [
                        Image(
                          height: 300,
                          width: 240,
                          fit: BoxFit.cover,
                          image: NetworkImage(
                            'https://images.pexels.com/photos/5325584/pexels-photo-5325584.jpeg?auto=compress&cs=tinysrgb&dpr=2&w=500',
                          ),
                        ),
                        Container(
                          height: 300,
                          width: 240,
                          decoration: BoxDecoration(
                              color: Colors.black,
                              gradient: LinearGradient(
                                  begin: FractionalOffset.topCenter,
                                  end: FractionalOffset.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '#EndSARS',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: AppColors.secondaryText,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 22,
                                ),
                              ),
                              Text(
                                "Robin Stark",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color:
                                      AppColors.secondaryText.withOpacity(0.8),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Card(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    shape: RoundedRectangleBorder(
                      borderRadius: Radii.k8pxRadius,
                    ),
                    child: Stack(
                      children: [
                        Image(
                          height: 300,
                          width: 240,
                          fit: BoxFit.cover,
                          image: NetworkImage(
                            'https://images.pexels.com/photos/5325584/pexels-photo-5325584.jpeg?auto=compress&cs=tinysrgb&dpr=2&w=500',
                          ),
                        ),
                        Container(
                          height: 300,
                          width: 240,
                          decoration: BoxDecoration(
                              color: Colors.black,
                              gradient: LinearGradient(
                                  begin: FractionalOffset.topCenter,
                                  end: FractionalOffset.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '#EndSARS',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: AppColors.secondaryText,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 22,
                                ),
                              ),
                              Text(
                                "Robin Stark",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color:
                                      AppColors.secondaryText.withOpacity(0.8),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 18,
            ),
            Text(
              "Daily Playlist",
              textAlign: TextAlign.left,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 20,
              ),
            ),
            ListTile(
              leading: Icon(
                FeatherIcons.music,
                color: AppColors.secondaryElement,
              ),
              trailing: ClipOval(
                child: Material(
                  color: AppColors.secondaryElement, // button color
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
                    onTap: () {},
                  ),
                ),
              ),
              title: Text('Joro (ft. Elhi)'),
              subtitle: Text('Layon'),
            ),
          ],
        ),
      ),
    );
  }
}
