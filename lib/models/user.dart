import 'package:wemeet/utils/converters.dart';

class UserModel {
  final int id;
  String email;
  String firstName;
  String lastName;
  String bio;
  String gender;
  int dob;
  String workStatus = "";
  List genderPreference;
  String type;
  int age;
  bool hideLocation;
  bool hideProfile;
  bool emailVerified;
  String phone;
  bool phoneVerified;
  bool active;
  bool suspended;
  String profileImage;
  int minAge;
  int maxAge;
  int distanceInKm;
  int swipeRadius;
  List additionalImages;

  Map data;

  UserModel({
    this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.bio,
    this.gender,
    this.dob,
    this.workStatus,
    this.genderPreference,
    this.type, 
    this.age,
    this.hideLocation,
    this.hideProfile,
    this.emailVerified,
    this.phone,
    this.phoneVerified,
    this.active,
    this.suspended,
    this.profileImage,
    this.minAge,
    this.maxAge,
    this.distanceInKm,
    this.additionalImages,
    this.swipeRadius,

    this.data
  });

  factory UserModel.fromMap(Map res) {
    return UserModel(
      id: ensureInt(res["id"]),
      email: res["email"] ?? "",
      phone: res["phone"] ?? "",
      firstName: res["firstName"] ?? "",
      lastName: res["lastName"] ?? "",
      bio: res["bio"] ?? "",
      gender: res["gender"] ?? "",
      dob: ensureInt(res["dateOfBirth"]),
      workStatus: res["workStatus"] ?? "",
      genderPreference: res["genderPreference"] ?? [],
      type: res["type"],
      age: ensureInt(res["age"]),
      hideLocation: res["hideLocation"] ?? false,
      hideProfile: res["hideProfile"] ?? false,
      emailVerified: res["emailVerified"] ?? false,
      phoneVerified: res["phoneVerified"] ?? false,
      active: res["active"] ?? false,
      profileImage: res["profileImage"],
      suspended: res["suspended"] ?? false,
      minAge: ensureInt(res["minAge"]),
      maxAge: ensureInt(res["maxAge"]),
      distanceInKm: ensureInt(res["distanceInKm"]) ?? 1,
      additionalImages: res["additionalImages"] ?? [],
      swipeRadius: ensureInt(res["swipeRadius"]),
      
      data: res
    );
  }

  String get fullName {
    return "$firstName $lastName".trim();
  }

  Map toMap() {
    Map entry = {
      "id": id,
      "email": email,
      "phone": phone,
      "firstName": firstName,
      "lastName": lastName,
      "bio": bio,
      "gender": gender,
      "dateOfBirth": dob,
      "workStatus": workStatus,
      "genderPreference": genderPreference,
      "type": type,
      "distanceInKm": distanceInKm,
      "minAge": minAge,
      "maxAge": maxAge,
      "swipeRadius": swipeRadius
    };

    return entry;
  }
}

/*
{
  "id":22,
  "firstName":"dwale",
  "lastName":"super",
  "bio":"bio",
  "gender":"MALE",
  "dateOfBirth":968362224000,
  "workStatus":"WORKING",
  "genderPreference":["FEMALE"],
  "type":"PREMIUM",
  "age":20,
  "hideLocation":true,
  "hideProfile":false,
  "longitude":18.720183,
  "latitude":-33.832253,
  "distanceInKm":null,
  "distanceInMiles":null,
  "email":"superdwale@gmail.com",
  "emailVerified":true,
  "phone":"08169477676",
  "phoneVerified":false,
  "active":true,
  "suspended":false,
  "lastSeen":1606946512860,
  "dateCreated":1600691901000,
  "swipeRadius":0,
  "minAge":18,
  "maxAge":56,
  "profileImage":
  "https://wemeetstorage.s3.eu-west-1.amazonaws.com/images/PROFILE_IMAGE_22_1bfec296-b8d9-45b6-9dab-121695b28f0a","additionalImages":[]
  }
*/
