// To parse this JSON data, do
//
//     final payModel = payModelFromJson(jsonString);

import 'dart:convert';

PayModel payModelFromJson(String str) => PayModel.fromJson(json.decode(str));

String payModelToJson(PayModel data) => json.encode(data.toJson());

class PayModel {
    PayModel({
        this.message,
        this.data,
        this.responseCode,
        this.errors,
        this.logId,
    });

    String message;
    Data data;
    dynamic responseCode;
    dynamic errors;
    dynamic logId;

    factory PayModel.fromJson(Map<String, dynamic> json) => PayModel(
        message: json["message"] == null ? null : json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        responseCode: json["responseCode"],
        errors: json["errors"],
        logId: json["logId"],
    );

    Map<String, dynamic> toJson() => {
        "message": message == null ? null : message,
        "data": data == null ? null : data.toJson(),
        "responseCode": responseCode,
        "errors": errors,
        "logId": logId,
    };
}

class Data {
    Data({
        this.authorizationUrl,
        this.accessCode,
        this.reference,
    });

    String authorizationUrl;
    String accessCode;
    String reference;

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        authorizationUrl: json["authorization_url"] == null ? null : json["authorization_url"],
        accessCode: json["access_code"] == null ? null : json["access_code"],
        reference: json["reference"] == null ? null : json["reference"],
    );

    Map<String, dynamic> toJson() => {
        "authorization_url": authorizationUrl == null ? null : authorizationUrl,
        "access_code": accessCode == null ? null : accessCode,
        "reference": reference == null ? null : reference,
    };
}
