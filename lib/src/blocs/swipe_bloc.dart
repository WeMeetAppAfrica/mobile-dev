import 'dart:async';

import 'package:wemeet/src/models/apimodel.dart';
import 'package:wemeet/src/models/getmatchesmodel.dart';
import 'package:wemeet/src/models/login.dart';
import 'package:wemeet/src/models/swipe.dart';
import 'package:wemeet/src/models/swipesuggestions.dart';
import 'package:wemeet/src/resources/api_response.dart';

import 'package:rxdart/rxdart.dart';
import '../resources/repository.dart';

class SwipeBloc {
  Repository _repository;

  StreamController _swipeController;
  StreamController _swipeSugController;
  StreamController _matchController;

  StreamSink<ApiResponse<SwipeSuggestions>> get swipeSugSink =>
      _swipeSugController.sink;
  Stream<ApiResponse<SwipeSuggestions>> get swipeSugStream =>
      _swipeSugController.stream;
  StreamSink<ApiResponse<Swipe>> get swipeSink => _swipeController.sink;
  Stream<ApiResponse<Swipe>> get swipeStream => _swipeController.stream;
  StreamSink<ApiResponse<GetMatchesModel>> get matchSink =>
      _matchController.sink;
  Stream<ApiResponse<GetMatchesModel>> get matchStream =>
      _matchController.stream;
  SwipeBloc() {
    _swipeSugController = BehaviorSubject<ApiResponse<SwipeSuggestions>>();
    _swipeController = BehaviorSubject<ApiResponse<Swipe>>();
    _matchController = BehaviorSubject<ApiResponse<GetMatchesModel>>();
    _repository = Repository();
  }
  // Stream<User> get user => _userFetcher.stream;

  getMatches(token) async {
    matchSink.add(ApiResponse.loading('Loading...'));
    try {
      GetMatchesModel user = await _repository.getMatches(token);
      matchSink.add(ApiResponse.done(user));
    } catch (e) {
      matchSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  getSwipeSuggestions(token) async {
    swipeSugSink.add(ApiResponse.loading('Loading...'));
    try {
      SwipeSuggestions user =
          await _repository.getSwipeSuggestions(token, 'false');
      swipeSugSink.add(ApiResponse.done(user));
    } catch (e) {
      swipeSugSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  swipe(request, token) async {
    swipeSink.add(ApiResponse.loading('Loading...'));
    try {
      Swipe user = await _repository.swipe(request,token);
      swipeSink.add(ApiResponse.done(user));
    } catch (e) {
      swipeSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  dispose() {
    _swipeController?.close();
    _swipeSugController?.close();
    _matchController?.close();
  }
}

final swipeBloc = SwipeBloc();
