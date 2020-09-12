import 'dart:async';

import 'package:wemeet/src/models/apimodel.dart';
import 'package:wemeet/src/models/login.dart';
import 'package:wemeet/src/resources/api_response.dart';

import 'package:rxdart/rxdart.dart';
import '../resources/repository.dart';

class Bloc {
  Repository _userRepository;

  StreamController _apiController;
  StreamController _loginController;

  StreamSink<ApiResponse<ApiModel>> get userSink => _apiController.sink;
  Stream<ApiResponse<ApiModel>> get userStream => _apiController.stream;
  StreamSink<ApiResponse<LoginModel>> get loginSink => _loginController.sink;
  Stream<ApiResponse<LoginModel>> get loginStream => _loginController.stream;
  Bloc() {
    _apiController = BehaviorSubject<ApiResponse<ApiModel>>();
    _loginController = BehaviorSubject<ApiResponse<LoginModel>>();
    _userRepository = Repository();
  }
  // Stream<User> get user => _userFetcher.stream;

  signup(request) async {
    userSink.add(ApiResponse.loading('Loading...'));
    try {
      ApiModel user = await _userRepository.signup(request);
      userSink.add(ApiResponse.done(user));
    } catch (e) {
      userSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }
  login(request) async {
    loginSink.add(ApiResponse.loading('Loading...'));
    try {
      LoginModel user = await _userRepository.login(request);
      loginSink.add(ApiResponse.done(user));
    } catch (e) {
      loginSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  dispose() {
    _apiController?.close();
    _loginController?.close();
  }
}

final bloc = Bloc();
