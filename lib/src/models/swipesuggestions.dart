// To parse this JSON data, do
//
//     final swipeSuggestions = swipeSuggestionsFromJson(jsonString);

import 'dart:convert';

SwipeSuggestions swipeSuggestionsFromJson(String str) => SwipeSuggestions.fromJson(json.decode(str));

String swipeSuggestionsToJson(SwipeSuggestions data) => json.encode(data.toJson());

class SwipeSuggestions {
    SwipeSuggestions({
        this.message,
        this.data,
        this.responseCode,
        this.errors,
        this.logId,
    });

    String message;
    List<Datum> data;
    String responseCode;
    dynamic errors;
    dynamic logId;

    factory SwipeSuggestions.fromJson(Map<String, dynamic> json) => SwipeSuggestions(
        message: json["message"] == null ? null : json["message"],
        data: json["data"] == null ? null : List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
        responseCode: json["responseCode"] == null ? null : json["responseCode"],
        errors: json["errors"],
        logId: json["logId"],
    );

    Map<String, dynamic> toJson() => {
        "message": message == null ? null : message,
        "data": data == null ? null : List<dynamic>.from(data.map((x) => x.toJson())),
        "responseCode": responseCode == null ? null : responseCode,
        "errors": errors,
        "logId": logId,
    };
}

class Datum {
    Datum({
        this.id,
        this.firstName,
        this.lastName,
        this.bio,
        this.gender,
        this.dateOfBirth,
        this.workStatus,
        this.genderPreference,
        this.age,
        this.longitude,
        this.latitude,
        this.distanceInKm,
        this.distanceInMiles,
        this.swipeRadius,
        this.minAge,
        this.maxAge,
        this.profileImage,
        this.additionalImages,
    });

    int id;
    String firstName;
    String lastName;
    String bio;
    String gender;
    int dateOfBirth;
    String workStatus;
    List<String> genderPreference;
    int age;
    double longitude;
    double latitude;
    int distanceInKm;
    int distanceInMiles;
    int swipeRadius;
    int minAge;
    int maxAge;
    dynamic profileImage;
    List<dynamic> additionalImages;

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"] == null ? null : json["id"],
        firstName: json["firstName"] == null ? null : json["firstName"],
        lastName: json["lastName"] == null ? null : json["lastName"],
        bio: json["bio"] == null ? null : json["bio"],
        gender: json["gender"] == null ? null : json["gender"],
        dateOfBirth: json["dateOfBirth"] == null ? null : json["dateOfBirth"],
        workStatus: json["workStatus"] == null ? null : json["workStatus"],
        genderPreference: json["genderPreference"] == null ? null : List<String>.from(json["genderPreference"].map((x) => x)),
        age: json["age"] == null ? null : json["age"],
        longitude: json["longitude"] == null ? null : json["longitude"].toDouble(),
        latitude: json["latitude"] == null ? null : json["latitude"].toDouble(),
        distanceInKm: json["distanceInKm"] == null ? null : json["distanceInKm"],
        distanceInMiles: json["distanceInMiles"] == null ? null : json["distanceInMiles"],
        swipeRadius: json["swipeRadius"] == null ? null : json["swipeRadius"],
        minAge: json["minAge"] == null ? null : json["minAge"],
        maxAge: json["maxAge"] == null ? null : json["maxAge"],
        profileImage: json["profileImage"],
        additionalImages: json["additionalImages"] == null ? null : List<dynamic>.from(json["additionalImages"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "firstName": firstName == null ? null : firstName,
        "lastName": lastName == null ? null : lastName,
        "bio": bio == null ? null : bio,
        "gender": gender == null ? null : gender,
        "dateOfBirth": dateOfBirth == null ? null : dateOfBirth,
        "workStatus": workStatus == null ? null : workStatus,
        "genderPreference": genderPreference == null ? null : List<dynamic>.from(genderPreference.map((x) => x)),
        "age": age == null ? null : age,
        "longitude": longitude == null ? null : longitude,
        "latitude": latitude == null ? null : latitude,
        "distanceInKm": distanceInKm == null ? null : distanceInKm,
        "distanceInMiles": distanceInMiles == null ? null : distanceInMiles,
        "swipeRadius": swipeRadius == null ? null : swipeRadius,
        "minAge": minAge == null ? null : minAge,
        "maxAge": maxAge == null ? null : maxAge,
        "profileImage": profileImage,
        "additionalImages": additionalImages == null ? null : List<dynamic>.from(additionalImages.map((x) => x)),
    };
}