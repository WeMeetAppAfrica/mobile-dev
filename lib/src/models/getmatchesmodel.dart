// To parse this JSON data, do
//
//     final getMatchesModel = getMatchesModelFromJson(jsonString);

import 'dart:convert';

GetMatchesModel getMatchesModelFromJson(String str) => GetMatchesModel.fromJson(json.decode(str));

String getMatchesModelToJson(GetMatchesModel data) => json.encode(data.toJson());

class GetMatchesModel {
    GetMatchesModel({
        this.message,
        this.data,
        this.responseCode,
        this.errors,
        this.logId,
    });

    String message;
    Data data;
    String responseCode;
    dynamic errors;
    dynamic logId;

    factory GetMatchesModel.fromJson(Map<String, dynamic> json) => GetMatchesModel(
        message: json["message"] == null ? null : json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        responseCode: json["responseCode"] == null ? null : json["responseCode"],
        errors: json["errors"],
        logId: json["logId"],
    );

    Map<String, dynamic> toJson() => {
        "message": message == null ? null : message,
        "data": data == null ? null : data.toJson(),
        "responseCode": responseCode == null ? null : responseCode,
        "errors": errors,
        "logId": logId,
    };
}

class Data {
    Data({
        this.content,
        this.totalPages,
        this.totalElements,
        this.pageNum,
        this.pageSize,
        this.numberOfElements,
    });

    List<dynamic> content;
    int totalPages;
    int totalElements;
    int pageNum;
    int pageSize;
    int numberOfElements;

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        content: json["content"] == null ? null : List<dynamic>.from(json["content"].map((x) => x)),
        totalPages: json["totalPages"] == null ? null : json["totalPages"],
        totalElements: json["totalElements"] == null ? null : json["totalElements"],
        pageNum: json["pageNum"] == null ? null : json["pageNum"],
        pageSize: json["pageSize"] == null ? null : json["pageSize"],
        numberOfElements: json["numberOfElements"] == null ? null : json["numberOfElements"],
    );

    Map<String, dynamic> toJson() => {
        "content": content == null ? null : List<dynamic>.from(content.map((x) => x)),
        "totalPages": totalPages == null ? null : totalPages,
        "totalElements": totalElements == null ? null : totalElements,
        "pageNum": pageNum == null ? null : pageNum,
        "pageSize": pageSize == null ? null : pageSize,
        "numberOfElements": numberOfElements == null ? null : numberOfElements,
    };
}
