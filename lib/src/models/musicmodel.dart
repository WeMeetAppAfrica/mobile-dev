// To parse this JSON data, do
//
//     final musicModel = musicModelFromJson(jsonString);

import 'dart:convert';

MusicModel musicModelFromJson(String str) => MusicModel.fromJson(json.decode(str));

String musicModelToJson(MusicModel data) => json.encode(data.toJson());

class MusicModel {
    MusicModel({
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

    factory MusicModel.fromJson(Map<String, dynamic> json) => MusicModel(
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

    List<Content> content;
    int totalPages;
    int totalElements;
    int pageNum;
    int pageSize;
    int numberOfElements;

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        content: json["content"] == null ? null : List<Content>.from(json["content"].map((x) => Content.fromJson(x))),
        totalPages: json["totalPages"] == null ? null : json["totalPages"],
        totalElements: json["totalElements"] == null ? null : json["totalElements"],
        pageNum: json["pageNum"] == null ? null : json["pageNum"],
        pageSize: json["pageSize"] == null ? null : json["pageSize"],
        numberOfElements: json["numberOfElements"] == null ? null : json["numberOfElements"],
    );

    Map<String, dynamic> toJson() => {
        "content": content == null ? null : List<dynamic>.from(content.map((x) => x.toJson())),
        "totalPages": totalPages == null ? null : totalPages,
        "totalElements": totalElements == null ? null : totalElements,
        "pageNum": pageNum == null ? null : pageNum,
        "pageSize": pageSize == null ? null : pageSize,
        "numberOfElements": numberOfElements == null ? null : numberOfElements,
    };
}

class Content {
    Content({
        this.id,
        this.artist,
        this.isPlaying,
        this.isSelected,
        this.title,
        this.songUrl,
        this.artworkUrl,
        this.uploadedBy,
    });

    int id;
    String artist;
    bool isPlaying;
    bool isSelected;
    String title;
    String songUrl;
    String artworkUrl;
    UploadedBy uploadedBy;

    factory Content.fromJson(Map<String, dynamic> json) => Content(
        id: json["id"] == null ? null : json["id"],
        artist: json["artist"] == null ? null : json["artist"],
        isPlaying: json["isPlaying"] == null ? false : json["isPlaying"],
        isSelected: json["isSelected"] == null ? false : json["isSelected"],
        title: json["title"] == null ? null : json["title"],
        songUrl: json["songUrl"] == null ? null : json["songUrl"],
        artworkUrl: json["artworkURL"] == null ? null : json["artworkURL"],
        uploadedBy: json["uploadedBy"] == null ? null : UploadedBy.fromJson(json["uploadedBy"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "artist": artist == null ? null : artist,
        "isPlaying": isPlaying == null ? false : isPlaying,
        "isSelected": isSelected == null ? false : isSelected,
        "title": title == null ? null : title,
        "songUrl": songUrl == null ? null : songUrl,
        "artworkURL": artworkUrl == null ? null : artworkUrl,
        "uploadedBy": uploadedBy == null ? null : uploadedBy.toJson(),
    };

    String get fileUrl {
      if(songUrl == null || songUrl.isEmpty) {
        return "";
      }

      if(songUrl.length > 5) {
        List ss = songUrl.split(".");
        if(ss.isEmpty) {
          return songUrl + ".mp3";
        }

        // make sure it is an audio file
        List<String> formats = ["mp3", "wav", "m3u"];
        if(!formats.contains(ss.last.toLowerCase())) {
          return songUrl + ".mp3";
        }
      }

      return songUrl;
    }
}

class UploadedBy {
    UploadedBy({
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
    dynamic profileImage;
    String email;
    bool emailVerified;
    String phone;
    bool phoneVerified;
    String gender;
    int dateOfBirth;
    bool active;
    bool suspended;
    String type;
    dynamic lastSeen;
    int dateCreated;

    factory UploadedBy.fromJson(Map<String, dynamic> json) => UploadedBy(
        id: json["id"] == null ? null : json["id"],
        firstName: json["firstName"] == null ? null : json["firstName"],
        lastName: json["lastName"] == null ? null : json["lastName"],
        profileImage: json["profileImage"],
        email: json["email"] == null ? null : json["email"],
        emailVerified: json["emailVerified"] == null ? null : json["emailVerified"],
        phone: json["phone"] == null ? null : json["phone"],
        phoneVerified: json["phoneVerified"] == null ? null : json["phoneVerified"],
        gender: json["gender"] == null ? null : json["gender"],
        dateOfBirth: json["dateOfBirth"] == null ? null : json["dateOfBirth"],
        active: json["active"] == null ? null : json["active"],
        suspended: json["suspended"] == null ? null : json["suspended"],
        type: json["type"] == null ? null : json["type"],
        lastSeen: json["lastSeen"],
        dateCreated: json["dateCreated"] == null ? null : json["dateCreated"],
    );

    Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "firstName": firstName == null ? null : firstName,
        "lastName": lastName == null ? null : lastName,
        "profileImage": profileImage,
        "email": email == null ? null : email,
        "emailVerified": emailVerified == null ? null : emailVerified,
        "phone": phone == null ? null : phone,
        "phoneVerified": phoneVerified == null ? null : phoneVerified,
        "gender": gender == null ? null : gender,
        "dateOfBirth": dateOfBirth == null ? null : dateOfBirth,
        "active": active == null ? null : active,
        "suspended": suspended == null ? null : suspended,
        "type": type == null ? null : type,
        "lastSeen": lastSeen,
        "dateCreated": dateCreated == null ? null : dateCreated,
    };
}
