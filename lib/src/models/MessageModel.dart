// To parse this JSON data, do
//
//     final messageModel = messageModelFromJson(jsonString);

import 'dart:convert';
import 'package:date_format/date_format.dart';

MessageModel messageModelFromJson(String str) => MessageModel.fromJson(json.decode(str));

String messageModelToJson(MessageModel data) => json.encode(data.toJson());

class MessageModel {
    MessageModel({
        this.status,
        this.data,
    });

    bool status;
    Data data;

    factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        status: json["status"] == null ? null : json["status"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "status": status == null ? null : status,
        "data": data == null ? null : data.toJson(),
    };
}

class Data {
    Data({
        this.message,
        this.messages,
        this.accessToken,
    });

    Message message;
    List<Message> messages;
    String accessToken;

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        message: json["message"] == null ? null : Message.fromJson(json["message"]),
        messages: json["messages"] == null ? null : List<Message>.from(json["messages"].map((x) => Message.fromJson(x))),
        accessToken: json["accessToken"] == null ? null : json["accessToken"],
    );

    Map<String, dynamic> toJson() => {
        "message": message == null ? null : message.toJson(),
        "messages": messages == null ? null : List<dynamic>.from(messages.map((x) => x.toJson())),
        "accessToken": accessToken == null ? null : accessToken,
    };
}

class Message {
    Message({
        this.id,
        this.content,
        this.sentAt,
        this.type,
        this.receiverId,
        this.senderId,
        this.chatId,
        this.status,
    });

    int id;
    String content;
    DateTime sentAt;
    String type;
    int receiverId;
    int senderId;
    String chatId;
    int status;

    bool withBubble = false;

    factory Message.fromJson(Map<String, dynamic> json) => Message(
        id: json["id"] == null ? null : json["id"],
        content: json["content"] == null ? null : json["content"],
        sentAt: json["sent_at"] == null ? null : DateTime.parse(json["sent_at"]),
        type: json["type"] == null ? null : json["type"],
        receiverId: json["receiver_id"] == null ? null : json["receiver_id"],
        senderId: json["sender_id"] == null ? null : json["sender_id"],
        chatId: json["chat_id"] == null ? null : json["chat_id"],
        status: json["status"] == null ? null : json["status"],
    );

    Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "content": content == null ? null : content,
        "sent_at": sentAt == null ? null : sentAt.toIso8601String(),
        "type": type == null ? null : type,
        "receiver_id": receiverId == null ? null : receiverId,
        "sender_id": senderId == null ? null : senderId,
        "chat_id": chatId == null ? null : chatId,
        "status": status == null ? null : status,
    };

    String get fDate {

      DateTime now = DateTime.now();

      // check if today
      if(now.year == sentAt.year && now.month == sentAt.month && now.day == sentAt.day) {
        return formatDate(sentAt, [hh, ':', nn, ' ', am]);
      } 

      return formatDate(sentAt, [dd, ' ', M, ', ', yyyy]);

    }

    String get chatDate {
      return formatDate(sentAt, [hh, ':', nn, ' ', am]);

      // DateTime now = DateTime.now();

      // // check if today
      // if(now.year == sentAt.year && now.month == sentAt.month && now.day == sentAt.day) {
      //   return formatDate(sentAt, [hh, ':', nn, ' ', am]);
      // } 

      // // check if yesterday
      // if(now.year == sentAt.year && now.month == sentAt.month && now.day == (sentAt.day + 1)) {
      //   return formatDate(sentAt, ["Yesterday at ", hh, ':', nn, ' ', am]);
      // }

      // return formatDate(sentAt, [dd, ' ', M, ', ', yyyy]);
    }

    int get timestamp {
      return sentAt.microsecondsSinceEpoch;
    }

    String get tag {

      DateTime now = DateTime.now();

      // check if today
      if(now.year == sentAt.year && now.month == sentAt.month && now.day == sentAt.day) {
        return "Today";
      }

      // check if yesterday
      if(now.year == sentAt.year && now.month == sentAt.month && now.day == (sentAt.day + 1)) {
        return "Yesterday";
      }

      return formatDate(sentAt, [dd, ' ', M, ', ', yyyy]);
    }

}

