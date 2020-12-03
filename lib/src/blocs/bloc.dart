import 'dart:async';
import 'dart:convert';

import 'package:wemeet/src/models/MessageModel.dart';
import 'package:wemeet/src/models/apimodel.dart';
import 'package:wemeet/src/models/getmatchesmodel.dart';
import 'package:wemeet/src/models/imageupload.dart';
import 'package:wemeet/src/models/login.dart';
import 'package:wemeet/src/models/musicmodel.dart';
import 'package:wemeet/src/models/paymodel.dart';
import 'package:wemeet/src/models/plansmodel.dart';
import 'package:wemeet/src/models/profilemodel.dart';
import 'package:wemeet/src/resources/api_response.dart';

import 'package:rxdart/rxdart.dart';
import '../resources/repository.dart';

class Bloc {
  Repository _userRepository;

  StreamController _apiController;
  StreamController _planController;
  StreamController _payController;
  StreamController _musicController;
  StreamController _uploadController;
  StreamController _messageController;
  StreamController _songController;
  StreamController _loginController;
  StreamController _matchesController;
  StreamController _registerController;
  StreamController _profileController;
  StreamController _profileLocController;

  StreamSink<ApiResponse<ApiModel>> get userSink => _apiController.sink;
  Stream<ApiResponse<ApiModel>> get userStream => _apiController.stream;
  StreamSink<ApiResponse<GetMatchesModel>> get matchesSink =>
      _matchesController.sink;
  Stream<ApiResponse<GetMatchesModel>> get matchesStream =>
      _matchesController.stream;
  StreamSink<ApiResponse<PlansModel>> get planSink => _planController.sink;
  Stream<ApiResponse<PlansModel>> get planStream => _planController.stream;
  StreamSink<ApiResponse<PayModel>> get paySink => _payController.sink;
  Stream<ApiResponse<PayModel>> get payStream => _payController.stream;
  StreamSink<ApiResponse<MusicModel>> get musicSink => _musicController.sink;
  Stream<ApiResponse<MusicModel>> get musicStream => _musicController.stream;
  StreamSink<ApiResponse<ImageUpload>> get uploadSink => _uploadController.sink;
  Stream<ApiResponse<ImageUpload>> get uploadStream => _uploadController.stream;
  StreamSink<ApiResponse<LoginModel>> get loginSink => _loginController.sink;
  Stream<ApiResponse<LoginModel>> get loginStream => _loginController.stream;
  StreamSink<ApiResponse<LoginModel>> get registerSink =>
      _registerController.sink;
  Stream<ApiResponse<LoginModel>> get registerStream =>
      _registerController.stream;
  StreamSink<ApiResponse<MessageModel>> get messageSink =>
      _messageController.sink;
  Stream<ApiResponse<MessageModel>> get messageStream =>
      _messageController.stream;
  StreamSink<ApiResponse<ApiModel>> get songSink => _songController.sink;
  Stream<ApiResponse<ApiModel>> get songStream => _songController.stream;
  StreamSink<ApiResponse<ProfileModel>> get profileSink =>
      _profileController.sink;
  Stream<ApiResponse<ProfileModel>> get profileStream =>
      _profileController.stream;
  StreamSink<ApiResponse<ProfileModel>> get profileLocSink =>
      _profileLocController.sink;
  Stream<ApiResponse<ProfileModel>> get profileLocStream =>
      _profileLocController.stream;
  Bloc() {
    _apiController = BehaviorSubject<ApiResponse<ApiModel>>();
    _planController = BehaviorSubject<ApiResponse<PlansModel>>();
    _payController = BehaviorSubject<ApiResponse<PayModel>>();
    _musicController = BehaviorSubject<ApiResponse<MusicModel>>();
    _uploadController = BehaviorSubject<ApiResponse<ImageUpload>>();
    _loginController = BehaviorSubject<ApiResponse<LoginModel>>();
    _messageController = BehaviorSubject<ApiResponse<MessageModel>>();
    _matchesController = BehaviorSubject<ApiResponse<GetMatchesModel>>();
    _songController = BehaviorSubject<ApiResponse<ApiModel>>();
    _registerController = BehaviorSubject<ApiResponse<LoginModel>>();
    _profileController = BehaviorSubject<ApiResponse<ProfileModel>>();
    _profileLocController = BehaviorSubject<ApiResponse<ProfileModel>>();
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
      print('object $user');
      profileSink.add(ApiResponse.done(user));
    } catch (e) {
      profileSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  updateProfileLoc(request, token) async {
    print('request');
    profileLocSink.add(ApiResponse.loading('Loading...'));
    try {
      ProfileModel user = await _userRepository.updateProfile(request, token);
      print('object $user');
      profileLocSink.add(ApiResponse.done(user));
    } catch (e) {
      profileLocSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  selfDelete(token) async {
    print('request');
    userSink.add(ApiResponse.loading('Loading...'));
    try {
      ApiModel user = await _userRepository.selfDelete(token);
      print('object $user');
      userSink.add(ApiResponse.selfDelete(user));
    } catch (e) {
      userSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  updateLocation(request, token) async {
    print('request');
    profileSink.add(ApiResponse.loading('Loading...'));
    try {
      ProfileModel user = await _userRepository.updateLocation(request, token);
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

  getPlans(token) async {
    print('request');
    planSink.add(ApiResponse.loading('Loading...'));
    try {
      PlansModel user = await _userRepository.getPlans(token);
      print(user);
      planSink.add(ApiResponse.done(user));
    } catch (e) {
      planSink.add(ApiResponse.error(e.toString()));
      try {
        if (json.decode(e.toString())['responseCode'] == 'INVALID_TOKEN') {
          planSink.add(ApiResponse.logout(e.toString()));
        } else {
          planSink.add(ApiResponse.error(e.toString()));
        }
      } catch (w) {
        print(e);
      }
    }
  }

  upgradePlan(request, amount, token) async {
    print('request');
    paySink.add(ApiResponse.loading('Loading...'));
    try {
      PayModel user = await _userRepository.upgradePlan(request, token);
      print(user);
      paySink.add(ApiResponse.upgradePlan(amount.toString(), user));
    } catch (e) {
      paySink.add(ApiResponse.error(e.toString()));
      try {
        if (json.decode(e.toString())['responseCode'] == 'INVALID_TOKEN') {
          paySink.add(ApiResponse.logout(e.toString()));
        } else {
          paySink.add(ApiResponse.error(e.toString()));
        }
      } catch (w) {
        print(e);
      }
    }
  }

  verifyUpgrade(reference, token) async {
    print('reference');
    paySink.add(ApiResponse.loading('Loading...'));
    try {
      PayModel user = await _userRepository.verifyUpgrade(reference, token);
      print(user);
      paySink.add(ApiResponse.verifyUpgrade(user));
    } catch (e) {
      paySink.add(ApiResponse.error(e.toString()));
      try {
        if (json.decode(e.toString())['responseCode'] == 'INVALID_TOKEN') {
          paySink.add(ApiResponse.logout(e.toString()));
        } else {
          paySink.add(ApiResponse.error(e.toString()));
        }
      } catch (w) {
        print(e);
      }
    }
  }

  getMusic(token) async {
    print('reference');
    musicSink.add(ApiResponse.loading('Loading...'));
    try {
      MusicModel user = await _userRepository.getMusicList(token);
      print('user');
      print(user);
      musicSink.add(ApiResponse.done(user));
    } catch (e) {
      musicSink.add(ApiResponse.error(e.toString()));
      try {
        if (json.decode(e.toString())['responseCode'] == 'INVALID_TOKEN') {
          musicSink.add(ApiResponse.logout(e.toString()));
        } else {
          musicSink.add(ApiResponse.error(e.toString()));
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

  resendEmailToken(token) async {
    print('request');
    loginSink.add(ApiResponse.loading('Loading...'));
    try {
      LoginModel user = await _userRepository.resendEmailToken(token);
      loginSink.add(ApiResponse.resendEmailToken(user));
    } catch (e) {
      loginSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  sendMessage(request, token) async {
    print('request');
    print(token);
    messageSink.add(ApiResponse.loading('Loading...'));
    try {
      MessageModel user = await _userRepository.sendMessage(request, token);
      messageSink.add(ApiResponse.sendMessage(user));
    } catch (e) {
      messageSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  loginMessages(request, token) async {
    print('request');
    print(request);
    messageSink.add(ApiResponse.loading('Loading...'));
    try {
      MessageModel user = await _userRepository.loginMessages(request, token);
      messageSink.add(ApiResponse.loginMessages(user));
    } catch (e) {
      messageSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  getMessages(request, token) async {
    print('request');
    print(token);
    messageSink.add(ApiResponse.loading('Loading...'));
    try {
      MessageModel user = await _userRepository.getMessages(request, token);
      messageSink.add(ApiResponse.getMessages(user));
    } catch (e) {
      messageSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  getChats(token) async {
    print('request');
    print(token);
    messageSink.add(ApiResponse.loading('Loading...'));
    try {
      MessageModel user = await _userRepository.getChats(token);
      print(user);
      print('ahah');
      messageSink.add(ApiResponse.getChats(user));
    } catch (e) {
      messageSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  sendMedia(request, token) async {
    print('request');
    print(token);
    messageSink.add(ApiResponse.loading('Loading...'));
    try {
      MessageModel user = await _userRepository.sendMessage(request, token);
      messageSink.add(ApiResponse.sendMedia(user));
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

  block(request, token) async {
    print('request');
    userSink.add(ApiResponse.loading('Loading...'));
    try {
      ApiModel user = await _userRepository.block(request, token);
      userSink.add(ApiResponse.blocked(user));
    } catch (e) {
      userSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  unblock(request, token) async {
    print('request');
    userSink.add(ApiResponse.loading('Loading...'));
    try {
      ApiModel user = await _userRepository.unblock(request, token);
      userSink.add(ApiResponse.unblocked(user));
    } catch (e) {
      userSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  report(request, token) async {
    print('request');
    print(request);
    userSink.add(ApiResponse.loading('Loading...'));
    try {
      ApiModel user = await _userRepository.report(request, token);
      userSink.add(ApiResponse.reported(user));
    } catch (e) {
      userSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  logout(request, token) async {
    print('request');
    userSink.add(ApiResponse.loading('Loading...'));
    try {
      ApiModel user = await _userRepository.logout(request, token);
      userSink.add(ApiResponse.logout('user'));
    } catch (e) {
      userSink.add(ApiResponse.error(e.toString()));
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

  getForgotPass(email) async {
    print('request');
    loginSink.add(ApiResponse.loading('Loading...'));
    try {
      LoginModel user = await _userRepository.getForgotPass(email);
      loginSink.add(ApiResponse.forgotPass(user));
    } catch (e) {
      loginSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  verifyForgotToken(email, token) async {
    print('request');
    loginSink.add(ApiResponse.loading('Loading...'));
    try {
      LoginModel user = await _userRepository.verifyForgotToken(email, token);
      loginSink.add(ApiResponse.verifyForgotToken(user));
    } catch (e) {
      loginSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  getBlockedList(token) async {
    print('request');
    matchesSink.add(ApiResponse.loading('Loading...'));
    try {
      GetMatchesModel user = await _userRepository.getBlockedList(token);
      matchesSink.add(ApiResponse.getBlockedList(user));
    } catch (e) {
      matchesSink.add(ApiResponse.error(e.toString()));
      print(e);
    }
  }

  resetPassword(request) async {
    print('request');
    loginSink.add(ApiResponse.loading('Loading...'));
    try {
      LoginModel user = await _userRepository.resetPassword(request);
      loginSink.add(ApiResponse.resetPassword(user));
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
    _planController?.close();
    _payController?.close();
    _musicController?.close();
    _uploadController?.close();
    _loginController?.close();
    _messageController?.close();
    _matchesController?.close();
    _songController?.close();
    _registerController?.close();
    _profileController?.close();
    _profileLocController?.close();
  }
}

final bloc = Bloc();
