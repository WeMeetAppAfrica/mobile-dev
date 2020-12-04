// To parse this JSON data, do
//
//     final loginModel = loginModelFromJson(jsonString);

import 'dart:convert';

LoginModel loginModelFromJson(String str) => LoginModel.fromJson(json.decode(str));

String loginModelToJson(LoginModel data) => json.encode(data.toJson());

class LoginModel {
    LoginModel({
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

    factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
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
        this.tokenInfo,
        this.user,
        this.token,
    });

    TokenInfo tokenInfo;
    User user;
    String token;

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        tokenInfo: json["tokenInfo"] == null ? null : TokenInfo.fromJson(json["tokenInfo"]),
        user: json["user"] == null ? null : User.fromJson(json["user"]),
        token: json["token"] == null ? null : json["token"],
    );

    Map<String, dynamic> toJson() => {
        "tokenInfo": tokenInfo == null ? null : tokenInfo.toJson(),
        "user": user == null ? null : user.toJson(),
        "token": token == null ? null : token,
    };
}

class TokenInfo {
    TokenInfo({
        this.accessToken,
        this.tokenType,
    });

    String accessToken;
    String tokenType;

    factory TokenInfo.fromJson(Map<String, dynamic> json) => TokenInfo(
        accessToken: json["accessToken"] == null ? null : json["accessToken"],
        tokenType: json["tokenType"] == null ? null : json["tokenType"],
    );

    Map<String, dynamic> toJson() => {
        "accessToken": accessToken == null ? null : accessToken,
        "tokenType": tokenType == null ? null : tokenType,
    };
}

class User {
    User({
        this.id,
        this.firstName,
        this.lastName,
        this.userName,
        this.profileImage,
        this.email,
        this.emailVerified,
        this.phone,
        this.phoneVerified,
        this.gender,
        this.dateOfBirth,
        this.active,
        this.suspended,
        this.type,
        this.name,
        this.jsonData
    });

    int id;
    String firstName;
    String lastName;
    dynamic userName;
    dynamic profileImage;
    String email;
    bool emailVerified;
    String phone;
    bool phoneVerified;
    dynamic gender;
    int dateOfBirth;
    bool active;
    bool suspended;
    String type;
    String name;

    Map jsonData = {};

    factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"] == null ? null : json["id"],
        firstName: json["firstName"] == null ? null : json["firstName"],
        lastName: json["lastName"] == null ? null : json["lastName"],
        userName: json["userName"],
        profileImage: json["profileImage"],
        email: json["email"] == null ? null : json["email"],
        emailVerified: json["emailVerified"] == null ? null : json["emailVerified"],
        phone: json["phone"] == null ? null : json["phone"],
        phoneVerified: json["phoneVerified"] == null ? null : json["phoneVerified"],
        gender: json["gender"],
        dateOfBirth: json["dateOfBirth"] == null ? null : json["dateOfBirth"],
        active: json["active"] == null ? null : json["active"],
        suspended: json["suspended"] == null ? null : json["suspended"],
        type: json["type"] == null ? null : json["type"],
        name: json["name"] == null ? null : json["name"],
        jsonData: json
    );

    Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "firstName": firstName == null ? null : firstName,
        "lastName": lastName == null ? null : lastName,
        "userName": userName,
        "profileImage": profileImage,
        "email": email == null ? null : email,
        "emailVerified": emailVerified == null ? null : emailVerified,
        "phone": phone == null ? null : phone,
        "phoneVerified": phoneVerified == null ? null : phoneVerified,
        "gender": gender,
        "dateOfBirth": dateOfBirth == null ? null : dateOfBirth,
        "active": active == null ? null : active,
        "suspended": suspended == null ? null : suspended,
        "type": type == null ? null : type,
        "name": name == null ? null : name,
    };
}
