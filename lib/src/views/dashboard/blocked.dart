import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:wemeet/src/blocs/bloc.dart';
import 'package:wemeet/src/resources/api_response.dart';
import 'package:wemeet/values/values.dart';

class Blocked extends StatefulWidget {
  final token;
  Blocked({Key key, this.token}) : super(key: key);

  @override
  _BlockedState createState() => _BlockedState();
}

class _BlockedState extends State<Blocked> {
  bool _obscureText = true;
  final passController = TextEditingController();
  final confirmPassController = TextEditingController();
  var blocked = List();
  final newPassController = TextEditingController();
  bool _obscureNewText = true;
  final _formKey = GlobalKey<FormState>();
  bool _obscureConText = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    bloc.getBlockedList(widget.token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: new IconThemeData(color: AppColors.primaryText),
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: Text(
          'Blocked Users',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontFamily: 'Berkshire Swash',
            color: AppColors.primaryText,
            fontWeight: FontWeight.w400,
            fontSize: 24,
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: StreamBuilder(
            stream: bloc.matchesStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                switch (snapshot.data.status) {
                  case Status.LOADING:
                    return Center(
                      child: Container(),
                    );
                    break;
                  case Status.GETBLOCKEDLIST:
                    bloc.userSink.add(ApiResponse.idle('message'));
                    blocked = snapshot.data.data.data.content;
                    print(snapshot.data.data.data);

                    break;
                  case Status.ERROR:
                    bloc.userSink.add(ApiResponse.idle('message'));
                    try {
                      Fluttertoast.showToast(
                          msg: json.decode(snapshot.data.message)['message']);
                    } on FormatException {
                      Fluttertoast.showToast(msg: snapshot.data.message);
                    }
                    break;
                  default:
                }
              }
              return blocked.length > 0
                  ? StreamBuilder(
                      stream: bloc.userStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          switch (snapshot.data.status) {
                            case Status.LOADING:
                              return Center(child: CircularProgressIndicator());
                              break;
                            case Status.DONE:
                              bloc.userSink.add(ApiResponse.idle('message'));
                              Fluttertoast.showToast(msg: 'User unblocked');
                              break;
                            case Status.ERROR:
                              bloc.userSink.add(ApiResponse.idle('message'));
                              try {
                                Fluttertoast.showToast(
                                    msg: json.decode(
                                        snapshot.data.message)['message']);
                              } on FormatException {
                                Fluttertoast.showToast(
                                    msg: snapshot.data.message);
                              }
                              break;
                            default:
                          }
                        }
                        return ListView.builder(
                          itemCount: blocked.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: Image(
                                height: 48,
                                width: 48,
                                fit: BoxFit.cover,
                                image: NetworkImage(
                                    '${blocked[index]['profileImage']}'),
                              ),
                              title: Text(
                                  '${blocked[index]['firstName']} ${blocked[index]['lastName']}'),
                              trailing: FlatButton(
                                color:
                                    AppColors.secondaryElement.withOpacity(0.1),
                                onPressed: () => {
                                  bloc.unblock(blocked[index]['id'], widget.token)
                                },
                                child: Text(
                                  'Unblock',
                                  style: TextStyle(
                                      color: AppColors.secondaryElement),
                                ),
                              ),
                            );
                          },
                        );
                      })
                  : Center(child: Text('You have no blocked users'));
            }),
      ),
    );
  }
}

void myCallback(Function callback) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    callback();
  });
}
