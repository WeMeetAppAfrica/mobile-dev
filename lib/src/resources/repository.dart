import 'dart:async';
import 'dart:convert';
import 'package:wemeet/src/models/apimodel.dart';
import 'package:wemeet/src/models/login.dart';
import 'package:wemeet/src/resources/api_base_helper.dart';
import 'package:wemeet/src/resources/api_response.dart';


class Repository {
  ApiBaseHelper _helper = ApiBaseHelper();


  Future<ApiModel> signup(request) async {
    final response = await _helper.post('auth/signup', request);
    return ApiModel.fromJson(response);
  }

  Future<LoginModel> login(request) async {
    final response = await _helper.post('auth/login', request);
    return LoginModel.fromJson(response);
  }
}
