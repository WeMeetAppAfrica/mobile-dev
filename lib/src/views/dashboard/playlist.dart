import 'dart:convert';

import 'package:feather_icons_flutter/feather_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:wemeet/src/blocs/bloc.dart';
import 'package:wemeet/src/resources/api_response.dart';
import 'package:wemeet/values/values.dart';

class Playlist extends StatefulWidget {
  final token;
  Playlist({Key key, this.token}) : super(key: key);

  @override
  _PlaylistState createState() => _PlaylistState();
}

class _PlaylistState extends State<Playlist> {
  bool allowSend = true;
  final descController = TextEditingController();

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
                  onPressed: () => {_showDialog()},
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

  _showDialog() async {
    await showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Request for Song',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontFamily: 'Berkshire Swash',
                  color: AppColors.secondaryElement,
                  fontWeight: FontWeight.w400,
                  fontSize: 24,
                ),
              ),
              contentPadding: const EdgeInsets.all(16.0),
              content: StreamBuilder(
                  stream: bloc.songStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      switch (snapshot.data.status) {
                        case Status.LOADING:
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Center(child: CircularProgressIndicator()),
                            ],
                          );
                          break;

                        case Status.ERROR:
                          bloc.songSink.add(ApiResponse.idle('message'));
                          myCallback(() {
                            setState(() {
                              allowSend = true;
                            });
                          });

                          try {
                            Fluttertoast.showToast(
                                msg: json
                                    .decode(snapshot.data.message)['message']);
                          } on FormatException {
                            Fluttertoast.showToast(msg: snapshot.data.message);
                          }
                          break;
                        case Status.SONGREQUEST:
                        print('done');
                          bloc.songSink.add(ApiResponse.idle('message'));
                           myCallback(() {
                            setState(() {
                              allowSend = true;
                            });
                          });
                          Navigator.pop(context);
                          Fluttertoast.showToast(
                              msg: 'Song request submitted successfully');
                          break;
                        default:
                      }
                    }
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                            "Tell us about the song you'd like to add and we would add it to tomorrow's playlist"),
                        new TextFormField(
                          controller: descController,
                          autofocus: true,
                          decoration: new InputDecoration(
                              prefixIcon: Icon(FeatherIcons.music),
                              labelText: 'Song Description',
                              hintText: 'eg. Joro by Layon ft. Elhi',
                            focusedBorder: UnderlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.green, width: 2.0),),),
                        ),
                      ],
                    );
                  }),
              actions: <Widget>[
                new FlatButton(
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: AppColors.primaryText),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
                allowSend == true
                    ? FlatButton(
                        color: AppColors.secondaryElement,
                        child: const Text('Send Song Request'),
                        onPressed: () {
                          setState(() {
                            allowSend = false;
                          });
                          var request = {
                            "description": descController.text,
                            "id": 0,
                            "requester": {
                              "active": true,
                              "dateOfBirth": "2020-10-27T22:29:06.265Z",
                              "email": "string",
                              "emailVerified": true,
                              "firstName": "string",
                              "gender": "MALE",
                              "id": 0,
                              "lastName": "string",
                              "phone": "string",
                              "phoneVerified": true,
                              "profileImage": "string",
                              "suspended": true,
                              "type": "FREE"
                            }
                          };
                          bloc.songRequest(request, widget.token);
                          // Navigator.pop(context);
                        })
                    : Container()
              ],
            );
          },
        );
      },
    );
  }

  void myCallback(Function callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      callback();
    });
  }
}

class _SystemPadding extends StatelessWidget {
  final Widget child;

  _SystemPadding({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    return new AnimatedContainer(
        padding: mediaQuery.viewInsets,
        duration: const Duration(milliseconds: 300),
        child: child);
  }
}
