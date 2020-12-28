import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';

import 'package:wemeet/providers/data.dart';
import 'package:wemeet/models/user.dart';

class _MainModel extends Model {
  
  // Main app data provider
  DataProvider _dataProvider = DataProvider();

  // Instance of shared preference
  SharedPreferences _prefs;

  // Main app local storage
  Map _localStorage = {};

  // chat list
  Map _chatList = {};

  // match list
  Map _matchList = {};

  // API Token
  String _token = "";

  // Push Token
  String _pushToken = "";

  // Message Token
  String _messageToken = "";

  // First launch
  String _firstLaunch = "yes";

  // User model
  UserModel _user;

  // Initialize main app model
  void init(Map item, SharedPreferences pref) async {

    _prefs = pref;
    _localStorage = item ?? {};

    print("##### Local storage Keys: ${_localStorage.keys}");

    // Get and set the user
    var user = _localStorage["@user"];
    if(user != null){
      Map d = jsonDecode(user);
      _user = UserModel.fromMap(d);
      _dataProvider.setUser(_user);
    }

    // get and set the token
    _token = _localStorage["@token"];
    _dataProvider.setToken(_token);

    // get and set push token
    _pushToken = _localStorage["@push_token"];
    _dataProvider.setPushToken(_pushToken);

    // get and set message token
    _messageToken = _localStorage["@message_token"];
    _dataProvider.setMessageToken(_messageToken);

    // Get and set user chat list
    var chatList = _localStorage["@chat_list"] ?? "{}";
    _chatList = jsonDecode(chatList);

    // Get and set user match list
    var matchList = _localStorage["@match_list"] ?? "{}";
    _matchList = jsonDecode(matchList);

    // get and set firsttime
    _firstLaunch = _localStorage["@first_launch"] ?? "yes";

    // Notify all listeners
    notifyListeners();

  }

  void _internalSaveData() async{
    await _prefs.setString("app", jsonEncode(_localStorage));
    await _prefs.setString('pushToken', _pushToken);
  }

}

mixin _UserData on _MainModel {

  UserModel get user => _user;
  String get token => _token;
  String get pushToken => _pushToken;
  String get messageToken => _messageToken;
  String get firstLaunch => _firstLaunch;

  // Set the user model
  void setUserModel(UserModel val){
    _user = val;
    _dataProvider.setUser(_user);
    _localStorage["@user"] = jsonEncode(val.toMap());
    notifyListeners();
    _internalSaveData();
  }

  // Set the user from map
  void setUserMap(Map val){
    _user = UserModel.fromMap(val);
    _dataProvider.setUser(_user);
    _localStorage["@user"] = jsonEncode(val);
    notifyListeners();
    _internalSaveData();
  }

  // Set the user token
  void setToken(String data){
    print("### Setting user token: $data");
    _token = data;
    _localStorage['@token'] = data;
    _dataProvider.setToken(data);
    notifyListeners();
    _internalSaveData();
  }

  // Set the push token
  void setPushToken(String data){
    _token = data;
    _localStorage['@push_token'] = data;
    _dataProvider.setPushToken(data);
    notifyListeners();
    _internalSaveData();
  }

  // Set the messae token
  void setMessageToken(String data){
    _token = data;
    _localStorage['@message_token'] = data;
    _dataProvider.setMessageToken(data);
    notifyListeners();
    _internalSaveData();
  }

  void setFirstLaunch(String val) {
    _firstLaunch = val;
    _localStorage['@first_launch'] = val;
    notifyListeners();
    _internalSaveData();
  }

  void logOut() async {
    _token = null;
    _user = null;
    _localStorage = {
      "@first_launch": _firstLaunch
    };
    _dataProvider.setToken(null);
    _dataProvider.setUser(_user);
    notifyListeners();
    await _internalSaveData();
  }

}

mixin _Chat on _MainModel {
  Map get chatList => _chatList;
  Map get matchList => _matchList;

  // Set the user token
  void setChatList(Map data){
    _chatList = data;
    _localStorage['@chat_list'] = jsonEncode(data);
    notifyListeners();
    _internalSaveData();
  }

  // Set the match list
  void setMatchList(Map data){
    _matchList = data;
    _localStorage['@match_list'] = jsonEncode(data);
    notifyListeners();
    _internalSaveData();
  }
}

class AppModel extends Model with _MainModel, _UserData, _Chat {}

/**

https://prod.wemeet.africa/api/messaging-service/v1/30

*/