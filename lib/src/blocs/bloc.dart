import 'dart:async';
import 'dart:convert';

import 'package:wemeet/src/models/apimodel.dart';
import 'package:wemeet/src/models/imageupload.dart';
import 'package:wemeet/src/models/login.dart';
import 'package:wemeet/src/models/profilemodel.dart';
import 'package:wemeet/src/resources/api_response.dart';

import 'package:rxdart/rxdart.dart';
import '../resources/repository.dart';

class Bloc {
  Repository _userRepository;

  StreamController _apiController;
  StreamController _uploadController;
  StreamController _messageController;
  StreamController _songController;
  StreamController _loginController;
  StreamController _registerController;
  StreamController _profileController;

  StreamSink<ApiResponse<ApiModel>> get userSink => _apiController.sink;
  Stream<ApiResponse<ApiModel>> get userStream => _apiController.stream;
  StreamSink<ApiResponse<ImageUpload>> get uploadSink => _uploadController.sink;
  Stream<ApiResponse<ImageUpload>> get uploadStream => _uploadController.stream;
  StreamSink<ApiResponse<LoginModel>> get loginSink => _loginController.sink;
  Stream<ApiResponse<LoginModel>> get loginStream => _loginController.stream;
  StreamSink<ApiResponse<LoginModel>> get registerSink =>
      _registerController.sink;
  Stream<ApiResponse<LoginModel>> get registerStream =>
      _registerController.stream;
  StreamSink<ApiResponse<ApiModel>> get messageSink => _messageController.sink;
  Stream<ApiResponse<ApiModel>> get messageStream => _messageController.stream;
  StreamSink<ApiResponse<ApiModel>> get songSink => _songController.sink;
  Stream<ApiResponse<ApiModel>> get songStream => _songController.stream;
  StreamSink<ApiResponse<ProfileModel>> get profileSink =>
      _profileController.sink;
  Stream<ApiResponse<ProfileModel>> get profileStream =>
      _profileController.stream;
  Bloc() {
    _apiController = BehaviorSubject<ApiResponse<ApiModel>>();
    _uploadController = BehaviorSubject<ApiResponse<ImageUpload>>();
    _loginController = BehaviorSubject<ApiResponse<LoginModel>>();
    _messageController = BehaviorSubject<ApiResponse<ApiModel>>();
    _songController = BehaviorSubject<ApiResponse<ApiModel>>();
    _registerController = BehaviorSubject<ApiResponse<LoginModel>>();
    _profileController = BehaviorSubject<ApiResponse<ProfileModel>>();
    _userRepository = Repository();
  }
  // Stream<User> get user => _userFetcher.stream;

