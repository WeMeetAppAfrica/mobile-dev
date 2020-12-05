// import 'dart:async';

import 'dart:async';

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
  }

  String _messageToken;
  String get messageToken => _messageToken;

  void setMessageToken(String t){
    print(t);
    _messageToken = t;
  }

  String _pushToken;
  String get pushToken => _pushToken;

  void setPushToken(String t){
    print(t);
    _pushToken = t;
  }

  // Location filter
  String _locationFilter = "true";
  String get locationFilter => _locationFilter;
  void setlocationFilter(String val) {
    _locationFilter = val ?? "true";
  }

  // User
  UserModel _user;
  UserModel get user => _user;

  void setUser(UserModel val) {
    _user = val;
  }

  // new chat stream controller
  StreamController<bool> _reloadController =
      StreamController<bool>.broadcast();
  Stream<bool> get onReload =>
      _reloadController.stream;
  
  void reloadData() {
    _reloadController.add(true);
  }

}