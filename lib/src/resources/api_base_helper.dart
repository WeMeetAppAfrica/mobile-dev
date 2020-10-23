import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wemeet/src/blocs/bloc.dart';
import 'package:wemeet/src/resources/app_exceptions.dart';

class ApiBaseHelper {
  final String _baseUrl = "https://wemeetng.herokuapp.com/api/v1/";

  Future<dynamic> get(String url, token) async {
    var responseJson;
    print(token);
    try {
      final response = await http.get(
        _baseUrl + url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": 'Bearer ' + token
        },
      );
      responseJson = _returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  Future<dynamic> post(String url, Object request, [String token]) async {
    print(request);
    var responseJson;
    try {
      final response = await http.post(_baseUrl + url,
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Authorization": 'Bearer ' + token
          },
          body: jsonEncode(request));
      responseJson = _returnResponse(response);
      print('eeeee');
    } on SocketException {
      print('error');
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  Future<dynamic> upload(String url, imageFile, String imageType, token) async {
    var uri = Uri.parse(_baseUrl + url);
    var responseJson;

    try {
      var request = new http.MultipartRequest("POST", uri);
      //contentType: new MediaType('image', 'png'));
      request.headers.addAll({
        "Authorization": 'Bearer ' + token,
        "accept": "application/json",
        "Content-Type": 'multipart/form-data'
      });
      request.files.add(await http.MultipartFile.fromPath('file', imageFile,
          contentType: MediaType('image', 'png')));

      request.fields['imageType'] = imageType;
      print(request);
      var response = await request.send();
      print(response.statusCode);
      final res = await http.Response.fromStream(response);
      print(res.body);
      responseJson = _returnResponse(res);
    } on SocketException {
      print('error');
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  Future<dynamic> put(String url, request) async {
    var responseJson;
    try {
      final response = await http.put(_baseUrl + url,
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode(request));
      responseJson = _returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }
  // Future<dynamic> upload(String url) async {
  //   var postUri = Uri.parse(_baseUrl + url);
  //   var request = new http.MultipartRequest("POST", postUri);
  //   request.fields['user'] = 'blah';
  //   request.files.add(new http.MultipartFile.fromBytes('file', await File.fromUri("<path/to/file").readAsBytes(), contentType: new MediaType('image', 'jpeg')))

  //   request.send().then((response) {
  //     if (response.statusCode == 200) print("Uploaded!");
  //   });
  // }

  dynamic _returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        var responseJson;
        if (response.body.toString() == '' ||
            response.body.toString() == null) {
          responseJson =
              json.decode('{"message":"Account activated, proceed to login!"}');
        } else {
          // print(response.body);
          var decodeSucceeded = false;

          try {
            var x = json.decode(response.body);
            decodeSucceeded = true;
          } on FormatException catch (e) {
            print('The provided string is not valid JSON');
          }
          if (decodeSucceeded) {
            responseJson = json.decode(response.body);
          } else {
            responseJson = response.body;
          }
        }
        // print(responseJson);
        return responseJson;
      case 201:
        var responseJson;
        if (response.body.toString() == '' ||
            response.body.toString() == null) {
          responseJson =
              json.decode('{"message":"Account activated, proceed to login!"}');
        } else {
          // print(response.body);
          var decodeSucceeded = false;

          try {
            var x = json.decode(response.body);
            decodeSucceeded = true;
          } on FormatException catch (e) {
            print('The provided string is not valid JSON');
          }
          if (decodeSucceeded) {
            responseJson = json.decode(response.body);
          } else {
            responseJson = response.body;
          }
        }
        // print(responseJson);
        return responseJson;
      case 400:
        throw BadRequestException(response.body.toString());
      case 401:
      case 403:
        throw UnauthorisedException(response.body.toString());
      case 404:
        print(json.decode(response.body));
        throw FetchDataException(json.decode(response.body)['message']);
      case 500:
      default:
        throw FetchDataException(
            'Error occured while Communication with Server with StatusCode : ${response.statusCode}');
    }
  }
}