  signup(request) async {
    registerSink.add(ApiResponse.loading('Loading...'));
    try {
      LoginModel user = await _userRepository.signup(request);
      registerSink.add(ApiResponse.done(user));
    } catch (e) {
      registerSink.add(ApiResponse.error(e.toString()));
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

  emailVerification(request, token) async {
    loginSink.add(ApiResponse.loading('Loading...'));
    try {
      LoginModel user = await _userRepository.emailVerification(request, token);
      loginSink.add(ApiResponse.activated(user));
    } catch (e) {
      loginSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  updateProfile(request, token) async {
    print('request');
    profileSink.add(ApiResponse.loading('Loading...'));
    try {
      ProfileModel user = await _userRepository.updateProfile(request, token);
      profileSink.add(ApiResponse.done(user));
    } catch (e) {
      profileSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  updateProfileImage(request, token) async {
    print('request');
    profileSink.add(ApiResponse.loading('Loading...'));
    try {
      ProfileModel user =
          await _userRepository.updateProfileImage(request, token);
      profileSink.add(ApiResponse.done(user));
    } catch (e) {
      profileSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  getProfile(token) async {
    print('request');
    profileSink.add(ApiResponse.loading('Loading...'));
    try {
      ProfileModel user = await _userRepository.getProfile(token);
      profileSink.add(ApiResponse.getProfile(user));
    } catch (e) {
      profileSink.add(ApiResponse.error(e.toString()));
      try {
        if (json.decode(e.toString())['responseCode'] == 'INVALID_TOKEN') {
          profileSink.add(ApiResponse.logout(e.toString()));
        } else {
          profileSink.add(ApiResponse.error(e.toString()));
        }
      } catch (w) {
        print(e);
      }
    }
  }

  changePassword(request, token) async {
    print('request');
    userSink.add(ApiResponse.loading('Loading...'));
    try {
      ApiModel user = await _userRepository.changePassword(request, token);
      userSink.add(ApiResponse.done(user));
    } catch (e) {
      userSink.add(ApiResponse.error(e.toString()));
      try {
        if (json.decode(e.toString())['responseCode'] == 'INVALID_TOKEN') {
          userSink.add(ApiResponse.logout(e.toString()));
        } else {
          userSink.add(ApiResponse.error(e.toString()));
        }
      } catch (w) {
        print(e);
      }
    }
  }

  getEmailToken(token) async {
    print('request');
    registerSink.add(ApiResponse.loading('Loading...'));
    try {
      LoginModel user = await _userRepository.getEmailToken(token);
      registerSink.add(ApiResponse.getEmailToken(user));
    } catch (e) {
      registerSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  sendMessage(request, token) async {
    print('request');
    messageSink.add(ApiResponse.loading('Loading...'));
    try {
      ApiModel user = await _userRepository.sendMessage(request, token);
      messageSink.add(ApiResponse.sendMessage(user));
    } catch (e) {
      messageSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }
  songRequest(request, token) async {
    print('request');
    songSink.add(ApiResponse.loading('Loading...'));
    try {
      ApiModel user = await _userRepository.songRequest(request, token);
      songSink.add(ApiResponse.songRequest(user));
    } catch (e) {
      songSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  getLoginEmailToken(token) async {
    print('request');
    loginSink.add(ApiResponse.loading('Loading...'));
    try {
      LoginModel user = await _userRepository.getEmailToken(token);
      loginSink.add(ApiResponse.getEmailToken(user));
    } catch (e) {
      loginSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  updateImageProfile(request, imageType, token) async {
    print('request');
    switch (imageType) {
      case 'PROFILE_IMAGE':
        break;
      default:
    }
    profileSink.add(ApiResponse.loading('Loading...'));
    try {
      ProfileModel user = await _userRepository.updateProfile(request, token);
      profileSink.add(ApiResponse.done(user));
    } catch (e) {
      profileSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  uploadPhoto(request, imageType, token) async {
    var imageTypes;
    switch (imageType) {
      case 'PROFILE_IMAGE':
        imageTypes = 'PROFILE_IMAGE';
        uploadSink.add(ApiResponse.proImageLoading('Loading...'));
        break;
      case 'ADDITIONAL_IMAGE':
        imageTypes = 'ADDITIONAL_IMAGE';
        uploadSink.add(ApiResponse.addImage1Loading('Loading...'));
        break;
    }
    try {
      ImageUpload image =
          await _userRepository.uploadPhoto(request, imageTypes, token);
      switch (imageType) {
        case 'PROFILE_IMAGE':
          uploadSink.add(ApiResponse.proImageDone(image));
          break;
        case 'ADDITIONAL_IMAGE':
          imageType = 'ADDITIONAL_IMAGE';
          uploadSink.add(ApiResponse.addImage1Done(image));
          break;
      }
    } catch (e) {
      uploadSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  uploadAddPhoto(request, token, index) async {
    uploadSink.add(ApiResponse.addImageLoading(index));
    try {
      ImageUpload user =
          await _userRepository.uploadPhoto(request, 'ADDITIONAL_IMAGE', token);
      print(index);
      print(user);
      uploadSink.add(ApiResponse.addImageDone(index, user));
    } catch (e) {
      uploadSink.add(ApiResponse.addImgError(e.toString()));
      print(e);
    }
  }

  uploadProPhoto(request, token) async {
    uploadSink.add(ApiResponse.proImageLoading('index'));
    try {
      ImageUpload user =
          await _userRepository.uploadPhoto(request, 'PROFILE_IMAGE', token);
      uploadSink.add(ApiResponse.proImageDone(user));
    } catch (e) {
      uploadSink.add(ApiResponse.proImgError(e.toString()));
      print(e);
    }
  }

  dispose() {
    _apiController?.close();
    _uploadController?.close();
    _loginController?.close();
    _messageController?.close();
    _songController?.close();
    _registerController?.close();
    _profileController?.close();
  }
}

final bloc = Bloc();
