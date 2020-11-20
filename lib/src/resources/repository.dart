import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wemeet/src/models/apimodel.dart';
import 'package:wemeet/src/models/getmatchesmodel.dart';
import 'package:wemeet/src/models/imageupload.dart';
import 'package:wemeet/src/models/login.dart';
import 'package:wemeet/src/models/musicmodel.dart';
import 'package:wemeet/src/models/paymodel.dart';
import 'package:wemeet/src/models/plansmodel.dart';
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

  Future<ProfileModel> updateLocation(request, token) async {
    final response = await _helper.post('user/location', request, token);
    return ProfileModel.fromJson(response);
  }

  Future<LoginModel> resetPassword(request) async {
    final response =
        await _helper.post('auth/accounts/reset-password', request);
    return LoginModel.fromJson(response);
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
    print(response);
    return LoginModel.fromJson(response);
  }

  Future<LoginModel> getForgotPass(email) async {
    print('aaa');
    final response =
        await _helper.getWOT('auth/accounts/forgot-password?email=$email');
    return LoginModel.fromJson(response);
  }

  Future<LoginModel> verifyForgotToken(email, token) async {
    print('aaa');
    final response = await _helper.getWOT(
        'auth/accounts/verify-password-token?email=$email&token=$token');
    response['data'] = null;
    print(response['data']);
    return LoginModel.fromJson(response);
  }

  Future<ImageUpload> uploadPhoto(file, imageType, token) async {
    final response =
        await _helper.upload('file/upload', file, imageType, token);
    return ImageUpload.fromJson(response);
  }

  Future<GetMatchesModel> getBlockedList(token) async {
    final response =
        await _helper.get('user/blocks?pageNum=0&pageSize=10', token);
    return GetMatchesModel.fromJson(response);
  }

  Future<GetMatchesModel> getMatches(token) async {
    final response = await _helper.get('swipe/matches', token);
    return GetMatchesModel.fromJson(response);
  }

  Future<MusicModel> getMusicList(token) async {
    final response =
        await _helper.get('file/music?pageNum=0&pageSize=10', token);
    return MusicModel.fromJson(response);
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

  Future<ApiModel> selfDelete(token) async {
    final response = await _helper.postOp('auth/self-delete', token);
    return ApiModel.fromJson(response);
  }

  Future<ApiModel> block(request, token) async {
    final response = await _helper.postOp('user/block?userId=$request', token);
    return ApiModel.fromJson(response);
  }

  Future<ApiModel> unblock(request, token) async {
    final response =
        await _helper.post('user/unblock?userId=$request', {}, token);
    return ApiModel.fromJson(response);
  }

  Future<ApiModel> report(request, token) async {
    final response = await _helper.post('user/report', request, token);
    return ApiModel.fromJson(response);
  }
  Future<ApiModel> logout(request, token) async {
    final response = await _helper.post('auth/logout', request, token);
    return ApiModel.fromJson(response);
  }

  Future<PlansModel> getPlans(token) async {
    final response = await _helper.get('payment/plans', token);
    return PlansModel.fromJson(response);
  }

  Future<PayModel> upgradePlan(request, token) async {
    final response = await _helper.post('payment/upgrade', request, token);
    return PayModel.fromJson(response);
  }

  Future<PayModel> verifyUpgrade(reference, token) async {
    final response =
        await _helper.get('payment/verify?reference=$reference', token);
    return PayModel.fromJson(response);
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
