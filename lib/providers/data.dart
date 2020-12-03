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

  // User
  UserModel _user;
  UserModel get user => _user;

  void setUser(UserModel val) {
    _user = val;
    print("### setting user");
  }

}