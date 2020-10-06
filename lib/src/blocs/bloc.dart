import 'dart:async';

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
  StreamController _loginController;
  StreamController _profileController;

  StreamSink<ApiResponse<ApiModel>> get userSink => _apiController.sink;
  Stream<ApiResponse<ApiModel>> get userStream => _apiController.stream;
  StreamSink<ApiResponse<ImageUpload>> get uploadSink => _uploadController.sink;
  Stream<ApiResponse<ImageUpload>> get uploadStream => _uploadController.stream;
  StreamSink<ApiResponse<LoginModel>> get loginSink => _loginController.sink;
  Stream<ApiResponse<LoginModel>> get loginStream => _loginController.stream;
  StreamSink<ApiResponse<ProfileModel>> get profileSink =>
      _profileController.sink;
  Stream<ApiResponse<ProfileModel>> get profileStream =>
      _profileController.stream;
  Bloc() {
    _apiController = BehaviorSubject<ApiResponse<ApiModel>>();
    _uploadController = BehaviorSubject<ApiResponse<ImageUpload>>();
    _loginController = BehaviorSubject<ApiResponse<LoginModel>>();
    _profileController = BehaviorSubject<ApiResponse<ProfileModel>>();
    _userRepository = Repository();
  }
  // Stream<User> get user => _userFetcher.stream;

  signup(request) async {
    loginSink.add(ApiResponse.loading('Loading...'));
    try {
      LoginModel user = await _userRepository.signup(request);
      loginSink.add(ApiResponse.done(user));
    } catch (e) {
      loginSink.add(ApiResponse.error(e.toString()));
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
      loginSink.add(ApiResponse.done(user));
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
      ProfileModel user = await _userRepository.updateProfileImage(request, token);
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
      print(e);
    }
  }
  getEmailToken(token) async {
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
      case 'ADDITIONAL_IMAGE1':
        imageTypes = 'ADDITIONAL_IMAGE';
        uploadSink.add(ApiResponse.addImage1Loading('Loading...'));
        break;
      case 'ADDITIONAL_IMAGE2':
        imageTypes = 'ADDITIONAL_IMAGE';
        uploadSink.add(ApiResponse.addImage2Loading('Loading...'));
        break;
      case 'ADDITIONAL_IMAGE3':
        imageTypes = 'ADDITIONAL_IMAGE';
        uploadSink.add(ApiResponse.addImage3Loading('Loading...'));
        break;
      case 'ADDITIONAL_IMAGE4':
        imageTypes = 'ADDITIONAL_IMAGE';
        uploadSink.add(ApiResponse.addImage4Loading('Loading...'));
        break;
      case 'ADDITIONAL_IMAGE5':
        imageTypes = 'ADDITIONAL_IMAGE';
        uploadSink.add(ApiResponse.addImage5Loading('Loading...'));
        break;
      default:
    }
    try {
      ImageUpload image =
          await _userRepository.uploadPhoto(request, imageTypes, token);
      switch (imageType) {
        case 'PROFILE_IMAGE':
          uploadSink.add(ApiResponse.proImageDone(image));
          break;
        case 'ADDITIONAL_IMAGE1':
          imageType = 'ADDITIONAL_IMAGE';
          uploadSink.add(ApiResponse.addImage1Done(image));
          break;
        case 'ADDITIONAL_IMAGE2':
          imageType = 'ADDITIONAL_IMAGE';
          uploadSink.add(ApiResponse.addImage2Done(image));
          break;
        case 'ADDITIONAL_IMAGE3':
          imageType = 'ADDITIONAL_IMAGE';
          uploadSink.add(ApiResponse.addImage3Done(image));
          break;
        case 'ADDITIONAL_IMAGE4':
          imageType = 'ADDITIONAL_IMAGE';
          uploadSink.add(ApiResponse.addImage4Done(image));
          break;
        case 'ADDITIONAL_IMAGE5':
          imageType = 'ADDITIONAL_IMAGE';
          uploadSink.add(ApiResponse.addImage5Done(image));
          break;
        default:
      }
    } catch (e) {
      uploadSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  dispose() {
    _apiController?.close();
    _uploadController?.close();
    _loginController?.close();
    _profileController?.close();
  }
}

final bloc = Bloc();
