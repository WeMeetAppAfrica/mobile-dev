import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:wemeet/src/blocs/bloc.dart';
import 'package:wemeet/src/resources/api_response.dart';
import 'package:wemeet/src/views/dashboard/profile.dart';
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
                      child: CircularProgressIndicator(),
                    );
                    break;
                  case Status.GETBLOCKEDLIST:
                    bloc.userSink.add(ApiResponse.idle('message'));

                    return ListView(
                      children: [
                        ListTile(
                          leading: Image(
                            height: 48,
                            image: NetworkImage(
                                'https://via.placeholder.com/1080'),
                          ),
                          title: Text('Hello'),
                          trailing: FlatButton(
                            color: AppColors.secondaryElement.withOpacity(0.1),
                            onPressed: () => {},
                            child: Text(
                              'Unblock',
                              style:
                                  TextStyle(color: AppColors.secondaryElement),
                            ),
                          ),
                        )
                      ],
                    );

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
              return Container();
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
