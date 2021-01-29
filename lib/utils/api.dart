import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:wemeet/config.dart';
import 'package:wemeet/providers/data.dart';

class WeMeetAPI {

  String _baseUrl = WeMeetConfig.baseUrl;
  HttpClient _httpClient = new HttpClient();
  DataProvider _dP = DataProvider();

  // Get the url
  String _getUrl(String endpoint){
    endpoint = endpoint.replaceAll("//", "/");

    if(endpoint.startsWith("/")){
      endpoint = endpoint.substring(1);
    }

    if (endpoint.endsWith("/")){
      endpoint = endpoint.substring(0, endpoint.length - 1);
    }
    return "$_baseUrl$endpoint";
  }

  // Compose the query data
  String composeQuery(Map data){
    if(data == null) return "";
    var params = [];
    data.forEach((key, value){
      String v = "$value";
      params.add("$key=${Uri.encodeComponent(v)}");
    });
    return params.join("&");
  }

  // Do GET request
  Future get(String endpoint, {Map query, bool token = true, String reqToken}) async {

    String url =
        _getUrl(endpoint) + ((query != null) ? "?" + composeQuery(query) : "");

    Uri uri = Uri.parse(url);
    print("GET: " + uri.toString());

    print("##########TOKEN" + _dP.token);

    var request = await _httpClient.openUrl("GET", uri);
    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json; charset=utf-8');
    if(token){
      request.headers.set(HttpHeaders.authorizationHeader, "Bearer ${reqToken ?? _dP.token}");
    }
    
    var response = await request.close();
    var responseBody = await response.transform(utf8.decoder).join();
    var dataResponse = await jsonDecode(responseBody);

    if(response.statusCode >= 300){
      throw dataResponse;
    }

    return dataResponse;
  }

  // Do POST request
  Future post(String endpoint, {dynamic data, bool token = true, String reqToken}) async{

    String u = _getUrl(endpoint);
    Uri uri = Uri.parse(u);
    print("POST: " + uri.toString());
    
    var request = await _httpClient.postUrl(uri);
    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json; charset=utf-8');
    if(token){
      request.headers.set(HttpHeaders.authorizationHeader, "Bearer ${reqToken ?? _dP.token}");
    }
    if(data != null){
      request.write(jsonEncode(data));
    }
    var response = await request.close();
    var responseBody = await response.transform(utf8.decoder).join();
    var dataResponse = await jsonDecode(responseBody);

    if(response.statusCode >= 300){
      throw dataResponse;
    }

    return dataResponse;
  }

  // Do Put request
  Future put(String endpoint, {dynamic data, bool token = true, String reqToken}) async {

    String u = _getUrl(endpoint);
    Uri uri = Uri.parse(u);
    print("PUT: " + uri.toString());

    var request = await _httpClient.putUrl(uri);
    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json; charset=utf-8');
    if(token){
      request.headers.set(HttpHeaders.authorizationHeader, "Bearer ${reqToken ??_dP.token}");
    }
    if(data != null){
      request.write(jsonEncode(data));
    }
    var response = await request.close();
    var responseBody = await response.transform(utf8.decoder).join();
    var dataResponse = await jsonDecode(responseBody);

    if(response.statusCode >= 300){
      throw dataResponse;
    }

    return dataResponse;
  }

  // Do DELETE request
  Future delete(String endpoint, {dynamic data, bool token = true, String reqToken}) async {

    String u = _getUrl(endpoint);
    Uri uri = Uri.parse(u);
    print("DELETE: " + uri.toString());

    var request = await _httpClient.deleteUrl(uri);
    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json; charset=utf-8');
    if(token){
      request.headers.set(HttpHeaders.authorizationHeader, "Bearer ${reqToken ?? _dP.token}");
    }
    if(data != null){
      request.write(jsonEncode(data));
    }
    var response = await request.close();
    var responseBody = await response.transform(utf8.decoder).join();
    var dataResponse = await jsonDecode(responseBody);

    if(response.statusCode >= 300){
      throw dataResponse;
    }

    return dataResponse;
  }

} 

WeMeetAPI api = WeMeetAPI();