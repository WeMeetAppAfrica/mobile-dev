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
    Data data;
    String responseCode;
    dynamic errors;
    dynamic logId;

    factory SwipeSuggestions.fromJson(Map<String, dynamic> json) => SwipeSuggestions(
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
        this.profiles,
        this.swipesLeft,
    });

    List<Profile> profiles;
    int swipesLeft;

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        profiles: json["profiles"] == null ? null : List<Profile>.from(json["profiles"].map((x) => Profile.fromJson(x))),
        swipesLeft: json["swipesLeft"] == null ? null : json["swipesLeft"],
    );

    Map<String, dynamic> toJson() => {
        "profiles": profiles == null ? null : List<dynamic>.from(profiles.map((x) => x.toJson())),
        "swipesLeft": swipesLeft == null ? null : swipesLeft,
    };
}

class Profile {
    Profile({
        this.id,
        this.firstName,
        this.lastName,
        this.bio,
        this.gender,
        this.dateOfBirth,
        this.workStatus,
        this.genderPreference,
        this.type,
        this.age,
        this.hideLocation,
        this.hideProfile,
        this.longitude,
        this.latitude,
        this.distanceInKm,
        this.distanceInMiles,
        this.email,
        this.emailVerified,
        this.phone,
        this.phoneVerified,
        this.active,
        this.suspended,
        this.lastSeen,
        this.dateCreated,
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
    String type;
    int age;
    bool hideLocation;
    bool hideProfile;
    double longitude;
    double latitude;
    int distanceInKm;
    int distanceInMiles;
    String email;
    bool emailVerified;
    String phone;
    bool phoneVerified;
    bool active;
    bool suspended;
    int lastSeen;
    int dateCreated;
    int swipeRadius;
    int minAge;
    int maxAge;
    String profileImage;
    List<String> additionalImages;

    factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        id: json["id"] == null ? null : json["id"],
        firstName: json["firstName"] == null ? null : json["firstName"],
        lastName: json["lastName"] == null ? null : json["lastName"],
        bio: json["bio"] == null ? null : json["bio"],
        gender: json["gender"] == null ? null : json["gender"],
        dateOfBirth: json["dateOfBirth"] == null ? null : json["dateOfBirth"],
        workStatus: json["workStatus"] == null ? null : json["workStatus"],
        genderPreference: json["genderPreference"] == null ? null : List<String>.from(json["genderPreference"].map((x) => x)),
        type: json["type"] == null ? null : json["type"],
        age: json["age"] == null ? null : json["age"],
        hideLocation: json["hideLocation"] == null ? null : json["hideLocation"],
        hideProfile: json["hideProfile"] == null ? null : json["hideProfile"],
        longitude: json["longitude"] == null ? null : json["longitude"].toDouble(),
        latitude: json["latitude"] == null ? null : json["latitude"].toDouble(),
        distanceInKm: json["distanceInKm"] == null ? null : json["distanceInKm"],
        distanceInMiles: json["distanceInMiles"] == null ? null : json["distanceInMiles"],
        email: json["email"] == null ? null : json["email"],
        emailVerified: json["emailVerified"] == null ? null : json["emailVerified"],
        phone: json["phone"] == null ? null : json["phone"],
        phoneVerified: json["phoneVerified"] == null ? null : json["phoneVerified"],
        active: json["active"] == null ? null : json["active"],
        suspended: json["suspended"] == null ? null : json["suspended"],
        lastSeen: json["lastSeen"] == null ? null : json["lastSeen"],
        dateCreated: json["dateCreated"] == null ? null : json["dateCreated"],
        swipeRadius: json["swipeRadius"] == null ? null : json["swipeRadius"],
        minAge: json["minAge"] == null ? null : json["minAge"],
        maxAge: json["maxAge"] == null ? null : json["maxAge"],
        profileImage: json["profileImage"] == null ? null : json["profileImage"],
        additionalImages: json["additionalImages"] == null ? null : List<String>.from(json["additionalImages"].map((x) => x)),
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
        "type": type == null ? null : type,
        "age": age == null ? null : age,
        "hideLocation": hideLocation == null ? null : hideLocation,
        "hideProfile": hideProfile == null ? null : hideProfile,
        "longitude": longitude == null ? null : longitude,
        "latitude": latitude == null ? null : latitude,
        "distanceInKm": distanceInKm == null ? null : distanceInKm,
        "distanceInMiles": distanceInMiles == null ? null : distanceInMiles,
        "email": email == null ? null : email,
        "emailVerified": emailVerified == null ? null : emailVerified,
        "phone": phone == null ? null : phone,
        "phoneVerified": phoneVerified == null ? null : phoneVerified,
        "active": active == null ? null : active,
        "suspended": suspended == null ? null : suspended,
        "lastSeen": lastSeen == null ? null : lastSeen,
        "dateCreated": dateCreated == null ? null : dateCreated,
        "swipeRadius": swipeRadius == null ? null : swipeRadius,
        "minAge": minAge == null ? null : minAge,
        "maxAge": maxAge == null ? null : maxAge,
        "profileImage": profileImage == null ? null : profileImage,
        "additionalImages": additionalImages == null ? null : List<dynamic>.from(additionalImages.map((x) => x)),
    };
}
