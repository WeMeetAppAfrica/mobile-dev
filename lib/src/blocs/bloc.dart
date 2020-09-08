import 'dart:async';

import 'package:wemeet/src/models/apimodel.dart';
import 'package:wemeet/src/resources/api_response.dart';

import 'package:rxdart/rxdart.dart';
import '../resources/repository.dart';

class Bloc {
  Repository _userRepository;

  StreamController _apiController;

  StreamSink<ApiResponse<ApiModel>> get userSink => _apiController.sink;
  Stream<ApiResponse<ApiModel>> get userStream => _apiController.stream;
  Bloc() {
    _apiController = BehaviorSubject<ApiResponse<ApiModel>>();
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
  }  dispose() {
    _apiController?.close();
  }
}

final bloc = Bloc();
