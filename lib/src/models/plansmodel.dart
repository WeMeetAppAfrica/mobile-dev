// To parse this JSON data, do
//
//     final plansModel = plansModelFromJson(jsonString);

import 'dart:convert';

PlansModel plansModelFromJson(String str) => PlansModel.fromJson(json.decode(str));

String plansModelToJson(PlansModel data) => json.encode(data.toJson());

class PlansModel {
    PlansModel({
        this.message,
        this.data,
        this.responseCode,
        this.errors,
        this.logId,
    });

    String message;
    List<Datum> data;
    dynamic responseCode;
    dynamic errors;
    dynamic logId;

    factory PlansModel.fromJson(Map<String, dynamic> json) => PlansModel(
        message: json["message"] == null ? null : json["message"],
        data: json["data"] == null ? null : List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
        responseCode: json["responseCode"],
        errors: json["errors"],
        logId: json["logId"],
    );

    Map<String, dynamic> toJson() => {
        "message": message == null ? null : message,
        "data": data == null ? null : List<dynamic>.from(data.map((x) => x.toJson())),
        "responseCode": responseCode,
        "errors": errors,
        "logId": logId,
    };
}

class Datum {
    Datum({
        this.name,
        this.code,
        this.amount,
        this.period,
        this.currency,
        this.currentPlan,
        this.limits,
    });

    String name;
    String code;
    int amount;
    String period;
    String currency;
    bool currentPlan;
    Limits limits;

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        name: json["name"] == null ? null : json["name"],
        code: json["code"] == null ? null : json["code"],
        amount: json["amount"] == null ? null : json["amount"],
        period: json["period"] == null ? null : json["period"],
        currency: json["currency"] == null ? null : json["currency"],
        currentPlan: json["currentPlan"] == null ? null : json["currentPlan"],
        limits: json["limits"] == null ? null : Limits.fromJson(json["limits"]),
    );

    Map<String, dynamic> toJson() => {
        "name": name == null ? null : name,
        "code": code == null ? null : code,
        "amount": amount == null ? null : amount,
        "period": period == null ? null : period,
        "currency": currency == null ? null : currency,
        "currentPlan": currentPlan == null ? null : currentPlan,
        "limits": limits == null ? null : limits.toJson(),
    };
}

class Limits {
    Limits({
        this.dailySwipeLimit,
        this.dailyMessageLimit,
        this.updateLocation,
    });

    int dailySwipeLimit;
    int dailyMessageLimit;
    bool updateLocation;

    factory Limits.fromJson(Map<String, dynamic> json) => Limits(
        dailySwipeLimit: json["dailySwipeLimit"] == null ? null : json["dailySwipeLimit"],
        dailyMessageLimit: json["dailyMessageLimit"] == null ? null : json["dailyMessageLimit"],
        updateLocation: json["updateLocation"] == null ? null : json["updateLocation"],
    );

    Map<String, dynamic> toJson() => {
        "dailySwipeLimit": dailySwipeLimit == null ? null : dailySwipeLimit,
        "dailyMessageLimit": dailyMessageLimit == null ? null : dailyMessageLimit,
        "updateLocation": updateLocation == null ? null : updateLocation,
    };
}
