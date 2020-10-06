// To parse this JSON data, do
//
//     final swipe = swipeFromJson(jsonString);

import 'dart:convert';

Swipe swipeFromJson(String str) => Swipe.fromJson(json.decode(str));

String swipeToJson(Swipe data) => json.encode(data.toJson());

class Swipe {
    Swipe({
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

    factory Swipe.fromJson(Map<String, dynamic> json) => Swipe(
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
        this.match,
        this.swipe,
    });

    bool match;
    SwipeClass swipe;

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        match: json["match"] == null ? null : json["match"],
        swipe: json["swipe"] == null ? null : SwipeClass.fromJson(json["swipe"]),
    );

    Map<String, dynamic> toJson() => {
        "match": match == null ? null : match,
        "swipe": swipe == null ? null : swipe.toJson(),
    };
}

class SwipeClass {
    SwipeClass({
        this.id,
        this.swiper,
        this.swipee,
        this.type,
    });

    int id;
    SwipeeClass swiper;
    SwipeeClass swipee;
    String type;

    factory SwipeClass.fromJson(Map<String, dynamic> json) => SwipeClass(
        id: json["id"] == null ? null : json["id"],
        swiper: json["swiper"] == null ? null : SwipeeClass.fromJson(json["swiper"]),
        swipee: json["swipee"] == null ? null : SwipeeClass.fromJson(json["swipee"]),
        type: json["type"] == null ? null : json["type"],
    );

    Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "swiper": swiper == null ? null : swiper.toJson(),
        "swipee": swipee == null ? null : swipee.toJson(),
        "type": type == null ? null : type,
    };
}

class SwipeeClass {
    SwipeeClass({
        this.id,
        this.firstName,
        this.lastName,
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
    });

    int id;
    String firstName;
    String lastName;
    String profileImage;
    String email;
    bool emailVerified;
    String phone;
    bool phoneVerified;
    String gender;
    int dateOfBirth;
    bool active;
    bool suspended;
    String type;

    factory SwipeeClass.fromJson(Map<String, dynamic> json) => SwipeeClass(
        id: json["id"] == null ? null : json["id"],
        firstName: json["firstName"] == null ? null : json["firstName"],
        lastName: json["lastName"] == null ? null : json["lastName"],
        profileImage: json["profileImage"] == null ? null : json["profileImage"],
        email: json["email"] == null ? null : json["email"],
        emailVerified: json["emailVerified"] == null ? null : json["emailVerified"],
        phone: json["phone"] == null ? null : json["phone"],
        phoneVerified: json["phoneVerified"] == null ? null : json["phoneVerified"],
        gender: json["gender"] == null ? null : json["gender"],
        dateOfBirth: json["dateOfBirth"] == null ? null : json["dateOfBirth"],
        active: json["active"] == null ? null : json["active"],
        suspended: json["suspended"] == null ? null : json["suspended"],
        type: json["type"] == null ? null : json["type"],
    );

    Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "firstName": firstName == null ? null : firstName,
        "lastName": lastName == null ? null : lastName,
        "profileImage": profileImage == null ? null : profileImage,
        "email": email == null ? null : email,
        "emailVerified": emailVerified == null ? null : emailVerified,
        "phone": phone == null ? null : phone,
        "phoneVerified": phoneVerified == null ? null : phoneVerified,
        "gender": gender == null ? null : gender,
        "dateOfBirth": dateOfBirth == null ? null : dateOfBirth,
        "active": active == null ? null : active,
        "suspended": suspended == null ? null : suspended,
        "type": type == null ? null : type,
    };
}
