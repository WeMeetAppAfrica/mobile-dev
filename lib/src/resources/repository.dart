import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wemeet/src/models/apimodel.dart';
import 'package:wemeet/src/models/getmatchesmodel.dart';
import 'package:wemeet/src/models/imageupload.dart';
import 'package:wemeet/src/models/login.dart';
import 'package:wemeet/src/models/profilemodel.dart';
import 'package:wemeet/src/models/swipe.dart';
import 'package:wemeet/src/models/swipesuggestions.dart';
import 'package:wemeet/src/resources/api_base_helper.dart';
import 'package:wemeet/src/resources/api_response.dart';

class Repository {
  ApiBaseHelper _helper = ApiBaseHelper();
  getStringValuesSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return String
    String stringValue = prefs.getString('accessToken');
    return stringValue;
  }

  Future<LoginModel> signup(request) async {
    final response = await _helper.post('auth/signup', request, '');
    return LoginModel.fromJson(response);
  }

  Future<LoginModel> login(request) async {
    final response = await _helper.post('auth/login', request, '');
    return LoginModel.fromJson(response);
  }

  Future<LoginModel> emailVerification(request, token) async {
    final response =
        await _helper.post('auth/verify/email?token=' + request, {}, token);
    return LoginModel.fromJson(response);
  }

  Future<ProfileModel> updateProfile(request, token) async {
    final response = await _helper.post('user/profile', request, token);
    return ProfileModel.fromJson(response);
  }

  Future<ProfileModel> updateProfileImage(request, token) async {
    print('upimg');
    final response = await _helper.post('user/profile/image', request, token);
    return ProfileModel.fromJson(response);
  }

  Future<ProfileModel> getProfile(token) async {
    final response = await _helper.get('user/profile', token);
    return ProfileModel.fromJson(response);
  }

  Future<LoginModel> getEmailToken(token) async {
    final response = await _helper.get('auth/emailverification', token);
    return LoginModel.fromJson(response);
  }

  Future<ImageUpload> uploadPhoto(file, imageType, token) async {
    final response =
        await _helper.upload('image/upload', file, imageType, token);
    return ImageUpload.fromJson(response);
  }

  Future<GetMatchesModel> getMatches(token) async {
    final response = await _helper.get('swipe/matches', token);
    return GetMatchesModel.fromJson(response);
  }

  Future<SwipeSuggestions> getSwipeSuggestions(token, locationFilter) async {
    final response = await _helper.get(
        'swipe/suggest?locationFilter=' + locationFilter, token);
    return SwipeSuggestions.fromJson(response);
  }

  Future<Swipe> swipe(request, token) async {
    final response = await _helper.post('swipe', request, token);
    return Swipe.fromJson(response);
  }

  Future<ApiModel> songRequest(request, token) async {
    final response = await _helper.post('user/song-request', request, token);
    return ApiModel.fromJson(response);
  }

  Future<ApiModel> changePassword(request, token) async {
    final response = await _helper.post('auth/change-password', request, token);
    return ApiModel.fromJson(response);
  }

  Future<ApiModel> sendMessage(request, token) async {
    final response = await _helper.post('message', request, token);
    return ApiModel.fromJson(response);
  }
}
