// To parse this JSON data, do
//
//     final imageUpload = imageUploadFromJson(jsonString);

import 'dart:convert';

ImageUpload imageUploadFromJson(String str) => ImageUpload.fromJson(json.decode(str));

String imageUploadToJson(ImageUpload data) => json.encode(data.toJson());

class ImageUpload {
    ImageUpload({
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

    factory ImageUpload.fromJson(Map<String, dynamic> json) => ImageUpload(
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
        this.imageUrl,
    });

    String imageUrl;

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        imageUrl: json["imageUrl"] == null ? null : json["imageUrl"],
    );

    Map<String, dynamic> toJson() => {
        "imageUrl": imageUrl == null ? null : imageUrl,
    };
}
