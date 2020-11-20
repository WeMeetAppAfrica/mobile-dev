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
        this.id,
        this.transactionType,
        this.paymentProcessor,
        this.paymentMethod,
        this.amount,
        this.status,
        this.isSubscription,
        this.authorizationUrl,
        this.accessCode,
        this.reference,
        this.user,
        this.subscription,
    });

    int id;
    String transactionType;
    String paymentProcessor;
    dynamic paymentMethod;
    int amount;
    String status;
    bool isSubscription;
    String authorizationUrl;
    String accessCode;
    String reference;
    User user;
    dynamic subscription;

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"] == null ? null : json["id"],
        transactionType: json["transaction_type"] == null ? null : json["transaction_type"],
        paymentProcessor: json["payment_processor"] == null ? null : json["payment_processor"],
        paymentMethod: json["payment_method"],
        amount: json["amount"] == null ? null : json["amount"],
        status: json["status"] == null ? null : json["status"],
        isSubscription: json["isSubscription"] == null ? null : json["isSubscription"],
        authorizationUrl: json["authorization_url"] == null ? null : json["authorization_url"],
        accessCode: json["access_code"] == null ? null : json["access_code"],
        reference: json["reference"] == null ? null : json["reference"],
        user: json["user"] == null ? null : User.fromJson(json["user"]),
        subscription: json["subscription"],
    );

    Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "transaction_type": transactionType == null ? null : transactionType,
        "payment_processor": paymentProcessor == null ? null : paymentProcessor,
        "payment_method": paymentMethod,
        "amount": amount == null ? null : amount,
        "status": status == null ? null : status,
        "isSubscription": isSubscription == null ? null : isSubscription,
        "authorization_url": authorizationUrl == null ? null : authorizationUrl,
        "access_code": accessCode == null ? null : accessCode,
        "reference": reference == null ? null : reference,
        "user": user == null ? null : user.toJson(),
        "subscription": subscription,
    };
}

class User {
    User({
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
        this.lastSeen,
        this.dateCreated,
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
    int lastSeen;
    int dateCreated;

    factory User.fromJson(Map<String, dynamic> json) => User(
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
        lastSeen: json["lastSeen"] == null ? null : json["lastSeen"],
        dateCreated: json["dateCreated"] == null ? null : json["dateCreated"],
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
        "lastSeen": lastSeen == null ? null : lastSeen,
        "dateCreated": dateCreated == null ? null : dateCreated,
    };
}
