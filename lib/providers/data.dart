// import 'dart:async';

import 'package:wemeet/models/user.dart';

class DataProvider {

  DataProvider._internal();

  static final DataProvider _dataProvider = DataProvider._internal();

  factory DataProvider(){
    return _dataProvider;
  }

  String _token;
  String get token => _token;

  void setToken(String t){
    print(t);
    _token = t;
    print("### setting token: $t");
  }

  String _messageToken;
  String get messageToken => _messageToken;

  void setMessageToken(String t){
    print(t);
    _messageToken = t;
    print("### setting message token: $t");
  }

  String _pushToken;
  String get pushToken => _pushToken;

  void setPushToken(String t){
    print(t);
    _pushToken = t;
    print("### setting push token: $t");
  }

  // User
  UserModel _user;
  UserModel get user => _user;

  void setUser(UserModel val) {
    _user = val;
    print("### setting user");
  }

}